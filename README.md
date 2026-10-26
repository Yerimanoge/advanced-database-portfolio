# MIT 8103 Advanced Database Systems: Portfolio

**Case study:** Akira, a fintech cryptocurrency wallet and transaction platform  
**Database:** MySQL Community Server and Workbench 26.7.0; MongoDB Community Server 9.0.4 and MongoDB Compass

## Portfolio 1: Database Design and Modelling

### Files in this repository

- `Dataset.sql` (repository root): the original *Cryptocurrency Transaction Insights* script. It creates the `crypto_fintech` database and loads the source data. I haven't edited it. All my changes to the schema are in separate scripts in the portfolio folders.
- `README.md` (repository root): this file.
- `portfolio-1-database-design/01-verify-row-counts.sql`: a short script that checks all five original tables loaded correctly, the numbered migration, backup and validation scripts.
- [Row count screenshot](https://github.com/Yerimanoge/advanced-database-portfolio/blob/main/portfolio-1-database-design/screenshots/01_row_counts.png): the result grid from the verification script.
- `portfolio-1-database-design/er-diagram_akira-er-diagram.drawio` and `.png`: the Akira ER diagram drawn in draw.io.
- `portfolio-2-query-optimisation/`: query, execution-plan, indexing and performance-test work.
- `portfolio-3-transactions-concurrency/`: stored procedures, transaction tests, reversal tests and two-session locking evidence.
- `portfolio-4-nosql/`: MongoDB wallet activity document model, queries, validation and Compass evidence.
- `portfolio-5-distributed-cloud/`: local replication baseline evidence and proposed cloud deployment design.
- `final-documentation.md` and `personal-reflection.md`: final project summary and individual reflection.

### Case study: Akira

**Organisation:** Akira is a simulated cryptocurrency platform.

**What the system does:** Akira lets customers hold digital wallets, monitor balances, track transaction activity, transfer cryptocurrency to other customers, and pay registered merchants. Everything is stored in a MySQL database that links customer accounts to their wallets and the transactions on those wallets. MongoDB is used for a separate read-focused wallet activity view.

**Who uses the database:**

- **Customers**sign up, create wallets, check balances and history, send funds, and make merchant payments.
- **System administrators**maintain wallet records, review device access, and manage the database environment.
- **Data analysts**  produce reports on transaction volumes, wallet activity, merchant payments, reversals and failed transactions.

**Main data stored:**

- Customer details: username, email and registration date.
- Device access: device types and last access times.
- Wallets: balances, current balances and creation dates.
- Addresses: the addresses attached to each wallet.
- Transactions:sender and recipient wallets, amount, timestamp, type and status.
- Ledger entries: a permanent record of every balance change and reversal.
- Merchants: merchant users, business names, categories and merchant wallets.

**What the database needs to do:**

- Register customers and set up their wallets.
- Record device access and login activity.
- Store wallet addresses and retrieve a wallet's transaction history.
- Check balances and produce reports.
- Transfer funds between wallets, updating both balances and matching ledger entries in one transaction.
- Record failed overdraft attempts without changing balances or ledger entries.
- Reverse a completed transaction without deleting its original audit history.
  
### Dataset source

The data comes from the synthetic *Cryptocurrency Transaction Insights* dataset on the Database Sample website. I used it as the starting point for Akira and reorganised it into a normalised relational design.
Merchant, transaction and ledger data created for the Akira business rules are clearly labelled as generated project data.

**Reference:** DatabaseSample (2026) *Cryptocurrency Transaction Insights*. Available at: https://databasesample.com/datasets/cryptocurrency-transaction-insights (Accessed: 15 October 2026).

### Schema exploration

I ran `DESCRIBE` on all five tables (users, wallets, devices, addresses, transactions) and queried the foreign keys, which found four original dataset.

- One user has many wallets and many devices.
- One wallet has many addresses and many transactions.
- `wallets.user_id` and `devices.user_id` reference `users.id`.
- `addresses.wallet_id` and `transactions.wallet_id` reference `wallets.id`.
- The final Akira design adds merchants, sender and recipient wallet relationships, statuses, transaction types and ledger entries.
- Validation checks confirmed no NULL wallet balances and a balance audit with no discrepancies after the tested transaction workflows.
- 
### Problems I ran into

- **MySQL error 1064:** I typed `DESCRIBE <table_name>` and kept the angle brackets around the table name. Removing them fixed it.
- **MySQL error 1832:** a schema change did not complete as expected. I kept the recovery work in `02b_transactions_ledger_continue.sql`, then ran the validation checks again.
- **Concurrency testing:** opening another query tab did not create a separate database session. I opened two Root Local connections, confirmed separate connection IDs, and then reproduced the intended lock wait between the sessions.
- **Git Bash:** the install failed, so I used GitHub Desktop to commit instead.

### Tools used

MySQL Server and Workbench, MongoDB Community Server, MongoDB Compass and `mongosh`, draw.io, GitHub Desktop.

## Portfolio 2: Query Processing and Optimisation

I seeded and validated 100 deterministic Akira transactions and ledger rows, then ran operational and analytical queries using joins, grouping, subqueries and window functions. I inspected real-table plans and ran a separate 200,000-row performance test to measure index effects. Four targeted indexes improved the reversed-transfer aggregation from 219 ms to 21.3 ms, the weekly date-range query from 156 ms to 22.3 ms, and the completed merchant-payment query from 500 ms to 167 ms. The supporting SQL, plans, measured results and analysis are in `portfolio-2-query-optimisation/`.

## Portfolio 3: Transactions and Concurrency

I created and tested `sp_post_transaction` and `sp_reverse_transaction`. Completed transfers update both wallet balances and insert matching ledger entries in one transaction. An overdraft attempt is recorded as `failed` with no balance or ledger change. The reversal procedure keeps the original history, adds opposite ledger entries and rejects a second reversal. A two-session test demonstrated row locking: Session B received a lock-wait timeout while Session A held the wallet lock. The final balance audit returned zero discrepancy rows. Evidence and SQL are in `portfolio-3-transactions-concurrency/`.

## Portfolio 4: NoSQL and Advanced Data Models

I created the `akira_nosql.wallet_activity` collection in MongoDB. Each document represents one wallet and contains its current balance with a bounded array of recent transaction events. I tested a wallet lookup, a newest-first wallet statement aggregation, merchant-payment aggregation and indexed lookup using `explain('executionStats')`. MongoDB Compass shows the two created wallet documents in the Documents interface. MongoDB is a read-focused projection; MySQL remains the authoritative ledger and balance database. Evidence and scripts are in `portfolio-4-nosql/`.

## Portfolio 5: Distributed and Cloud Database Exercise

I recorded a read-only baseline for the local MySQL server. It is writable (`read_only = false`), uses `REPEATABLE-READ` isolation, has binary logging enabled and has `server_id = 1`. `SHOW REPLICA STATUS` returned no rows, so no local replica is configured. `SHOW BINARY LOG STATUS` showed an active binary-log file, position and GTID set. Based on this baseline, I documented a proposed deployment with one writable primary for financial changes, asynchronous read replicas for reporting, encrypted backups with point-in-time recovery, and primary reads after a balance-changing write. This is a documented design proposal, not a deployed cloud topology. Evidence and design notes are in `portfolio-5-distributed-cloud/`.

## Final documentation

`final-documentation.md` summarises the completed portfolios, data provenance, environment and references. `personal-reflection.md` records my individual reflection on the design decisions, testing, challenges, limitations and future improvements.

## AI assistance

AI was used to explain database concepts, help me understand MySQL errors, suggest corrections to SQL code, clarify queries and execution plans that I found difficult to interpret. I ran the scripts myself, checked the results in MySQL Workbench and MongoDB Compass, captured the evidence, and reviewed the final documentation. I remain responsible for the work submitted and for explaining the decisions and results.

