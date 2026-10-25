-- Akira | Portfolio 2 | 05_explain_after.sql

USE crypto_fintech;

-- PQ1
EXPLAIN
SELECT COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions WHERE `status` = 'reversed' AND `type` = 'transfer';
EXPLAIN ANALYZE
SELECT COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions WHERE `status` = 'reversed' AND `type` = 'transfer';

-- PQ2
EXPLAIN
SELECT DATE(`timestamp`) AS day, COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions
WHERE `timestamp` >= '2025-02-01' AND `timestamp` < '2025-02-08' GROUP BY DATE(`timestamp`) ORDER BY day;
EXPLAIN ANALYZE
SELECT DATE(`timestamp`) AS day, COUNT(*) AS n, SUM(amount) AS total FROM perf_transactions
WHERE `timestamp` >= '2025-02-01' AND `timestamp` < '2025-02-08' GROUP BY DATE(`timestamp`) ORDER BY day;

-- PQ3
EXPLAIN
SELECT id, `type`, `status`, amount, `timestamp` FROM perf_transactions WHERE wallet_id = 10 ORDER BY `timestamp` DESC LIMIT 20;
EXPLAIN ANALYZE
SELECT id, `type`, `status`, amount, `timestamp` FROM perf_transactions WHERE wallet_id = 10 ORDER BY `timestamp` DESC LIMIT 20;


-- PQ4
EXPLAIN
SELECT m.category, COUNT(*) AS payments, SUM(t.amount) AS total_spent
FROM perf_transactions AS t JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND t.`status` = 'completed' GROUP BY m.category;
EXPLAIN ANALYZE
SELECT m.category, COUNT(*) AS payments, SUM(t.amount) AS total_spent
FROM perf_transactions AS t JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND t.`status` = 'completed' GROUP BY m.category;


