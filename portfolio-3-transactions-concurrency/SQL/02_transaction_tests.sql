
USE crypto_fintech;

-- Choose a personal wallet with enough funds and a personal wallet belonging to another user.
SELECT id INTO @sender FROM wallets WHERE wallet_type = 'personal' AND balance >= 20 ORDER BY id LIMIT 1;
SELECT id INTO @recipient FROM wallets WHERE wallet_type = 'personal' AND id <> @sender ORDER BY id DESC LIMIT 1;
SELECT @sender AS sender_wallet, @recipient AS recipient_wallet;

SELECT id, balance FROM wallets WHERE id IN (@sender, @recipient) ORDER BY id;
CALL sp_post_transaction(@sender, @recipient, 10.00, 'transfer', @transaction_id, @result);
SELECT @transaction_id AS transaction_id, @result AS result;
SELECT * FROM transactions WHERE id = @transaction_id;
SELECT transaction_id, wallet_id, entry_kind, change_amount, balance_after FROM ledger_entries WHERE transaction_id = @transaction_id ORDER BY id;
SELECT id, balance FROM wallets WHERE id IN (@sender, @recipient) ORDER BY id;

-- Overdraft test: the procedure records a failed transaction but does not alter balances or ledger.
SELECT balance INTO @sender_before FROM wallets WHERE id = @sender;
CALL sp_post_transaction(@sender, @recipient, @sender_before + 1.00, 'transfer', @failed_transaction_id, @result);
SELECT @failed_transaction_id AS failed_transaction_id, @result AS result;
SELECT id, `status`, amount FROM transactions WHERE id = @failed_transaction_id;
SELECT COUNT(*) AS failed_transaction_ledger_rows_must_be_zero FROM ledger_entries WHERE transaction_id = @failed_transaction_id;
SELECT id, balance FROM wallets WHERE id IN (@sender, @recipient) ORDER BY id;

-- Reversal test. It returns the original amount and adds two reversal entries.
CALL sp_reverse_transaction(@transaction_id, @reversal_result);
SELECT @reversal_result AS reversal_result;
SELECT id, `status` FROM transactions WHERE id = @transaction_id;
SELECT transaction_id, wallet_id, entry_kind, change_amount, balance_after FROM ledger_entries WHERE transaction_id = @transaction_id ORDER BY id;
SELECT id, balance FROM wallets WHERE id IN (@sender, @recipient) ORDER BY id;



CALL sp_reverse_transaction(103, @second_reversal_result);


-- Audit after all tests. It must return no rows.

SELECT w.id, w.balance AS stored_balance,
       w.opening_balance + COALESCE(SUM(l.change_amount), 0) AS calculated_balance
FROM wallets AS w
LEFT JOIN ledger_entries AS l ON l.wallet_id = w.id
GROUP BY w.id, w.balance, w.opening_balance
HAVING w.balance <> w.opening_balance + COALESCE(SUM(l.change_amount), 0);
