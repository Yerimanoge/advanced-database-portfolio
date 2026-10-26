USE crypto_fintech;

CREATE TABLE ledger_entries (
  id INT NOT NULL AUTO_INCREMENT,
  transaction_id INT NOT NULL,
  wallet_id INT NOT NULL,
  change_amount DECIMAL(14,6),
  balance_after DECIMAL(14,6),
  created_at TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_ledger_txn FOREIGN KEY (transaction_id) REFERENCES transactions (id),
  CONSTRAINT fk_ledger_wallet FOREIGN KEY (wallet_id) REFERENCES wallets (id)
);