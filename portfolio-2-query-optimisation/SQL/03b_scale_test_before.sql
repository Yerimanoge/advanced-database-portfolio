-- Akira | Portfolio 2 | 03b_scale_test_before.sql
-- WHY: the real tables are far too small (100 rows) for MySQL to prefer an index over a table scan, so an index
-- would show no benefit. This script builds a SEPARATE test table, perf_transactions, with 200,000 GENERATED rows
-- in the same shape as transactions, so index effects can be measured. The real tables are not touched.
-- perf_transactions is GENERATED, synthetic test data for performance measurement only; it is not part of the Akira data.

USE crypto_fintech;

DROP TABLE IF EXISTS perf_transactions;
CREATE TABLE perf_transactions LIKE transactions;   

SET SESSION cte_max_recursion_depth = 250000;

-- 70% completed, 10% each failed / pending / reversed; 1 in 3 is a payment to merchant wallets 153 to 157
INSERT INTO perf_transactions (wallet_id, to_wallet_id, amount, `timestamp`, `type`, `status`)
WITH RECURSIVE seq (n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 200000
)
SELECT 1 + MOD(n, 152),
       IF(MOD(n, 3) = 0, 153 + MOD(n, 5), 1 + MOD(n + 37, 152)),
       1 + MOD(n * 37, 900) / 100,
       DATE_ADD('2025-01-01 00:00:00', INTERVAL n MINUTE),
       IF(MOD(n, 3) = 0, 'payment', 'transfer'),
       CASE MOD(n, 10) WHEN 0 THEN 'failed' WHEN 1 THEN 'pending' WHEN 2 THEN 'reversed' ELSE 'completed' END
FROM seq;

ANALYZE TABLE perf_transactions;   

SELECT COUNT(*) AS total_rows, SUM(`status` = 'completed') AS completed, SUM(`type` = 'payment') AS payments FROM perf_transactions;
SHOW INDEX FROM perf_transactions;

-- BEFORE plans. EXPLAIN gives the table view; EXPLAIN ANALYZE runs the query and shows real timings (one text cell:
-- right-click the cell, Copy Field, and paste it into a .txt file in Evidence/ as well as taking the screenshot).

-- PQ1 aggregate on status and type
EXPLAIN
SELECT COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions WHERE `status` = 'reversed' AND `type` = 'transfer';
EXPLAIN ANALYZE
SELECT COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions WHERE `status` = 'reversed' AND `type` = 'transfer';

-- PQ2 one week of activity grouped by day
EXPLAIN
SELECT DATE(`timestamp`) AS day, COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions
WHERE `timestamp` >= '2025-02-01' AND `timestamp` < '2025-02-08' GROUP BY DATE(`timestamp`) ORDER BY day;
EXPLAIN ANALYZE
SELECT DATE(`timestamp`) AS day, COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions
WHERE `timestamp` >= '2025-02-01' AND `timestamp` < '2025-02-08' GROUP BY DATE(`timestamp`) ORDER BY day;

-- PQ3 latest 20 transactions sent by one wallet
EXPLAIN
SELECT id, `type`, `status`, amount, `timestamp` FROM perf_transactions WHERE wallet_id = 10 ORDER BY `timestamp` DESC LIMIT 20;
EXPLAIN ANALYZE
SELECT id, `type`, `status`, amount, `timestamp` FROM perf_transactions WHERE wallet_id = 10 ORDER BY `timestamp` DESC LIMIT 20;

-- PQ4 spending by merchant category (same shape as Q4)
EXPLAIN
SELECT m.category, COUNT(*) AS payments, SUM(t.amount) AS total_spent
FROM perf_transactions AS t JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND t.`status` = 'completed' GROUP BY m.category;
EXPLAIN ANALYZE
SELECT m.category, COUNT(*) AS payments, SUM(t.amount) AS total_spent
FROM perf_transactions AS t JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND t.`status` = 'completed' GROUP BY m.category;
