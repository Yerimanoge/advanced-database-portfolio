# Portfolio 2 performance analysis

## Scope and method

Akira's operational `transactions` table contains only 100 generated rows. At that size, full scans are inexpensive and MySQL may reasonably choose them. To measure index behaviour at a meaningful scale without altering the business dataset, `03b_scale_test_before.sql` created the separate, deterministic `perf_transactions` table with 200,000 rows. Its query pattern mirrors the real transaction table.

Each query was captured first without the targeted indexes and again after `04_indexes.sql` created four composite indexes. The comparison below uses the `EXPLAIN ANALYZE` output in `Evidence/scale_test_before.txt` and `Evidence/Scale_test_after.txt`. Timings are from one local run, so they show the direction and size of change in this environment rather than a universal benchmark.

| Query | Before | After | Change | Interpretation |
|---|---:|---:|---:|---|
| PQ1: reversed transfers by status and type | 219 ms, full table scan of 200,000 rows | 21.3 ms, covering lookup of 13,333 rows | about 90% faster | `idx_perf_status_type_amount` matched both filters and supplied the amount for the aggregate. |
| PQ2: daily totals for a seven-day date range | 156 ms, full table scan | 22.3 ms, covering range scan of 10,080 rows | about 86% faster | `idx_perf_timestamp_amount` limited the read to the requested week. The temporary aggregation and final sort remain because the result groups by `DATE(timestamp)`. |
| PQ3: latest 20 transactions for one wallet | 8.2 ms, wallet lookup then sort of 1,316 rows | 8.2 ms, reverse index lookup | plan improved; elapsed time was effectively unchanged | `idx_perf_wallet_time` removed the explicit sort by providing rows in timestamp order. At this small result limit, the measured wall-clock saving was below the noise of this run. |
| PQ4: completed payments by merchant category | 500 ms, five recipient-index lookups then filtering | 167 ms, covering lookup of the required payment rows | about 67% faster | `idx_perf_to_type_status_amt` narrowed each merchant lookup by recipient, type and status. The grouping temporary table remains. |

## Index decisions and trade-offs

The indexes are deliberately narrow and query-led. `status, type, amount` supports PQ1; `timestamp, amount` supports the date range and aggregate in PQ2; `wallet_id, timestamp` supports a wallet statement in newest-first order; and `to_wallet_id, type, status, amount` supports merchant-payment reporting. The after plans identify these indexes as covering where the selected columns are available from the index, avoiding additional table-row reads.

Indexes are not free. They increase `perf_transactions` index storage (shown in evidence files 23–27) and make inserts, updates and deletes maintain more B-tree entries. For that reason, the tested indexes were created on the performance table only. The equivalent real-table statements remain commented out in `04_indexes.sql`; they should be enabled only if production-scale measurements show the same workload is important.

## Conclusion

The test supports the design decision to add targeted composite indexes for selective filters, date ranges and ordered wallet history as the transaction volume grows. The result also shows that an index does not guarantee a visible timing improvement for every query: PQ3 produced a better no-sort plan, but the measured elapsed time was almost identical. Query plans and realistic data size should therefore guide index decisions, together with the write cost and storage cost.
