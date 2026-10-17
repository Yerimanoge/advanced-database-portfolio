
USE crypto_fintech;
SET SQL_SAFE_UPDATES = 0;


SELECT COUNT(*) AS new_columns_present_expect_2
FROM information_schema.columns
WHERE table_schema = 'crypto_fintech' AND table_name = 'transactions' AND column_name IN ('type','status');
SELECT COUNT(*) AS ledger_rows_must_be_zero FROM ledger_entries;

DELETE FROM transactions WHERE `type` IS NULL;
ALTER TABLE transactions AUTO_INCREMENT = 1;
SELECT COUNT(*) AS transactions_rows_must_be_zero FROM transactions;

SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE transactions
  MODIFY to_wallet_id INT NOT NULL,
  MODIFY amount DECIMAL(14,6) NOT NULL,
  MODIFY `type` ENUM('transfer','payment') NOT NULL,
  MODIFY `status` ENUM('pending','completed','failed','reversed') NOT NULL DEFAULT 'pending',
  ADD CONSTRAINT chk_txn_amount_positive   CHECK (amount > 0),
  ADD CONSTRAINT chk_txn_different_wallets CHECK (wallet_id <> to_wallet_id);

ALTER TABLE ledger_entries
  MODIFY wallet_id INT NOT NULL,
  MODIFY change_amount DECIMAL(14,6) NOT NULL,
  MODIFY balance_after DECIMAL(14,6) NOT NULL,
  MODIFY created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN entry_kind ENUM('original','reversal') NOT NULL DEFAULT 'original' AFTER transaction_id,
  ADD CONSTRAINT chk_ledger_nonzero       CHECK (change_amount <> 0),
  ADD CONSTRAINT chk_ledger_balance_after CHECK (balance_after >= 0),
  ADD UNIQUE KEY uq_ledger_txn_wallet_kind (transaction_id, wallet_id, entry_kind);

SET FOREIGN_KEY_CHECKS = 1;


SELECT table_name, constraint_name
FROM information_schema.table_constraints
WHERE table_schema = 'crypto_fintech' AND constraint_type = 'FOREIGN KEY'
  AND table_name IN ('transactions','ledger_entries')
ORDER BY table_name, constraint_name;
