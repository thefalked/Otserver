-- Match website/install.php: ADD accounts.created / players.created
-- (03-gesior historically only added create_date; backfill from it when present)

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'created');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `created` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'created');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `players` ADD `created` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'create_date');
SET @sqlstmt := IF(@exist > 0, 'UPDATE `accounts` SET `created` = `create_date` WHERE `created` = 0 AND `create_date` > 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'create_date');
SET @sqlstmt := IF(@exist > 0, 'UPDATE `players` SET `created` = `create_date` WHERE `created` = 0 AND `create_date` > 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;
