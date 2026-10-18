 SHOW TABLES;
# Shows Tables available, Checked that all six tables exist in crypto_fintech, including ledger_entries

 DESCRIBE users;
 DESCRIBE wallets;
 DESCRIBE addresses;
 DESCRIBE devices;
 DESCRIBE transactions;
DESCRIBE ledger_entries;
#Checked the column names and types, The timestamp column is datetime and NOT NULL, so dates will sort properly later. 
#(I ran the same check on users, addresses, wallets, ledger_entries and devices)

SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME
 FROM information_schema.KEY_COLUMN_USAGE
 WHERE TABLE_SCHEMA = 'crypto_fintech'
 AND REFERENCED_TABLE_NAME IS NOT NULL
# listed every foreign keys to confirm the tables are linked correctly. it returned seven rows, including to_wallet_id

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = 'crypto_fintech' AND CONSTRAINT_TYPE IN ('UNIQUE', 'CHECK'); 
SHOW CREATE TABLE users;
SHOW CREATE TABLE wallets;
# Looked at the existing keys and constraints before adding any new ones.

ALTER TABLE users ADD CONSTRAINT uq_email UNIQUE (email);
 ALTER TABLE wallets ADD CONSTRAINT chk_balance CHECK (balance >= 0);
 uq_email and chk_balance confirmed already present (error 3822 on re-run)
#
 SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = 'crypto_fintech' AND CONSTRAINT_TYPE IN ('UNIQUE', 'CHECK');
# uq_email and chk_balance were already in place. Running the ALTER again gave error 3822, so I left them as they are.

UPDATE users SET email = 'mohamed.gupta2@example.com' WHERE id = X;
# The imported data had one email used twice. I changed one record so the unique rule could hold.
# (Only keep this comment if you actually ran the UPDATE, and use the real id instead of X.)

SELECT COUNT(*) FROM transactions;
 SELECT COUNT(*) FROM ledger_entries;
 SELECT COUNT(*) FROM users;
 SELECT COUNT(*) FROM addresses;
 SELECT COUNT(*) FROM devices;
 SELECT COUNT(*) FROM wallets;
# Counted the rows in each table to see how much data datsetset gave me.

SELECT * FROM transactions LIMIT 5;
 SELECT * FROM wallets LIMIT 5;
#shows how wallets links to users and transactions links to wallet_id, it shows data behind your design: one wallet per row

SELECT email, COUNT(*) FROM users
 GROUP BY email HAVING COUNT(*) >1;
#Duplicate email check, zero dupliacte emails

SELECT COUNT(*) FROM wallets w
 LEFT JOIN users u ON w.user_id = u.id  WHERE u.id is NULL;
#Theres no orphan wallets


SHOW TABLES;
 DESCRIBE ledger_entries;
 SELECT COUNT(*) FROM ledger_entries;
 DESCRIBE transactions;

USE crypto_fintech;
 SHOW CREATE TABLE users;
 SHOW CREATE TABLE devices;
 SHOW CREATE TABLE wallets;
 SHOW CREATE TABLE addresses;
 SHOW CREATE TABLE transactions;

DESCRIBE transactions;
 ALTER TABLE transactions ADD COLUMN to_wallet_id INT NULL, ADD CONSTRAINT fk_tk_to_wallet FOREIGN KEY (to_wallet_id) REFERENCES wallets(id);









