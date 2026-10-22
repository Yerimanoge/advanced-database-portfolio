-- Akira | Portfolio 1 | original-schema.sql

CREATE TABLE `users` (
    `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `username` varchar(36),
    `email` varchar(120),
    `created_at` date NOT NULL
);

CREATE TABLE `devices` (
    `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` int NOT NULL,
    `device_type` varchar(7) NOT NULL,
    `last_accessed` datetime
);

CREATE TABLE `wallets` (
    `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` int NOT NULL,
    `balance` decimal(14,6),
    `created_at` date NOT NULL
);

CREATE TABLE `addresses` (
    `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `wallet_id` int NOT NULL,
    `address` varchar(120)
);

CREATE TABLE `transactions` (
    `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `wallet_id` int NOT NULL,
    `amount` decimal(14,6),
    `timestamp` datetime NOT NULL
);

ALTER TABLE `devices`      ADD CONSTRAINT `fk_devices_user_id`        FOREIGN KEY (`user_id`)   REFERENCES `users` (`id`);
ALTER TABLE `wallets`      ADD CONSTRAINT `fk_wallets_user_id`        FOREIGN KEY (`user_id`)   REFERENCES `users` (`id`);
ALTER TABLE `addresses`    ADD CONSTRAINT `fk_addresses_wallet_id`    FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`);
ALTER TABLE `transactions` ADD CONSTRAINT `fk_transactions_wallet_id` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`);
