-- Akira | Portfolio 2 | 01b_seed_validation.sql

USE crypto_fintech;


SELECT `status`, `type`, COUNT(*) AS n FROM transactions GROUP BY `status`, `type` ORDER BY `status`, `type`;


SELECT t.`status`, COUNT(DISTINCT t.id) AS transactions, COUNT(l.id) AS ledger_rows
FROM transactions AS t LEFT JOIN ledger_entries AS l ON l.transaction_id = t.id
GROUP BY t.`status` ORDER BY t.`status`;


SELECT l.transaction_id, l.entry_kind, SUM(l.change_amount) AS imbalance
FROM ledger_entries AS l GROUP BY l.transaction_id, l.entry_kind HAVING SUM(l.change_amount) <> 0;


SELECT w.id AS wallet_id, w.balance AS stored_balance,
       w.opening_balance + COALESCE(SUM(l.change_amount), 0) AS calculated_balance
FROM wallets AS w LEFT JOIN ledger_entries AS l ON l.wallet_id = w.id
GROUP BY w.id, w.balance, w.opening_balance
HAVING w.balance <> w.opening_balance + COALESCE(SUM(l.change_amount), 0);


SELECT SUM(balance) AS total_balance_after FROM wallets;


SELECT w.id AS wallet_id, w.balance, last_e.balance_after
FROM wallets AS w
JOIN (
  SELECT l.wallet_id, l.balance_after,
         ROW_NUMBER() OVER (PARTITION BY l.wallet_id ORDER BY l.created_at DESC, l.id DESC) AS rn
  FROM ledger_entries AS l
) AS last_e ON last_e.wallet_id = w.id AND last_e.rn = 1
WHERE w.balance <> last_e.balance_after;


SELECT m.id AS merchant_id, m.business_name, COUNT(*) AS payments, SUM(t.amount) AS received
FROM merchants AS m
JOIN transactions AS t ON t.to_wallet_id = m.wallet_id AND t.`status` = 'completed'
GROUP BY m.id, m.business_name ORDER BY m.id;
