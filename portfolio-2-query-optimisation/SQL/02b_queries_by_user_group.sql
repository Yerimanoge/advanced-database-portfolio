-- Akira | Portfolio 2 | 02b_queries_by_user_group.sql
-- Four extra queries aimed at the case study's user groups (regular user, merchant, data analyst).
-- Corrected to the REAL column names of this schema:

USE crypto_fintech;

-- Q15 Regular user: what transactions have I sent and received?

SET @wallet_id = 120;
SELECT t.id AS transaction_id, t.`timestamp`, t.amount,
       CASE WHEN t.wallet_id = @wallet_id THEN 'Sent' ELSE 'Received' END AS direction,
       CASE WHEN t.wallet_id = @wallet_id THEN t.to_wallet_id ELSE t.wallet_id END AS other_wallet,
       t.`type`, t.`status`
FROM transactions AS t
WHERE t.wallet_id = @wallet_id OR t.to_wallet_id = @wallet_id
ORDER BY t.`timestamp` DESC;

-- Q16 Merchant: how much did my business receive each week from completed payments?
SET @merchant_id = 1;
SELECT YEARWEEK(t.`timestamp`, 3) AS transaction_week, COUNT(*) AS payment_count, SUM(t.amount) AS weekly_revenue
FROM transactions AS t
JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE m.id = @merchant_id AND t.`type` = 'payment' AND t.`status` = 'completed'
GROUP BY YEARWEEK(t.`timestamp`, 3)
ORDER BY transaction_week;

-- Q17 Regular user: statement of one wallet with a running balance calculated from the ledger.

SET @wallet_id = 81;
SELECT l.created_at, l.transaction_id, l.entry_kind, l.change_amount,
       w.opening_balance + SUM(l.change_amount) OVER (
           PARTITION BY l.wallet_id ORDER BY l.created_at, l.id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance,
       l.balance_after
FROM ledger_entries AS l
JOIN wallets AS w ON w.id = l.wallet_id
WHERE l.wallet_id = @wallet_id
ORDER BY l.created_at, l.id;

-- Q18 Data analyst: what percentage of transactions fail for each transaction type?

SELECT t.`type` AS transaction_type,
       COUNT(*) AS total_transactions,
       SUM(CASE WHEN t.`status` = 'failed' THEN 1 ELSE 0 END) AS failed_transactions,
       ROUND(100.0 * SUM(CASE WHEN t.`status` = 'failed' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS failure_rate_percent
FROM transactions AS t
GROUP BY t.`type`
ORDER BY failure_rate_percent DESC;
