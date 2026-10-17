

USE crypto_fintech;
SET SQL_SAFE_UPDATES = 0;


SELECT COUNT(*) AS ledger_rows_must_be_zero FROM ledger_entries;

ALTER TABLE transactions
  ADD COLUMN `type`   ENUM('transfer','payment') NULL AFTER to_wallet_id,
  ADD COLUMN `status` ENUM('pending','completed','failed','reversed') NULL AFTER `type`;


DELETE FROM transactions WHERE `type` IS NULL;
ALTER TABLE transactions AUTO_INCREMENT = 1;

ALTER TABLE transactions
  MODIFY to_wallet_id INT NOT NULL,
  MODIFY amount DECIMAL(14,6) NOT NULL,
  MODIFY `type` ENUM('transfer','payment') NOT NULL,
  MODIFY `status` ENUM('pending','completed','failed','reversed') NOT NULL DEFAULT 'pending',
  ADD CONSTRAINT chk_txn_amount_positive  CHECK (amount > 0),
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
