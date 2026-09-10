-- Custom Baiak / war-system tables expected by data scripts

CREATE TABLE IF NOT EXISTS `z_shut` (
	`id` INT NOT NULL DEFAULT 1,
	`shutdown` INT NOT NULL DEFAULT 0,
	`long` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT IGNORE INTO `z_shut` (`id`, `shutdown`, `long`) VALUES (1, 0, 0);

CREATE TABLE IF NOT EXISTS `guild_wars` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`guild_id` INT NOT NULL,
	`enemy_id` INT NOT NULL,
	`begin` BIGINT NOT NULL DEFAULT 0,
	`end` BIGINT NOT NULL DEFAULT 0,
	`frags` INT UNSIGNED NOT NULL DEFAULT 0,
	`payment` BIGINT UNSIGNED NOT NULL DEFAULT 0,
	`guild_kills` INT UNSIGNED NOT NULL DEFAULT 0,
	`enemy_kills` INT UNSIGNED NOT NULL DEFAULT 0,
	`status` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	KEY `status` (`status`),
	KEY `guild_id` (`guild_id`),
	KEY `enemy_id` (`enemy_id`),
	FOREIGN KEY (`guild_id`) REFERENCES `guilds`(`id`) ON DELETE CASCADE,
	FOREIGN KEY (`enemy_id`) REFERENCES `guilds`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `guild_kills` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`guild_id` INT NOT NULL,
	`war_id` INT NOT NULL,
	`death_id` INT NOT NULL,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`guild_id`) REFERENCES `guilds`(`id`) ON DELETE CASCADE,
	FOREIGN KEY (`war_id`) REFERENCES `guild_wars`(`id`) ON DELETE CASCADE,
	FOREIGN KEY (`death_id`) REFERENCES `player_deaths`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Safe if already present
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'guilds' AND COLUMN_NAME = 'balance');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `guilds` ADD `balance` BIGINT UNSIGNED NOT NULL DEFAULT 0 AFTER `motd`', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'killers' AND COLUMN_NAME = 'war');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `killers` ADD `war` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;
