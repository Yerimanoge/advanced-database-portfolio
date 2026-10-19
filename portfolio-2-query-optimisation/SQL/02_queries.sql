-- Akira | Portfolio 2 | 02_queries.sql
USE crypto_fintech;

-- Q1 Filtering and sorting: the ten largest completed transactions
SELECT t.id, t.wallet_id AS sender_wallet, t.to_wallet_id AS recipient_wallet, t.`type`, t.amount, t.`timestamp`
FROM transactions AS t
WHERE t.`status` = 'completed'
ORDER BY t.amount DESC, t.id
LIMIT 10;

-- Q2 Joins: who sent what to whom (sender and recipient names through wallets and users)
SELECT t.id, t.`timestamp`, t.`type`, t.`status`, t.amount,
       COALESCE(su.username, CONCAT('user#', su.id)) AS sender,
       COALESCE(ru.username, CONCAT('user#', ru.id)) AS recipient
FROM transactions AS t
JOIN wallets AS sw ON sw.id = t.wallet_id
JOIN users   AS su ON su.id = sw.user_id
JOIN wallets AS rw ON rw.id = t.to_wallet_id
JOIN users   AS ru ON ru.id = rw.user_id
ORDER BY t.id
LIMIT 20;

-- Q3 Transaction volume by status and type (report E)

SELECT t.`status`, t.`type`, COUNT(*) AS transactions, SUM(t.amount) AS total_amount, ROUND(AVG(t.amount), 4) AS average_amount
FROM transactions AS t
GROUP BY t.`status`, t.`type`
ORDER BY t.`status`, t.`type`;

-- Q4 Spending by merchant category (report E, merchant payments B)

SELECT m.category, COUNT(*) AS payments, SUM(t.amount) AS total_spent
FROM transactions AS t
JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND t.`status` = 'completed'
GROUP BY m.category
ORDER BY total_spent DESC;

-- Q5 Wallet activity: the ten busiest wallets (sent plus received), using two grouped subqueries
SELECT w.id AS wallet_id, w.wallet_type,
       COALESCE(s.sent_count, 0) AS sent,
       COALESCE(r.received_count, 0) AS received,
       COALESCE(s.sent_count, 0) + COALESCE(r.received_count, 0) AS total_activity
FROM wallets AS w
LEFT JOIN (SELECT t.wallet_id AS wallet_id, COUNT(*) AS sent_count
           FROM transactions AS t GROUP BY t.wallet_id) AS s ON s.wallet_id = w.id
LEFT JOIN (SELECT t.to_wallet_id AS wallet_id, COUNT(*) AS received_count
           FROM transactions AS t GROUP BY t.to_wallet_id) AS r ON r.wallet_id = w.id
ORDER BY total_activity DESC, w.id
LIMIT 10;

-- Q6 Scalar subquery: personal wallets with a balance above the personal-wallet average
SELECT w.id, w.user_id, w.balance
FROM wallets AS w
WHERE w.wallet_type = 'personal'
  AND w.balance > (SELECT AVG(p.balance) FROM wallets AS p WHERE p.wallet_type = 'personal')
ORDER BY w.balance DESC
LIMIT 10;

-- Q7 GROUP BY with HAVING: users who hold more than one wallet, with their combined balance
SELECT u.id AS user_id, COALESCE(u.username, CONCAT('user#', u.id)) AS username,
       COUNT(w.id) AS wallets, SUM(w.balance) AS combined_balance
FROM users AS u
JOIN wallets AS w ON w.user_id = u.id
GROUP BY u.id, u.username
HAVING COUNT(w.id) > 1
ORDER BY combined_balance DESC
LIMIT 10;

-- Q8 Reversal report (operation C): each reversed transaction with its original and reversal ledger entries
SELECT t.id AS transaction_id, t.amount, t.wallet_id AS sender_wallet, t.to_wallet_id AS recipient_wallet,
       SUM(CASE WHEN l.entry_kind = 'original' AND l.wallet_id = t.wallet_id    THEN l.change_amount END) AS original_sender,
       SUM(CASE WHEN l.entry_kind = 'original' AND l.wallet_id = t.to_wallet_id THEN l.change_amount END) AS original_recipient,
       SUM(CASE WHEN l.entry_kind = 'reversal' AND l.wallet_id = t.wallet_id    THEN l.change_amount END) AS reversal_sender,
       SUM(CASE WHEN l.entry_kind = 'reversal' AND l.wallet_id = t.to_wallet_id THEN l.change_amount END) AS reversal_recipient,
       SUM(l.change_amount) AS net_effect
FROM transactions AS t
JOIN ledger_entries AS l ON l.transaction_id = t.id
WHERE t.`status` = 'reversed'
GROUP BY t.id, t.amount, t.wallet_id, t.to_wallet_id
ORDER BY t.id;

-- Q9 Balance audit summary (operation D): reports differences, never corrects them. Expect 157 wallets checked, 0 discrepancies
SELECT COUNT(*) AS wallets_checked, SUM(a.calculated_balance <> a.stored_balance) AS discrepancies
FROM (
  SELECT w.id, w.balance AS stored_balance,
         w.opening_balance + COALESCE(SUM(l.change_amount), 0) AS calculated_balance
  FROM wallets AS w
  LEFT JOIN ledger_entries AS l ON l.wallet_id = w.id
  GROUP BY w.id, w.balance, w.opening_balance
) AS a;

-- Q10 Merchant-payment integrity (operation B): payments whose recipient is NOT a registered merchant wallet. Expect 0 rows
SELECT t.id, t.to_wallet_id
FROM transactions AS t
LEFT JOIN merchants AS m ON m.wallet_id = t.to_wallet_id
WHERE t.`type` = 'payment' AND m.id IS NULL;

-- Q11 Weekly transaction volume (report E)
SELECT YEARWEEK(t.`timestamp`, 3) AS iso_week, COUNT(*) AS transactions, SUM(t.amount) AS total_amount
FROM transactions AS t
GROUP BY YEARWEEK(t.`timestamp`, 3)
ORDER BY iso_week;

-- Q12 NOT EXISTS: personal wallets that never sent or received anything (note the OR on two columns:

SELECT COUNT(*) AS inactive_personal_wallets
FROM wallets AS w
WHERE w.wallet_type = 'personal'
  AND NOT EXISTS (SELECT 1 FROM transactions AS t WHERE t.wallet_id = w.id OR t.to_wallet_id = w.id);

-- Q13 Wallet statement: ledger of the sender of transaction 71 (a reversed one): expect 2 entries, balance_after returns to opening
SET @stmt_wallet = (SELECT t.wallet_id FROM transactions AS t WHERE t.id = 71);
SELECT l.created_at, l.transaction_id, l.entry_kind, l.change_amount, l.balance_after
FROM ledger_entries AS l
WHERE l.wallet_id = @stmt_wallet
ORDER BY l.created_at, l.id;

-- Q14 Dataset check: users per device type (original data)
SELECT d.device_type, COUNT(DISTINCT d.user_id) AS users, COUNT(*) AS devices
FROM devices AS d
GROUP BY d.device_type
ORDER BY users DESC;
