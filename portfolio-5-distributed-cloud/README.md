# Portfolio 5: Distributed and Cloud Database Exercise

## Akira deployment proposal

Akira's authoritative relational database is MySQL/InnoDB. A practical cloud design uses one writable primary instance in a single region, one or more asynchronous read replicas, automated backups with point-in-time recovery, private networking, encrypted storage and secrets managed outside the application source code. The primary is the only writer for transfers, payments and reversals; this preserves the single serial order needed by the balance and ledger procedures.

```text
wallet application --> primary MySQL (writes and balance reads)
analytics/reporting --> read replica (eventually consistent reads)
backups/PITR      --> encrypted object storage
```

## Replication, availability and consistency

Replication improves reporting capacity and recovery options, but an asynchronous replica can lag. A customer must therefore read a balance or immediate transfer result from the primary after a write. Analytics that tolerate a slightly older view can use a replica. Automatic failover improves availability, but the application must reconnect and should use an idempotency key before retrying a write so a network timeout cannot create a duplicate money movement.

For a balance-changing workflow, Akira chooses consistency over writing in two regions at once. MySQL row locks, transactions and the ledger are the source of truth. During a regional outage, a replica can be promoted according to the provider runbook, after assessing replication lag and recovery point objective. This design accepts a short interruption and a possible small recovery-point gap in exchange for avoiding conflicting balances.

## Local-server baseline evidence

The current development server is one writable local MySQL instance, not a configured cloud replica topology. On 26 October 2026, the read-only evidence showed `read_only = false`, `REPEATABLE-READ` isolation, MySQL version `26.7.0`, `log_bin = ON`, and `server_id = 1`. Binary logging and a stable server ID are prerequisites for a replication design, but this evidence does **not** claim that a replica or automatic failover has been configured.

`SHOW REPLICA STATUS` returned zero rows, confirming this local instance is not currently a replica. `SHOW BINARY LOG STATUS` returned the active file `DESKTOP-ABB36V8-bin.000006`, position `5434022`, and an executed GTID set. In a production setup, these replication coordinates would be managed by the cloud provider or used when initializing a new replica; they are recorded here as configuration evidence only.

| Evidence file | What it proves |
|---|---|
| `Evidence/p5_01_primary-server-role-and-isolation.png` | The server is writable (`read_only = false`) and reports `REPEATABLE-READ` isolation. |
| `Evidence/p5_02_binary-logging-enabled.png` | Binary logging is enabled (`log_bin = ON`). |
| `Evidence/p5_03_server-id.png` | The local instance has `server_id = 1`. |
| `Evidence/p5_04_evidence-capture-time.png` | The configuration evidence was captured on 26 October 2026. |
| `Evidence/p5_05_no-replica-configured.png` | `SHOW REPLICA STATUS` returned zero rows, confirming no local replica is configured. |
| `Evidence/p5_06_binary-log-file-position-and-gtid.png` | The active binary-log file, position, and executed GTID set were available for replication initialisation. |
| `Evidence/p5_07_replication-observations-script-server-baseline.png` | The saved `01_replication_observations.sql` file returned the writable-server and isolation baseline. |
| `Evidence/p5_08_replication-observations-script-capture-time.png` | The saved observation script returned its capture timestamp. |

## Sharding decision

Do not shard the current small Akira dataset. If scale later requires it, shard by a stable account or wallet-home key so a wallet's balance and most ledger events remain in one shard. Transfers between wallets on different shards require distributed coordination or a compensating workflow; for financial correctness, keep an authoritative transfer ledger and a unique idempotency key. Merchant/category reporting should use a replica, warehouse or precomputed aggregate rather than cross-shard operational joins.

## Optional MySQL evidence

`SQL/01_replication_observations.sql` is a read-only evidence template. Run it only on a server where replication or a managed replica is configured; it does not configure production replication. Capture the output and describe the actual provider, region, replica lag and backup settings used. If no cloud account is available, submit this design discussion and clearly label it as a proposed deployment, as allowed by the brief's “discussion or setup” wording.
