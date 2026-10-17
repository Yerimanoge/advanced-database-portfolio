

USE crypto_fintech;

SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'wallets', COUNT(*) FROM wallets
UNION ALL SELECT 'devices', COUNT(*) FROM devices
UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'ledger_entries', COUNT(*) FROM ledger_entries;


SELECT
  (SELECT COUNT(*) FROM wallets WHERE balance IS NULL)          AS wallets_null_balance,
  (SELECT COUNT(*) FROM transactions WHERE amount IS NULL)      AS transactions_null_amount,
  (SELECT COUNT(*) FROM transactions WHERE to_wallet_id IS NOT NULL) AS transactions_with_recipient;

