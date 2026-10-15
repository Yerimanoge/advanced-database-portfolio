# advanced-database-portfolio
## Portfolio 1: Database Design and Modelling
- MIT 8103 Advanced Database System portfolio: Cryptocurrency wallet and transaction platform using MySQL
- crpytocurrency-transaction-insight-V3-sql-mysql.sql: this is the main database, it creates the database and loads the data
- 01-verify-row-counts.sql: this is a short verification script, checks all five tables loaded correctly
- The Screenshot [Akira verify row](portfolio-1-database-design/screenshots/01_row_counts.png), showing the result grid
### Case Study: Akira Cryptocurrency Platform
- Akira is a simulated cryptocurrency platform that allows customers to maintain digital wallets, monitor their wallet balances and track cryptocurrency transaction activity. The system uses a MySQL database to organize customer accounts and organize information about their wallets and associated transactions.
- The database is used by customers, system administrators and data analysts. It stores customer details, registration dates, device types and last access times, wallet balances and creation dates, wallet addresses, transaction amounts and timestamps.
- Key operations include registering customers, creating and managing wallet records, tracking device access, storing wallet addresses, retrieving transaction histories linked to individual wallets, checking recorded balances and generating reports, and transferring funds between wallets while updating the relevant balances.
#### Dataset source
-The dataset used for this project is cryptocurrency Transaction Insights, obtained from the Database Sample website. It contains synthetic data created for learning and practising database concepts. The Data is used to develop and demonstrate the Akira simulated cryptocurrency platform
##### Reference
- DatabaseSample. Cryptocurrency Transaction Insights. Database sample website. [https://databasesample.com/datasets/cryptocurrency-transaction-insights]. Accessed 13 October 2026
  
- app.diagrams.net was used to design the ER Diagram. portfolio-1-database-design\ER-DIAGRAM.png
- [Akira ER Diagram](portfolio-1-database-design/screenshots/ER-DIAGRAM.png)
- Schema exploration with 'DESCRIBE' on all 5 tables (users, wallets, devices, addresses, transactions)
- Foreign-key query (4 FKs identified)
### Problem solved
- MySQL error 1064 came from keeping the < > around a placeholder in DESCRIBE <table_name>. Removing the brackets fixed it. Git Bash failed to install, so I switched to GitHub Desktop for committing.
- Relationships: one user has many wallets and many devices. One wallet has many addresses and many transactions.
- Foreign keys: wallets.user_id and devices.user_id reference users.id. addresses.wallet_id and transactions.wallet_id reference wallets.id.
- Tools used: MySQL Server and Workbench, draw.io, GitHub Desktop.
