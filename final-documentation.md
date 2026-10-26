# Akira fintech cryptocurrency platform: Advanced Database Systems portfolio

**Course:** MIT 8103 Advanced Database Systems  
**Repository:** <https://github.com/Yerimanoge/advanced-database-portfolio>  
**Dataset source:** Database Sample. (2026). *Cryptocurrency Transaction Insights* [Synthetic dataset]. Accessed 15 October 2026. <https://databasesample.com/datasets/cryptocurrency-transaction-insights>  
**Environment:** MySQL Community Server 26.7.0 with MySQL Workbench; local MongoDB Community Server 9.0.4 with MongoDB Compass and `mongosh`.

## Organisation and database scope

Akira is a fintech cryptocurrency platform that lets users maintain wallets, transfer cryptocurrency to other users and pay registered merchants. This portfolio models one currency unit only. It stores users, devices, wallets, addresses, merchants, transactions and ledger entries. The principal operations are transfers, merchant payments, reversals that preserve history, balance audits and analytical reporting.

The original synthetic dataset supplied users, devices, wallets, addresses and transactions. Its transaction rows could not represent a complete Akira transfer because they lacked recipient, type and status information. They were therefore retained in the source dataset but removed from the working schema. The project generated clearly labelled merchant, transaction and ledger data for the Akira business rules. NULL wallet balances were converted to zero and captured in a new opening-balance field.

## Portfolio 1: Database design and modelling

The final relational design has seven tables. `users` owns `wallets` and `devices`; wallets own addresses; `merchants` links a merchant user to one merchant wallet; `transactions` records sender and recipient wallets; and `ledger_entries` records the signed accounting events. A composite foreign key ensures that a merchant wallet belongs to its registered merchant user.

The main financial constraints are positive transaction amounts, different sender and recipient wallets, non-negative wallet balances, unique merchants, and unique transaction/wallet/entry-kind ledger records. `wallets.balance` is intentionally stored for fast balance checks, while `ledger_entries` provides the auditable history. The balance audit compares the stored balance against `opening_balance + SUM(change_amount)` and reports differences without silently repairing them.

**Insert evidence:** Akira ER diagram; a validation screenshot showing the final tables and constraints; a negative-test screenshot showing failed self-transfer, zero-amount, duplicate-merchant or overdraft checks.

## Portfolio 2: Query processing and optimisation

Portfolio 2 uses a deterministic seed of 100 generated Akira transactions and 180 ledger entries. It includes fourteen operational and analytical SQL queries plus four user-group queries for wallet history, merchant weekly revenue, a wallet statement and failure rates. The evidence shows joins, grouping, subqueries, window functions and balance-audit queries.

Because 100 operational rows are too small to demonstrate meaningful optimisation, a separate `perf_transactions` table with 200,000 generated rows was used. Before indexing, the four performance queries used full table scans or an explicit sort. Four targeted composite indexes produced covering index lookups or range scans. Measured elapsed time fell from 219 ms to 21.3 ms for reversed-transfer aggregation, 156 ms to 22.3 ms for the weekly date range, and 500 ms to 167 ms for completed merchant payments. The wallet-history plan removed its sort, although its observed runtime remained about 8.2 ms. The analysis records index storage and write-maintenance costs, so the indexes were tested on the performance table rather than automatically added to the small operational table.

**Insert evidence:** one before/after `EXPLAIN ANALYZE` comparison and one index-size screenshot.

## Portfolio 3: Transactions and concurrency

The portfolio supplies `sp_post_transaction` and `sp_reverse_transaction`. A completed movement locks the sender and recipient wallets in a stable ID order, checks funds and payment-recipient rules, inserts the transaction, updates both wallet balances and records the matching signed ledger entries in one transaction. If funds are insufficient, the procedure commits a `failed` transaction with no ledger posting or balance change. The reversal procedure locks both wallets, refuses a second reversal or a reversal where the recipient no longer holds the amount, then posts the opposite ledger entries and changes the transaction status to `reversed`.

