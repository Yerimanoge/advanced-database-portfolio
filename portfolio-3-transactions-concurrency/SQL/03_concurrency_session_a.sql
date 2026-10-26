
USE crypto_fintech;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation AS isolation_level;

SELECT id INTO @sender FROM wallets WHERE wallet_type = 'personal' AND balance >= 20 ORDER BY id LIMIT 1;
SELECT id INTO @recipient FROM wallets WHERE wallet_type = 'personal' AND id <> @sender ORDER BY id DESC LIMIT 1;
SELECT @sender AS sender_wallet, @recipient AS recipient_wallet;

START TRANSACTION;
SELECT balance INTO @sender_balance FROM wallets WHERE id = @sender FOR UPDATE;
SELECT balance INTO @recipient_balance FROM wallets WHERE id = @recipient FOR UPDATE;



SET @amount = 10.00;
INSERT INTO transactions (wallet_id, to_wallet_id, amount, `timestamp`, `type`, `status`)
VALUES (@sender, @recipient, @amount, NOW(), 'transfer', 'completed');
SET @transaction_id = LAST_INSERT_ID();
UPDATE wallets SET balance = balance - @amount WHERE id = @sender;
UPDATE wallets SET balance = balance + @amount WHERE id = @recipient;
INSERT INTO ledger_entries (transaction_id, wallet_id, entry_kind, change_amount, balance_after, created_at)
VALUES (@transaction_id, @sender, 'original', -@amount, @sender_balance - @amount, NOW()),
       (@transaction_id, @recipient, 'original',  @amount, @recipient_balance + @amount, NOW());
COMMIT;
SELECT id, balance FROM wallets WHERE id IN (@sender, @recipient) ORDER BY id;
