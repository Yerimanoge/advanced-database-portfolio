USE crupto_fintech;
SELECT 'user' AS table_name, COUNT(*) AS total FROM users
UNION ALL SELECT 'devices', COUNT(*) FROM devices
UNION ALL SELECT 'wallets', COUNT(*) FROM wallets
UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;