# MIT 8103 Advanced Database Systems: Portfolio

**Case study:** Akira, a simulated cryptocurrency wallet and transaction platform
**Database:** MySQL (Server and Workbench 26.7)

## Portfolio 1: Database Design and Modelling

### Files in this repository

- `Dataset.sql` (repository root): the original Cryptocurrency Transaction Insights script. It creates the `crypto_fintech` database and loads the data. I haven't edited it. All my changes to the schema are in separate scripts in the portfolio folders.
- `README.md` (repository root): this file.
- `portfolio-1-database-design/01-verify-row-counts.sql`: a short script that checks all five original tables loaded correctly.
- [Row count screenshot](https://github.com/Yerimanoge/advanced-database-portfolio/blob/main/portfolio-1-database-design/screenshots/01_row_counts.png): the result grid from the verification script.
- [Akira ER diagram](https://github.com/Yerimanoge/advanced-database-portfolio/blob/main/portfolio-1-database-design/er-diagram_akira-er-diagram.png): drawn in draw.io (app.diagrams.net).


### Case study: Akira

**Organisation:** Akira is a simulated cryptocurrency platform.

**What the system does:** Akira lets customers hold digital wallets, monitor their balances and track their transaction activity. Everything is stored in a MySQL database that links customer accounts to their wallets and the transactions on those wallets.

**Who uses the database:**

- **Customers** sign up, create wallets, check balances and history, and send funds.
- **System administrators** look after wallet records, keep an eye on device access and run the platform day to day.
- **Data analysts** pull reports on transaction volumes, wallet activity and user behaviour.

**Main data stored:**

- Customer details: username, email and registration date.
- Device access: device types and last access times.
- Wallets: balances and creation dates.
- Addresses: the addresses attached to each wallet.
- Transactions: amount, timestamp and the wallets involved.
- Ledger entries: a permanent record of every balance change.

**What the database needs to do:**

- Register customers and set up their wallets.
- Record device access and login activity.
- Store wallet addresses and retrieve a wallet's transaction history.
- Check balances and produce reports.
- Transfer funds between wallets, updating both balances in a single transaction.

### Dataset source

The data comes from the synthetic *Cryptocurrency Transaction Insights* dataset on the Database Sample website. I used it as the starting point for Akira and reorganised it into a normalised relational design.

**Reference:** DatabaseSample (2026) *Cryptocurrency Transaction Insights*. Available at: https://databasesample.com/datasets/cryptocurrency-transaction-insights (Accessed: 15 October 2026).

### Schema exploration

I ran `DESCRIBE` on all five tables (users, wallets, devices, addresses, transactions) and queried the foreign keys, which found four.

- One user has many wallets and many devices.
- One wallet has many addresses and many transactions.
- `wallets.user_id` and `devices.user_id` reference `users.id`.
- `addresses.wallet_id` and `transactions.wallet_id` reference `wallets.id`.
- Screenshots 08 and 10 show the results of the V4 and V6 checks in `SQL/04_validation.sql`. Both returned 0 rows, which is what I expected, because it means the check found nothing wrong.

### Problems I ran into

- **MySQL error 1064:** I typed `DESCRIBE <table_name>` and kept the angle brackets around the table name. Removing them fixed it.
- **Git Bash:** the install failed, so I used GitHub Desktop to commit instead.

### Tools used

MySQL Server and Workbench, draw.io, GitHub Desktop.
