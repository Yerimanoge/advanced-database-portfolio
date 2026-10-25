-- Akira | Portfolio 2 | 03_explain_real_tables.sql
-- Execution plans BEFORE any new index, on the real Akira tables (100 transactions, 180 ledger rows).
-- Run each EXPLAIN on its own (select it, Execute Current Statement). Screenshot the plan with the query visible.
-- Columns to read: type (ALL = full table scan, ref/eq_ref/range = index used), key (index used),
--                  rows (estimated rows examined), Extra (Using filesort / Using temporary are the costly ones).
USE crypto_fintech;

-- Indexes that exist today on transactions (screenshot this too)
SHOW INDEX FROM transactions;

-- E1 plan for Q3 (volume by status and type)
EXPLAIN
SELECT t.`status`, t.`type`, COUNT(*) AS transactions, SUM(t.amount) AS total_amount, ROUND(AVG(t.amount), 4) AS average_amount
FROM transactions AS t
GROUP BY t.`status`, t.`type`
ORDER BY t.`status`, t.`type`;

-- E2 plan for Q4 (spending by merchant category)
EXPLAIN
SELECT m.category, COUNT(*) AS payments, SUM(t.amount) AS total_spent
FROM transactions AS t
JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND t.`status` = 'completed'
GROUP BY m.category
ORDER BY total_spent DESC;

-- E3 plan for Q8 (reversal report)
EXPLAIN
SELECT t.id AS transaction_id, t.amount, SUM(l.change_amount) AS net_effect
FROM transactions AS t
JOIN ledger_entries AS l ON l.transaction_id = t.id
WHERE t.`status` = 'reversed'
GROUP BY t.id, t.amount
ORDER BY t.id;

-- E4 plan for Q12 (NOT EXISTS with OR)
EXPLAIN
SELECT COUNT(*) AS inactive_personal_wallets
FROM wallets AS w
WHERE w.wallet_type = 'personal'
  AND NOT EXISTS (SELECT 1 FROM transactions AS t WHERE t.wallet_id = w.id OR t.to_wallet_id = w.id);
