-- Akira | Portfolio 3 
USE crypto_fintech;

DROP PROCEDURE IF EXISTS sp_post_transaction;
DROP PROCEDURE IF EXISTS sp_reverse_transaction;

DELIMITER $$

CREATE PROCEDURE sp_post_transaction(
  IN p_sender_wallet_id INT,
  IN p_recipient_wallet_id INT,
  IN p_amount DECIMAL(14,6),
  IN p_type VARCHAR(20),
  OUT p_transaction_id INT,
  OUT p_result VARCHAR(40)
)
proc: BEGIN
  DECLARE v_sender_balance DECIMAL(14,6);
  DECLARE v_recipient_balance DECIMAL(14,6);
  DECLARE v_is_merchant INT DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_amount IS NULL OR p_amount <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be greater than zero';
  END IF;
  IF p_sender_wallet_id = p_recipient_wallet_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sender and recipient must differ';
  END IF;
  IF p_type IS NULL OR p_type NOT IN ('transfer', 'payment') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction type must be transfer or payment';
  END IF;

  START TRANSACTION;
  -- Lock in ID order. Every movement procedure follows this order to reduce deadlocks.
  SELECT id FROM wallets
  WHERE id IN (p_sender_wallet_id, p_recipient_wallet_id)
  ORDER BY id FOR UPDATE;

  SELECT balance INTO v_sender_balance FROM wallets WHERE id = p_sender_wallet_id;
  SELECT balance INTO v_recipient_balance FROM wallets WHERE id = p_recipient_wallet_id;
  IF v_sender_balance IS NULL OR v_recipient_balance IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sender or recipient wallet does not exist';
  END IF;

  IF p_type = 'payment' THEN
    SELECT COUNT(*) INTO v_is_merchant FROM merchants WHERE wallet_id = p_recipient_wallet_id;
    IF v_is_merchant = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment recipient must be a registered merchant wallet';
    END IF;
  END IF;

  IF v_sender_balance < p_amount THEN
    INSERT INTO transactions (wallet_id, to_wallet_id, amount, `timestamp`, `type`, `status`)
    VALUES (p_sender_wallet_id, p_recipient_wallet_id, p_amount, NOW(), p_type, 'failed');
    SET p_transaction_id = LAST_INSERT_ID();
    SET p_result = 'failed_insufficient_funds';
    COMMIT;
    LEAVE proc;
  END IF;

  INSERT INTO transactions (wallet_id, to_wallet_id, amount, `timestamp`, `type`, `status`)
  VALUES (p_sender_wallet_id, p_recipient_wallet_id, p_amount, NOW(), p_type, 'completed');
  SET p_transaction_id = LAST_INSERT_ID();

  UPDATE wallets SET balance = balance - p_amount WHERE id = p_sender_wallet_id;
  UPDATE wallets SET balance = balance + p_amount WHERE id = p_recipient_wallet_id;

  INSERT INTO ledger_entries (transaction_id, wallet_id, entry_kind, change_amount, balance_after, created_at)
  VALUES
    (p_transaction_id, p_sender_wallet_id, 'original', -p_amount, v_sender_balance - p_amount, NOW()),
    (p_transaction_id, p_recipient_wallet_id, 'original',  p_amount, v_recipient_balance + p_amount, NOW());

  SET p_result = 'completed';
  COMMIT;
END$$

CREATE PROCEDURE sp_reverse_transaction(
  IN p_transaction_id INT,
  OUT p_result VARCHAR(40)
)
proc: BEGIN
  DECLARE v_sender_wallet_id INT;
  DECLARE v_recipient_wallet_id INT;
  DECLARE v_amount DECIMAL(14,6);
  DECLARE v_status VARCHAR(20);
  DECLARE v_sender_balance DECIMAL(14,6);
  DECLARE v_recipient_balance DECIMAL(14,6);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT wallet_id, to_wallet_id, amount, `status`
  INTO v_sender_wallet_id, v_recipient_wallet_id, v_amount, v_status
  FROM transactions WHERE id = p_transaction_id FOR UPDATE;

  IF v_sender_wallet_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction does not exist';
  END IF;
  IF v_status <> 'completed' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only completed transactions can be reversed';
  END IF;

  SELECT id FROM wallets
  WHERE id IN (v_sender_wallet_id, v_recipient_wallet_id)
  ORDER BY id FOR UPDATE;
  SELECT balance INTO v_sender_balance FROM wallets WHERE id = v_sender_wallet_id;
  SELECT balance INTO v_recipient_balance FROM wallets WHERE id = v_recipient_wallet_id;

  IF v_recipient_balance < v_amount THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reversal refused: recipient no longer holds the amount';
  END IF;

  UPDATE wallets SET balance = balance + v_amount WHERE id = v_sender_wallet_id;
  UPDATE wallets SET balance = balance - v_amount WHERE id = v_recipient_wallet_id;
  UPDATE transactions SET `status` = 'reversed' WHERE id = p_transaction_id;

  INSERT INTO ledger_entries (transaction_id, wallet_id, entry_kind, change_amount, balance_after, created_at)
  VALUES
    (p_transaction_id, v_sender_wallet_id, 'reversal',  v_amount, v_sender_balance + v_amount, NOW()),
    (p_transaction_id, v_recipient_wallet_id, 'reversal', -v_amount, v_recipient_balance - v_amount, NOW());

  SET p_result = 'reversed';
  COMMIT;
END$$
DELIMITER ;
