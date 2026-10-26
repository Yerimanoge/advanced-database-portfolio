# Portfolio 4: NoSQL and Advanced Data Models

## Chosen model: MongoDB document database

Akira keeps balances, transfers and merchant payments in MySQL because the relational ledger needs foreign keys, ACID transactions and exact balance checks. MongoDB is used here for a separate read-oriented wallet activity view. Each `wallet_activity` document embeds a bounded list of recent transaction events for one wallet, so a mobile application can render a wallet statement with one document lookup.

This is not the authoritative balance ledger. MySQL remains the source of truth, and the document is a derived projection. That avoids relying on MongoDB embedded events to enforce the no-overdraft rule.

## Files

- `mongodb/01_create_and_seed.js`: creates sample Akira wallet documents and indexes.
- `mongodb/02_queries.js`: demonstrates wallet statement, merchant-payment and analyst queries.
- `mongodb/03_validation.js`: checks embedded-event structure and index definitions.

The scripts were run successfully in MongoDB Compass `mongosh` against the local `akira` connection. They created the `akira_nosql` database and two `wallet_activity` documents. The completed evidence demonstrates:

- `countDocuments()` returned `2`.
- A wallet `101` lookup returned its balance and embedded recent events.
- The wallet-statement aggregation returned the two events in newest-first order.
- The merchant aggregation returned `Groceries`, one completed payment, totalling `8.500000` AKR.
- `explain('executionStats')` showed the `uq_wallet_activity_wallet` index for the wallet lookup.
- The missing embedded-event-fields validation returned no documents.
- `getIndexes()` returned `_id_`, `uq_wallet_activity_wallet`, `idx_recent_event_time`, and `idx_merchant_category_status`.

Keep screenshots of those commands and results in `Evidence/`. The seed values are generated examples that mirror the Akira model; they do not claim to have imported a live MySQL database.

## Evidence map

| Evidence file | What it proves |
|---|---|
| `p4_01_seed-documents-and-indexes.png` | The seed script created the two embedded wallet documents and completed the three named index creations. |
| `p4_02_document-count-two.png` | `countDocuments()` returned `2`. |
| `p4_03_wallet-lookup.png` | The wallet `101` lookup returns its balance and embedded event array. |
| `p4_04a_wallet-statement-command-and-newest-event.png` | The wallet-statement aggregation, including the pipeline and newest event first. |
| `p4_04b_wallet-statement-second-event.png` | The same statement's remaining transfer event, proving both embedded events were returned. |
| `p4_05_merchant-payment-aggregation.png` | The merchant aggregation returned `Groceries`, one completed payment, total `8.500000` AKR. |
| `p4_06a_index-explain-command.png` | The `executionStats` explain request for the indexed wallet lookup. |
| `p4_06b_index-explain-index-scan.png` | MongoDB used `EXPRESS_IXSCAN` with `uq_wallet_activity_wallet`; one key and one document were examined. |
| `p4_07_embedded-event-fields-validation-empty.png` | The validation pipeline executed and returned no malformed embedded events. |
| `p4_08_index-list.png` | The collection has `_id_`, `uq_wallet_activity_wallet`, `idx_recent_event_time`, and `idx_merchant_category_status`. |
| `p4_09_compass-documents-interface.png` | MongoDB Compass's Documents interface shows the live `akira_nosql.wallet_activity` collection with both wallet documents and their embedded activity arrays. |

## Suitability and limits

The document model suits fast per-wallet reads because events used together are stored together. Embedding is deliberately bounded to recent events; an unbounded transaction history would create continually growing documents and should instead be stored in a separate collection or retrieved from MySQL. Cross-wallet transfer posting and balance enforcement remain better suited to the MySQL procedures in Portfolio 3.
