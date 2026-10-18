-- Akira | Portfolio 2 | 01_seed_transactions.sql
-- GENERATED DATA: 100 synthetic transactions with matching ledger entries and wallet balances.
-- Run once, after Portfolio 1 scripts 00 to 04. Needs: transactions and ledger_entries both empty.
--
-- Design (fixed numbers, no RANDOM, so anyone can reproduce the same data):
--   n 1-45    completed transfer      n 46-70   completed payment (to merchant wallets)
--   n 71-80   reversed transfer       n 81-85   failed transfer    n 86-90  failed payment
--   n 91-95   pending transfer        n 96-100  pending payment
-- Each transaction has its OWN sender (the first 100 personal wallets with opening_balance >= 20),
-- and every amount is between 1.00 and 9.99, so no sender can ever be overdrawn.
-- Transfer recipients are personal wallets that never send; payment recipients are the 5 merchant wallets.
-- Failed and pending transactions have NO ledger entries and change no balance.
-- A reversed transaction has 4 ledger entries: 2 original and 2 reversal (opposite signs, one day later).

USE crypto_fintech;
SET SQL_SAFE_UPDATES = 0;

-- Guards: both must be 0. Note total_balance_before for the comparison at the end.
SELECT COUNT(*) AS transactions_must_be_zero FROM transactions;
SELECT COUNT(*) AS ledger_must_be_zero FROM ledger_entries;
SELECT SUM(balance) AS total_balance_before FROM wallets;


UPDATE wallets SET created_at = '2026-08-31' WHERE wallet_type = 'merchant';


CREATE TEMPORARY TABLE tmp_senders AS
SELECT s.n, s.wallet_id
FROM (
  SELECT ROW_NUMBER() OVER (ORDER BY w.id) AS n, w.id AS wallet_id
  FROM wallets AS w
  WHERE w.wallet_type = 'personal' AND w.opening_balance >= 20
) AS s
WHERE s.n <= 100;

CREATE TEMPORARY TABLE tmp_recv AS
SELECT ROW_NUMBER() OVER (ORDER BY w.id) AS k, w.id AS wallet_id
FROM wallets AS w
WHERE w.wallet_type = 'personal'
  AND w.id NOT IN (SELECT t.wallet_id FROM tmp_senders AS t);

CREATE TEMPORARY TABLE tmp_merch AS
SELECT ROW_NUMBER() OVER (ORDER BY m.id) AS k, m.wallet_id
FROM merchants AS m;

CREATE TEMPORARY TABLE tmp_plan AS
SELECT nums.n,
       CASE WHEN nums.n BETWEEN 46 AND 70 OR nums.n BETWEEN 86 AND 90 OR nums.n BETWEEN 96 AND 100
            THEN 'payment' ELSE 'transfer' END AS txn_type,
       CASE WHEN nums.n <= 70 THEN 'completed'
            WHEN nums.n <= 80 THEN 'reversed'
            WHEN nums.n <= 90 THEN 'failed'
            ELSE 'pending' END AS txn_status
FROM (SELECT ROW_NUMBER() OVER (ORDER BY u.id) AS n FROM users AS u) AS nums;   -- users has exactly 100 rows

SET @recv_cnt  = (SELECT COUNT(*) FROM tmp_recv);
SET @merch_cnt = (SELECT COUNT(*) FROM tmp_merch);
SELECT @recv_cnt AS recipient_wallets_expect_52, @merch_cnt AS merchant_wallets_expect_5,
       (SELECT COUNT(*) FROM tmp_senders) AS senders_expect_100;

SET SESSION optimizer_switch = 'derived_merge=off';

START TRANSACTION;

INSERT INTO transactions (wallet_id, to_wallet_id, amount, `timestamp`, `type`, `status`)
SELECT s.wallet_id,
       COALESCE(mc.wallet_id, rc.wallet_id),
       1 + MOD(p.n * 37, 900) / 100,
       DATE_ADD('2026-09-01 08:00:00', INTERVAL p.n * 7 HOUR),
       p.txn_type,
       p.txn_status
FROM tmp_plan AS p
JOIN tmp_senders AS s ON s.n = p.n
LEFT JOIN tmp_merch AS mc ON p.txn_type = 'payment'  AND mc.k = MOD(p.n, @merch_cnt) + 1
LEFT JOIN tmp_recv  AS rc ON p.txn_type = 'transfer' AND rc.k = MOD(p.n, @recv_cnt) + 1
ORDER BY p.n;

-- Ledger: balance_after starts at 0 and is filled in by the UPDATE below
INSERT INTO ledger_entries (transaction_id, wallet_id, entry_kind, change_amount, balance_after, created_at)
SELECT x.transaction_id, x.wallet_id, x.entry_kind, x.change_amount, 0, x.created_at
FROM (
  SELECT t.id AS transaction_id, 1 AS seq, t.wallet_id AS wallet_id, 'original' AS entry_kind,
         -t.amount AS change_amount, t.`timestamp` AS created_at
  FROM transactions AS t WHERE t.`status` IN ('completed','reversed')
  UNION ALL
  SELECT t.id, 2, t.to_wallet_id, 'original', t.amount, t.`timestamp`
  FROM transactions AS t WHERE t.`status` IN ('completed','reversed')
  UNION ALL
  SELECT t.id, 3, t.wallet_id, 'reversal', t.amount, DATE_ADD(t.`timestamp`, INTERVAL 1 DAY)
  FROM transactions AS t WHERE t.`status` = 'reversed'
  UNION ALL
  SELECT t.id, 4, t.to_wallet_id, 'reversal', -t.amount, DATE_ADD(t.`timestamp`, INTERVAL 1 DAY)
  FROM transactions AS t WHERE t.`status` = 'reversed'
) AS x
ORDER BY x.transaction_id, x.seq;

-- Running balance after each entry = opening_balance + cumulative change, per wallet, in time order
UPDATE ledger_entries AS le
JOIN (
  SELECT l.id,
         w.opening_balance + SUM(l.change_amount) OVER (PARTITION BY l.wallet_id ORDER BY l.created_at, l.id) AS running_balance
  FROM ledger_entries AS l
  JOIN wallets AS w ON w.id = l.wallet_id
) AS r ON r.id = le.id
SET le.balance_after = r.running_balance;

-- Stored wallet balance = opening_balance + total of its ledger entries
UPDATE wallets AS w
JOIN (
  SELECT l.wallet_id, SUM(l.change_amount) AS net_change
  FROM ledger_entries AS l
  GROUP BY l.wallet_id
) AS n ON n.wallet_id = w.id
SET w.balance = w.opening_balance + n.net_change;

COMMIT;

SET SESSION optimizer_switch = 'derived_merge=on';
DROP TEMPORARY TABLE tmp_plan;
DROP TEMPORARY TABLE tmp_merch;
DROP TEMPORARY TABLE tmp_recv;
DROP TEMPORARY TABLE tmp_senders;
