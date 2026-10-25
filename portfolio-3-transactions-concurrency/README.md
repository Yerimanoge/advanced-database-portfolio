# Portfolio 3: Transactions and Concurrency

## Objective

This activity implements Akira money movements as stored procedures and demonstrates commit, rollback, row locking and isolation. It uses the same MySQL `crypto_fintech` schema and the ledger design from Portfolio 1.

## Files and execution order

1. Run `SQL/01_create_procedures.sql` once after the Portfolio 1 migration and Portfolio 2 seed.
2. Run `SQL/02_transaction_tests.sql` and capture every result set.
3. Open two MySQL Workbench query tabs. Run the labelled statements in `SQL/03_concurrency_session_a.sql` and `SQL/04_concurrency_session_b.sql` in the stated order.
4. Save screenshots in `Evidence/` using the suggested names in the files.

The test script selects a personal sender and a personal recipient at runtime, then records their IDs in session variables. It does not depend on fixed seed IDs.

## Completed tests and evidence

- The procedures were created successfully (`Evidence/p3_01`).
- Transaction 103 completed as a 10.000000 transfer from wallet 2 to wallet 152, with two balanced original ledger entries (`Evidence/p3_04` to `p3_07`).
- The deliberate overdraft created failed transaction 104 with no ledger rows and no balance change (`Evidence/p3_08` to `p3_11`).
- Transaction 103 was reversed, which added two opposite reversal entries and restored both wallet balances (`Evidence/p3_12` to `p3_15`).
- The balance audit returned no rows after the tests (`Evidence/p3_16`).

## Concurrency evidence

- Session A and Session B ran through separate MySQL connections (IDs 17 and 20) at `REPEATABLE-READ` isolation.
- While Session A held wallet 2 with `SELECT ... FOR UPDATE`, Session B attempted the same lock and received MySQL error 1205 after 51 seconds (`Evidence/p3_18`). The lock wait demonstrates that a concurrent transaction cannot acquire the same row lock.
- Session A then committed its balanced 10.000000 transfer (`Evidence/p3_19`).
- After Session B rolled back its timed-out transaction, it read the committed balance and attempted to send one unit more than that balance. The procedure created failed transaction 106 with result `failed_insufficient_funds` (`Evidence/p3_20`).

The second reversal of transaction 103 was refused with MySQL error 1644, “Only completed transactions can be reversed” (`Evidence/p3_17`). This proves that a reversed transaction cannot be reversed again.

## Completion check

The final post-concurrency balance audit returned zero discrepancy rows (`Evidence/p3_21`). Portfolio 3 is complete.

The procedures can be recreated safely because the creation script drops its named procedures first.
