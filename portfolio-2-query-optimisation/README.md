# Portfolio 2: Query Processing and Optimisation

## Objective

This portfolio demonstrates SQL querying, execution-plan analysis and targeted index design on the Akira schema. The operational data is generated and deterministic, so another reviewer can reproduce it.

## Verified work and evidence

| Activity | Status | Evidence |
|---|---|---|
| Seed 100 Akira transactions and ledger rows | Executed and validated | `Evidence/p2_01a` to `p2_04g` |
| Queries Q1–Q14 | Executed; results checked | `Evidence/p2_05` to `p2_18` |
| User-group queries Q15–Q18 | Executed | `Evidence/p2_19` to `p2_22` |
| Real-table execution plans before performance indexes | Executed | `Evidence/p2_40a` to `p2_44` |
| Before-index plans on 200,000-row test table | Executed | `Evidence/scale_test_before.txt`, screenshots 23–24 |
| Index creation and after-index plans | Executed | `Evidence/Scale_test_after.txt`, screenshots 25–27 |

## Execution order

Portfolio 1 migrations → `01_seed_transactions.sql` → `01b_seed_validation.sql` → `02_queries.sql` → `03_explain_real_tables.sql` → `03b_scale_test_before.sql` → `04_indexes.sql` Part A → `05_explain_after.sql` → `02b_queries_by_user_group.sql`.

The four indexes were applied to `perf_transactions`, the separate 200,000-row test table. They were deliberately not applied to the small real `transactions` table; the commented Part B statements are a future growth option. See `analysis.md` for the measured comparison and trade-offs.

The real-table plans are a baseline: they show that MySQL sensibly scans or uses existing foreign-key indexes on a 100-row operational table. The scale test provides the measurable before-and-after index comparison at 200,000 rows.

## Data provenance

`transactions`, `ledger_entries` and `perf_transactions` are generated project data. The seed script uses fixed arithmetic, no random values, and amounts from 1.00 to 9.99. The original dataset remains unchanged in `Dataset.sql`.
