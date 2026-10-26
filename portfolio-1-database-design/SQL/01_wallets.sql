

USE crypto_fintech;
SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

ALTER TABLE wallets
  ADD COLUMN wallet_type ENUM('personal','merchant') NOT NULL DEFAULT 'personal' AFTER user_id,
  ADD COLUMN opening_balance DECIMAL(14,6) NOT NULL DEFAULT 0 AFTER wallet_type;


UPDATE wallets SET balance = 0 WHERE balance IS NULL;


UPDATE wallets SET opening_balance = balance;

ALTER TABLE wallets
  MODIFY balance DECIMAL(14,6) NOT NULL DEFAULT 0,
  ADD CONSTRAINT chk_wallets_opening_balance CHECK (opening_balance >= 0),
  ADD CONSTRAINT chk_balance CHECK (balance >= 0), 
  ADD UNIQUE KEY uq_wallets_id_user (id, user_id);   

COMMIT;
