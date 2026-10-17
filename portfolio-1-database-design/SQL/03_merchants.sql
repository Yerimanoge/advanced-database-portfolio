
USE crypto_fintech;
SET SQL_SAFE_UPDATES = 0;

CREATE TABLE merchants (
  id            INT NOT NULL AUTO_INCREMENT,
  user_id       INT NOT NULL,
  wallet_id     INT NOT NULL,
  business_name VARCHAR(100) NOT NULL,
  category      VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_merchants_user (user_id),            -- one merchant account per user
  UNIQUE KEY uq_merchants_wallet (wallet_id),        -- one wallet per merchant
  UNIQUE KEY uq_merchants_business_name (business_name),
  CONSTRAINT fk_merchants_user   FOREIGN KEY (user_id) REFERENCES users (id),
  -- composite FK: the wallet must belong to the same user who registered the merchant
  CONSTRAINT fk_merchants_wallet FOREIGN KEY (wallet_id, user_id) REFERENCES wallets (id, user_id)
) ENGINE=InnoDB;

-- GENERATED seed: the first 5 users (by id) that have both a username and an email
CREATE TEMPORARY TABLE tmp_merchant_seed AS
SELECT u.user_id, m.business_name, m.category
FROM (
  SELECT x.id AS user_id, ROW_NUMBER() OVER (ORDER BY x.id) AS rn
  FROM (SELECT id FROM users WHERE username IS NOT NULL AND email IS NOT NULL ORDER BY id LIMIT 5) AS x
) AS u
JOIN (
  SELECT 1 AS rn, 'Nova Grocers' AS business_name, 'Groceries' AS category
  UNION ALL SELECT 2, 'Pixel Electronics', 'Electronics'
  UNION ALL SELECT 3, 'Bluewave Travel',   'Travel'
  UNION ALL SELECT 4, 'Urban Eats',        'Food and Dining'
  UNION ALL SELECT 5, 'Lumen Utilities',   'Utilities'
) AS m ON m.rn = u.rn;

START TRANSACTION;

INSERT INTO wallets (user_id, wallet_type, opening_balance, balance, created_at)
SELECT t.user_id, 'merchant', 0, 0, CURDATE() FROM tmp_merchant_seed AS t;

INSERT INTO merchants (user_id, wallet_id, business_name, category)
SELECT t.user_id, w.id, t.business_name, t.category
FROM tmp_merchant_seed AS t
JOIN wallets AS w ON w.user_id = t.user_id AND w.wallet_type = 'merchant';

COMMIT;
DROP TEMPORARY TABLE tmp_merchant_seed;
