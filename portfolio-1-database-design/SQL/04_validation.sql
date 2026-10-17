
USE crypto_fintech;


SELECT table_name, column_name, column_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'crypto_fintech'
  AND table_name IN ('wallets','transactions','ledger_entries','merchants')
ORDER BY table_name, ordinal_position;


SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'crypto_fintech'
ORDER BY table_name, constraint_type, constraint_name;


SELECT (SELECT COUNT(*) FROM wallets) AS wallets, (SELECT COUNT(*) FROM merchants) AS merchants,
       (SELECT COUNT(*) FROM transactions) AS transactions, (SELECT COUNT(*) FROM ledger_entries) AS ledger_entries;

SELECT id FROM wallets WHERE balance IS NULL;


SELECT m.id, m.business_name, m.category, u.username, w.id AS wallet_id, w.wallet_type, w.balance
FROM merchants AS m
JOIN users   AS u ON u.id = m.user_id
JOIN wallets AS w ON w.id = m.wallet_id;


SELECT w.id AS wallet_id, w.balance AS stored_balance,
       w.opening_balance + COALESCE(SUM(l.change_amount), 0) AS calculated_balance
FROM wallets AS w
LEFT JOIN ledger_entries AS l ON l.wallet_id = w.id
GROUP BY w.id, w.balance, w.opening_balance
HAVING w.balance <> w.opening_balance + COALESCE(SUM(l.change_amount), 0);