The two-session demonstration uses SELECT ... FOR UPDATE under the server's recorded isolation level (REPEATABLE-READ). Session B waits while Session A holds the sender-wallet lock and receives a lock-wait timeout (error 1205). After Session A commits its balanced transfer, Session B rolls back its timed-out transaction, reads the newly committed balance and attempts a deliberate overdraw. This overdraft attempt is recorded as a failed transaction with no ledger posting or balance change. This demonstrates row-level locking, commit/rollback control and protection against concurrent overspending.

Execution evidence is stored in `portfolio-3-transactions-concurrency/Evidence/`. It records a successful 10 AKR transfer, an insufficient-funds transaction recorded as `failed` with no ledger entries, a successful reversal, a rejected second reversal and two independent MySQL sessions. Session B received a lock-wait timeout while Session A held the wallet lock and the final balance audit returned zero discrepancy rows.

## Portfolio 4: NoSQL and advanced data models

MongoDB provides a document-oriented, read-focused `wallet_activity` projection. One document represents one wallet and embeds a bounded collection of recent transfer or payment events. This supports an efficient mobile wallet statement because the wallet summary and recent activity are read together. Indexes support unique wallet lookup, event-time ordering and completed merchant-payment analysis.

The document database is not the authoritative financial ledger. MySQL remains the source of truth for cross-wallet ACID transactions, foreign-key relationships and no-overdraft enforcement. Embedded events are deliberately bounded; an unbounded transaction history would be moved to a separate collection or retrieved from the relational ledger.

Execution evidence is stored in `portfolio-4-nosql/Evidence/`. A local MongoDB collection contains two wallet documents. The wallet-statement aggregation returned the two events in newest-first order, the merchant aggregation returned one `Groceries` payment totalling `8.500000` AKR, and `explain('executionStats')` showed the unique wallet index (`uq_wallet_activity_wallet`) with one key and one document examined. MongoDB Compass also shows the collection and both documents in its graphical Documents interface.

## Portfolio 5: Distributed and cloud database exercise

The proposed Akira deployment uses a single writable MySQL primary for transfers, payments, reversals and immediate balance reads, plus asynchronous read replicas for analytics and reports. Automated encrypted backups and point-in-time recovery support restoration. Replication improves availability and read capacity, but a replica may lag; a user should therefore read a just-written balance from the primary.

Akira chooses consistency for money movements over multi-region write availability. If later scale requires sharding, wallets should be partitioned by a stable wallet-home key to keep most balance activity local. Cross-shard transfers require distributed coordination or an explicit compensating design and idempotency controls. At the current scale, sharding adds more operational risk than benefit.

This portfolio is a documented deployment design rather than a cloud deployment. The local-server baseline recorded on 26 October 2026 shows a writable instance (`read_only = false`) with `REPEATABLE-READ` isolation, binary logging enabled, and `server_id = 1`. `SHOW REPLICA STATUS` returned zero rows, so no local replica is configured. `SHOW BINARY LOG STATUS` returned an active binary-log file, position and GTID set. The supporting screenshots are in `portfolio-5-distributed-cloud/Evidence/`.

## Individual reflection

My individual reflection is available in `personal-reflection.md`. It covers the design decisions, executed tests, technical problems, personal learning, limitations, and future improvements without presenting planned cloud or application features as completed work.

## References and AI-use declaration

- Database Sample. (2026). *Cryptocurrency Transaction Insights* [Synthetic dataset]. <https://databasesample.com/datasets/cryptocurrency-transaction-insights>  
- Oracle, *MySQL Reference Manual*: InnoDB transactions, locking and `EXPLAIN ANALYZE`. [Insert pages used.]  
- MongoDB, *MongoDB Manual*: embedded data models, aggregation and indexes. [Insert pages used.]  

**AI-use declaration.** AI was used to explain database concepts, help me understand MySQL errors, suggest corrections to SQL code, and clarify queries and execution plans that I found difficult to interpret. I ran the scripts myself, checked the results in MySQL Workbench and MongoDB Compass, captured the evidence, and reviewed the final documentation. I remain responsible for the work submitted and for explaining the decisions and results.
