-- Session B: replace the two values with the IDs printed by Session A, then run while A is open.
USE crypto_fintech;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation AS isolation_level;
SELECT CONNECTION_ID() AS connection_id;

SET @sender = [paste_sender_wallet_id];
SET @recipient = [paste_recipient_wallet_id];

-- This waits until Session A commits because it asks for the same row lock.
START TRANSACTION;
SELECT id, balance FROM wallets WHERE id = @sender FOR UPDATE;
SELECT id, balance FROM wallets WHERE id = @sender;
ROLLBACK;

-- After Session A commits, this attempts to spend the sender's remaining balance plus 1.00.
-- Expected: a failed transaction, proving Session B reads the committed balance rather than over-drawing.
SELECT balance INTO @current_balance FROM wallets WHERE id = @sender;
CALL sp_post_transaction(@sender, @recipient, @current_balance + 1.00, 'transfer', @transaction_id, @result);
SELECT @transaction_id AS transaction_id, @result AS result;
