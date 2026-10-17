CREATE DATABASE IF NOT EXISTS crypto_fintech_backup;

CREATE TABLE crypto_fintech_backup.users          LIKE crypto_fintech.users;
CREATE TABLE crypto_fintech_backup.wallets        LIKE crypto_fintech.wallets;
CREATE TABLE crypto_fintech_backup.devices        LIKE crypto_fintech.devices;
CREATE TABLE crypto_fintech_backup.addresses      LIKE crypto_fintech.addresses;
CREATE TABLE crypto_fintech_backup.transactions   LIKE crypto_fintech.transactions;
CREATE TABLE crypto_fintech_backup.ledger_entries LIKE crypto_fintech.ledger_entries;

INSERT INTO crypto_fintech_backup.users          SELECT * FROM crypto_fintech.users;
INSERT INTO crypto_fintech_backup.wallets        SELECT * FROM crypto_fintech.wallets;
INSERT INTO crypto_fintech_backup.devices        SELECT * FROM crypto_fintech.devices;
INSERT INTO crypto_fintech_backup.addresses      SELECT * FROM crypto_fintech.addresses;
INSERT INTO crypto_fintech_backup.transactions   SELECT * FROM crypto_fintech.transactions;
INSERT INTO crypto_fintech_backup.ledger_entries SELECT * FROM crypto_fintech.ledger_entries;

SELECT 'users' AS t, COUNT(*) AS n FROM crypto_fintech_backup.users
UNION ALL SELECT 'wallets', COUNT(*) FROM crypto_fintech_backup.wallets
UNION ALL SELECT 'devices', COUNT(*) FROM crypto_fintech_backup.devices
UNION ALL SELECT 'addresses', COUNT(*) FROM crypto_fintech_backup.addresses
UNION ALL SELECT 'transactions', COUNT(*) FROM crypto_fintech_backup.transactions
UNION ALL SELECT 'ledger_entries', COUNT(*) FROM crypto_fintech_backup.ledger_entries;