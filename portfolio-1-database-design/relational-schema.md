# Portfolio 1: Database Design and Modelling (Akira)

> DRAFT written with AI assistance (see AI Use Declaration in the root README). Rewrite the explanations in your own words, and only keep what you can explain. Status of all SQL here: **specified, not yet executed** until you run it and attach your screenshots.

## 1. Case study
Akira is a fintech cryptocurrency platform where users hold wallets, send crypto to other users, and pay businesses that accept it. One currency unit is used throughout (no conversion, no multiple coin types). Users: regular users, merchants, data analysts. Data source: *Cryptocurrency Transaction Insights*, DatabaseSample, 2026 (synthetic, for learning), accessed 15 October 2026. Add the dataset page URL you used.

## 2. Original schema and its limitations
Original tables: users, wallets, devices, addresses, transactions (4 foreign keys). Limits for Akira:
- transactions had one wallet only: no sender and recipient, so no transfer could be represented.
- No transaction type or status, so payments, failures and reversals could not be recorded.
- No ledger and no merchants table.
- wallets.balance allowed NULL (26 of 152 wallets), so the no-overdraft rule could be bypassed.
- transactions.amount allowed NULL (31 of 343 rows).

## 3. Final relational schema
Keys: PK = primary key, FK = foreign key.

| Table | Columns |
|---|---|
| users | **id** PK, username, email (UNIQUE), created_at |
| devices | **id** PK, user_id FK→users, device_type, last_accessed |
| wallets | **id** PK, user_id FK→users, wallet_type (personal/merchant), opening_balance, balance, created_at; UNIQUE (id, user_id) |
| addresses | **id** PK, wallet_id FK→wallets, address |
| merchants | **id** PK, user_id FK→users UNIQUE, wallet_id UNIQUE, business_name UNIQUE, category; FK (wallet_id, user_id)→wallets (id, user_id) |
| transactions | **id** PK, wallet_id FK→wallets (**sender**), to_wallet_id FK→wallets (**recipient**), type (transfer/payment), status (pending/completed/failed/reversed), amount, timestamp |
| ledger_entries | **id** PK, transaction_id FK→transactions, wallet_id FK→wallets, entry_kind (original/reversal), change_amount (signed), balance_after, created_at; UNIQUE (transaction_id, wallet_id, entry_kind) |

All money columns are DECIMAL(14,6). No floating-point types.

**Relationships (for the draw.io ER diagram, redraw it to match):**
- users 1 — N wallets; users 1 — N devices; wallets 1 — N addresses
- users 1 — 0..1 merchants; merchants 1 — 1 wallets (its merchant wallet)
- wallets 1 — N transactions (as sender); wallets 1 — N transactions (as recipient)
- transactions 1 — N ledger_entries (2 original, plus 2 reversal if reversed); wallets 1 — N ledger_entries

## 4. Business rules
- **BR1 Single currency.** All amounts are in one unit.
- **BR2 Positive amounts.** amount > 0 (CHECK chk_txn_amount_positive).
- **BR3 No self-transfer.** Sender and recipient must differ (CHECK chk_txn_different_wallets).
- **BR4 Insufficient funds: a wallet cannot send more than its balance.** Enforced in two layers:
  1. Transfer procedure (Portfolio 3): lock the sender row with `SELECT ... FOR UPDATE`, compare balance with amount; if balance < amount, no balance or ledger change is made and the attempt is recorded as `failed`.
  2. Database safety net: CHECK chk_balance (balance >= 0) on wallets plus balance NOT NULL. Any debit below zero is rejected by MySQL and the whole transaction rolls back.
- **BR5 Merchant payments.** A payment's recipient wallet must appear in merchants.wallet_id (merchants is the authority; wallet_type is a convenience copy).
- **BR6 One merchant per user,** unique business name, enforced by UNIQUE keys.
- **BR7 Completed transaction = balanced ledger.** Two entries: sender change_amount = -amount, recipient = +amount, so the signed sum is 0.
- **BR8 Reversal keeps history.** Original rows are never deleted. A reversal adds two entries with entry_kind = 'reversal' (opposite signs) and sets the status to `reversed`. The UNIQUE key on (transaction, wallet, entry_kind) makes a second reversal impossible. Rule to confirm: a reversal is refused if the recipient no longer holds the amount.
- **BR9 Balance audit.** balance = opening_balance + SUM(change_amount). Differences are reported, never auto-corrected.

## 5. Keys, constraints and referential integrity
Every FK points at a primary key, so no orphan rows are possible. Optional attributes (username, email, address, last_accessed) stay nullable because the dataset has gaps; everything the money rules depend on is NOT NULL. Composite FK merchants(wallet_id, user_id)→wallets(id, user_id) stops a merchant being linked to someone else's wallet.

## 6. Normalisation
- 1NF: every column holds one atomic value; each table has a primary key.
- 2NF: all keys are single-column (the UNIQUE composite keys are constraints, not the PK), so no partial dependencies.
- 3NF: non-key columns depend only on the key. Example: a merchant's category lives in merchants, not repeated on every transaction; user details live in users, not in wallets.
- **Intentional denormalisation** (document these in your reflection):
  1. wallets.balance can be computed from opening_balance and the ledger, but is stored for fast reads and for the overdraft CHECK. The audit proves they agree.
  2. ledger_entries.balance_after is a running-balance snapshot used for statements and audit.
  3. wallets.wallet_type duplicates what the merchants table already says; kept for simple filtering.

## 7. Data provenance (copy into the README)
| Data | Origin |
|---|---|
| users, devices, wallets, addresses | Original dataset |
| NULL balances set to 0; opening_balance | Derived from the original data |
| 5 merchants, their business names and categories, 5 merchant wallets | **Generated** for this project |
| transactions and ledger_entries | **Generated** (seed script comes at the start of Portfolio 2); the 343 original transactions were removed from the working database, and remain in the original .sql file |

## 8. Changes made and why
See sql/01 to 03. Every change maps to a rule above; nothing was added that the case study does not need.

## 9. Known limitations
- Single currency only; no external blockchain; not a production financial system.
- ALTER TABLE statements commit automatically in MySQL, so the scripts are meant to run once, after a backup.
- Your database was loaded from the file named v3 (the tab name); email is already UNIQUE there. State in the README which dataset version you used.

## 10. Evidence to capture yourself
Screenshots of 00_pre_checks output, 04_validation V1 to V6, and the four failing statements in V7 (the error messages are the evidence).
