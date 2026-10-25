-- Akira | Portfolio 2 | 04_indexes.sql
-- Index design chosen from the BEFORE plans in 03b (all four test queries scanned or sorted far more rows than needed).

USE crypto_fintech;

-- Size before (data_length and index_length are in bytes)
SELECT table_name, table_rows, data_length, index_length
FROM information_schema.tables
WHERE table_schema = 'crypto_fintech' AND table_name = 'perf_transactions';

-- ===== Part A: test table =====
ALTER TABLE perf_transactions
  ADD INDEX idx_perf_status_type_amount   (`status`, `type`, amount),
  ADD INDEX idx_perf_timestamp_amount     (`timestamp`, amount),
  ADD INDEX idx_perf_wallet_time          (wallet_id, `timestamp`),
  ADD INDEX idx_perf_to_type_status_amt   (to_wallet_id, `type`, `status`, amount);

ANALYZE TABLE perf_transactions;

-- Size after: compare index_length with the first result
SELECT table_name, table_rows, data_length, index_length
FROM information_schema.tables
WHERE table_schema = 'crypto_fintech' AND table_name = 'perf_transactions';

SHOW INDEX FROM perf_transactions;

-- ===== Part B: real table (run only after 05 confirms the benefit) =====
-- On 100 rows the optimiser will not use these, so the gain is design for growth, not a measured speed-up today.
-- ALTER TABLE transactions
--   ADD INDEX idx_txn_status_type_amount   (`status`, `type`, amount),
--   ADD INDEX idx_txn_timestamp_amount     (`timestamp`, amount),
--   ADD INDEX idx_txn_wallet_time          (wallet_id, `timestamp`),
--   ADD INDEX idx_txn_to_type_status_amt   (to_wallet_id, `type`, `status`, amount);
-- ANALYZE TABLE transactions;
