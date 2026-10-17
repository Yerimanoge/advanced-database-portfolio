# advanced-database-portfolio
## Portfolio 1: Database Design and Modelling
- MIT 8103 Advanced Database System portfolio: Cryptocurrency wallet and transaction platform using MySQL
- crpytocurrency-transaction-insight-V3-sql-mysql.sql: this is the main database, it creates the database and loads the data
- 01-verify-row-counts.sql: this is a short verification script, checks all five tables loaded correctly
- The Screenshot [Akira verify row](portfolio-1-database-design/screenshots/01_row_counts.png), showing the result grid
### Case Study: Akira Cryptocurrency Platform
ORGANISATION: Akira is a simulated cryptocurrency platform.
WHAT THE SYSTEM DOES: Akira lets customers maintain digital wallets, monitor their wallet balances and track cryptocurrency transaction activity. Everything is stored in a MySQL database that links customer accounts and organize their wallets and associated transactions.

WHO USES THE DATABASE:
- Customers sign up, create wallets, check balances and history and send funds.
- System administrators look after wallet records keep an eye on devices access and run the platform day to day.
- Data analysts pulls reports on transaction volumes, wallet acttivity and how users behave.
MAIN DATA STORED:
- Customer details: name, email, registration dates.
- Device access: device types and last access times.
- Wallets: addresses, balances and creation dates,currency.
- Transactions: amount, timestamps and wallet involved.
- Ledger entries: a permanent record of every balance change.
WHAT THE DATABASE NEEDS TO DO:
- Registering customers and set up thier wallets.
- Record device access and login activities.
- Storing wallet addresses and pull up a wallets transaction history.
- Check balance and produce generating reports.
- Transferring funds between wallets while updating the relevant balances in a single transaction.
#### Dataset source
I used the synthetic project is cryptocurrency Transaction Insights, obtained from the Database Sample website. The Data is used to develop and demonstrate the Akira simulated cryptocurrency platform and reorganised it into a normalised relationship design.
##### Reference
- DatabaseSample. CRYPTOCURRENCY TRANSACTION INSIGHTS. database sample website. [https://databasesample.com/datasets/cryptocurrency-transaction-insights]. Accessed 13 October 2026.
  
- app.diagrams.net was used to design the ER Diagram. portfolio-1-database-design\ER-DIAGRAM.png
- [Akira ER Diagram](portfolio-1-database-design/er-diagram_akira-er-diagram.png)
- Schema exploration with 'DESCRIBE' on all 5 tables (users, wallets, devices, addresses, transactions)
- Foreign-key query (4 FKs identified)
### Problem solved
- MySQL error 1064 came from keeping the < > around a placeholder in DESCRIBE <table_name>. Removing the brackets fixed it. Git Bash failed to install, so I switched to GitHub Desktop for committing.
- Relationships: one user has many wallets and many devices. One wallet has many addresses and many transactions.
- Foreign keys: wallets.user_id and devices.user_id reference users.id. addresses.wallet_id and transactions.wallet_id reference wallets.id.
- Tools used: MySQL Server and Workbench, draw.io, GitHub Desktop.
