-- Gesior AAC columns/tables from TIBIA.rar (GesiorACC 2012 + Tabelas Gesior)
-- Idempotent where possible for an already-initialized volume.

-- accounts extras
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'page_lastday');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `page_lastday` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'email_new');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `email_new` VARCHAR(255) NOT NULL DEFAULT ""', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'email_new_time');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `email_new_time` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'rlname');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `rlname` VARCHAR(255) NOT NULL DEFAULT ""', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'location');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `location` VARCHAR(255) NOT NULL DEFAULT ""', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'page_access');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `page_access` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'email_code');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `email_code` VARCHAR(255) NOT NULL DEFAULT ""', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'next_email');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `next_email` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'premium_points');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `premium_points` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'create_date');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `create_date` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'create_ip');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `create_ip` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'last_post');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `last_post` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'flag');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `flag` VARCHAR(80) NOT NULL DEFAULT ""', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'guild_points');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `guild_points` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'vip_time');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `vip_time` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'accounts' AND COLUMN_NAME = 'vote');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `accounts` ADD `vote` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- players extras
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'comment');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `players` ADD `comment` TEXT NULL', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'create_ip');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `players` ADD `create_ip` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'create_date');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `players` ADD `create_date` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'hide_char');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `players` ADD `hide_char` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'signature');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `players` ADD `signature` TEXT NULL', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- guild extras
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'guilds' AND COLUMN_NAME = 'description');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `guilds` ADD `description` TEXT NULL', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'guilds' AND COLUMN_NAME = 'guild_logo');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `guilds` ADD `guild_logo` MEDIUMBLOB NULL', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'guilds' AND COLUMN_NAME = 'create_ip');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `guilds` ADD `create_ip` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'guilds' AND COLUMN_NAME = 'balance');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `guilds` ADD `balance` BIGINT UNSIGNED NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'killers' AND COLUMN_NAME = 'war');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `killers` ADD `war` INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `z_ots_comunication` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  `param1` varchar(255) NOT NULL,
  `param2` varchar(255) NOT NULL,
  `param3` varchar(255) NOT NULL,
  `param4` varchar(255) NOT NULL,
  `param5` varchar(255) NOT NULL,
  `param6` varchar(255) NOT NULL,
  `param7` varchar(255) NOT NULL,
  `delete_it` int(2) NOT NULL default '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_ots_guildcomunication` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  `param1` varchar(255) NOT NULL,
  `param2` varchar(255) NOT NULL,
  `param3` varchar(255) NOT NULL,
  `param4` varchar(255) NOT NULL,
  `param5` varchar(255) NOT NULL,
  `param6` varchar(255) NOT NULL,
  `param7` varchar(255) NOT NULL,
  `delete_it` int(2) NOT NULL default '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_shop_offer` (
  `id` int(11) NOT NULL auto_increment,
  `points` int(11) NOT NULL default '0',
  `itemid1` int(11) NOT NULL default '0',
  `count1` int(11) NOT NULL default '0',
  `itemid2` int(11) NOT NULL default '0',
  `count2` int(11) NOT NULL default '0',
  `offer_type` varchar(255) default NULL,
  `offer_description` text NOT NULL,
  `offer_name` varchar(255) NOT NULL,
  `pid` int(11) NOT NULL default '0',
  `category` int(11) NOT NULL default '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_shop_history_pacc` (
  `id` int(11) NOT NULL auto_increment,
  `to_name` varchar(255) NOT NULL default '0',
  `to_account` int(11) NOT NULL default '0',
  `from_nick` varchar(255) NOT NULL,
  `from_account` int(11) NOT NULL default '0',
  `price` int(11) NOT NULL default '0',
  `pacc_days` int(11) NOT NULL default '0',
  `trans_state` varchar(255) NOT NULL,
  `trans_start` int(11) NOT NULL default '0',
  `trans_real` int(11) NOT NULL default '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_shop_history_item` (
  `id` int(11) NOT NULL auto_increment,
  `to_name` varchar(255) NOT NULL default '0',
  `to_account` int(11) NOT NULL default '0',
  `from_nick` varchar(255) NOT NULL,
  `from_account` int(11) NOT NULL default '0',
  `price` int(11) NOT NULL default '0',
  `offer_id` varchar(255) NOT NULL default '',
  `trans_state` varchar(255) NOT NULL,
  `trans_start` int(11) NOT NULL default '0',
  `trans_real` int(11) NOT NULL default '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_forum` (
  `id` int(11) NOT NULL auto_increment,
  `sticky` tinyint(1) NOT NULL default '0',
  `closed` tinyint(1) NOT NULL default '0',
  `first_post` int(11) NOT NULL default '0',
  `last_post` int(11) NOT NULL default '0',
  `section` int(3) NOT NULL default '0',
  `icon_id` int(3) NOT NULL default '1',
  `replies` int(20) NOT NULL default '0',
  `views` int(20) NOT NULL default '0',
  `author_aid` int(20) NOT NULL default '0',
  `author_guid` int(20) NOT NULL default '0',
  `post_text` text NOT NULL,
  `post_topic` varchar(255) NOT NULL,
  `post_smile` tinyint(1) NOT NULL default '0',
  `post_date` int(20) NOT NULL default '0',
  `last_edit_aid` int(20) NOT NULL default '0',
  `edit_date` int(20) NOT NULL default '0',
  `post_ip` varchar(15) NOT NULL default '0.0.0.0',
  PRIMARY KEY (`id`),
  KEY `section` (`section`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_news_tickers` (
  `date` int(11) NOT NULL DEFAULT '1',
  `author` int(11) NOT NULL,
  `image_id` int(3) NOT NULL DEFAULT '0',
  `text` text NOT NULL,
  `hide_ticker` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `auction_system` (
  `id` int(11) NOT NULL auto_increment,
  `player` int(11) default NULL,
  `item_id` int(11) default NULL,
  `item_name` varchar(255) default NULL,
  `count` int(11) default NULL,
  `cost` int(11) default NULL,
  `date` int(11) default NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Move Account Manager to Baiak temple coords from TIBIA.rar schema
UPDATE `players` SET `posx` = 32360, `posy` = 31782, `posz` = 7, `town_id` = 1 WHERE `name` = 'Account Manager';

// A2: Account Manager (name/id 1) is for the game client only — no AAC admin.
UPDATE `accounts` SET `page_access` = 0, `flag` = 'unknown' WHERE `name` = '1' OR `id` = 1;

-- Sample vocation templates for website character creation (cloned by Gesior).
-- deleted=1 keeps them off the account 1/1 login charlist; OTS_Player::find still loads them.
INSERT INTO `players` (
  `name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`,
  `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`,
  `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`,
  `cap`, `sex`, `save`, `stamina`, `loss_experience`, `loss_mana`, `loss_skills`, `loss_containers`, `loss_items`, `deleted`, `description`
)
SELECT
  v.name, 0, 1, 1, 1, v.voc,
  150, 150, 0, 0, 0, 0, 0, 128, 0,
  0, 0, 0, 0, 0, 1, 32360, 31782, 7, '',
  400, 0, 1, 201660000, 100, 100, 100, 100, 100, 1, ''
FROM (
  SELECT 'Rook Sample' AS name, 0 AS voc
  UNION ALL SELECT 'Sorcerer Sample', 1
  UNION ALL SELECT 'Druid Sample', 2
  UNION ALL SELECT 'Paladin Sample', 3
  UNION ALL SELECT 'Knight Sample', 4
) AS v
WHERE NOT EXISTS (SELECT 1 FROM `players` p WHERE p.name = v.name);

UPDATE `players`
SET `deleted` = 1
WHERE `name` IN ('Rook Sample', 'Sorcerer Sample', 'Druid Sample', 'Paladin Sample', 'Knight Sample')
  AND `deleted` = 0;

CREATE TABLE IF NOT EXISTS `z_featured_article` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) NOT NULL,
  `text` varchar(255) NOT NULL,
  `date` varchar(30) NOT NULL,
  `author` varchar(50) NOT NULL,
  `read_more` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_polls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `end` int(11) NOT NULL,
  `start` int(11) NOT NULL,
  `answers` int(11) NOT NULL,
  `votes_all` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_polls_answers` (
  `poll_id` int(11) NOT NULL,
  `answer_id` int(11) NOT NULL,
  `answer` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_network_box` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `network_name` varchar(10) NOT NULL,
  `network_link` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_shopguild_offer` (
  `id` int(11) NOT NULL auto_increment,
  `points` int(11) NOT NULL default '0',
  `itemid1` int(11) NOT NULL default '0',
  `count1` int(11) NOT NULL default '0',
  `itemid2` int(11) NOT NULL default '0',
  `count2` int(11) NOT NULL default '0',
  `offer_type` varchar(255) default NULL,
  `offer_description` text NOT NULL,
  `offer_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_spells` (
  `name` VARCHAR(255) NOT NULL,
  `spell` VARCHAR(255) NOT NULL,
  `spell_type` VARCHAR(255) NOT NULL,
  `mana` INTEGER NOT NULL DEFAULT 0,
  `lvl` INTEGER NOT NULL DEFAULT 0,
  `mlvl` INTEGER NOT NULL DEFAULT 0,
  `soul` INTEGER NOT NULL DEFAULT 0,
  `pacc` VARCHAR(255) NOT NULL,
  `vocations` VARCHAR(255) NOT NULL,
  `conj_count` INTEGER NOT NULL DEFAULT 0,
  `hide_spell` INTEGER NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_monsters` (
  `hide_creature` tinyint(1) NOT NULL default '0',
  `name` varchar(255) NOT NULL,
  `mana` int(11) NOT NULL,
  `exp` int(11) NOT NULL,
  `health` int(11) NOT NULL,
  `speed_lvl` int(11) NOT NULL default '1',
  `use_haste` tinyint(1) NOT NULL,
  `voices` text NOT NULL,
  `immunities` varchar(255) NOT NULL,
  `summonable` tinyint(1) NOT NULL,
  `convinceable` tinyint(1) NOT NULL,
  `race` varchar(255) NOT NULL,
  `gfx_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `z_changelog` (
  `id` int(11) NOT NULL auto_increment,
  `type` varchar(255) NOT NULL default '',
  `where` varchar(255) NOT NULL default '',
  `date` int(11) NOT NULL default '0',
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'guilds' AND COLUMN_NAME = 'logo_gfx_name');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE `guilds` ADD `logo_gfx_name` VARCHAR(255) NOT NULL DEFAULT ""', 'SELECT 1');
PREPARE stmt FROM @sqlstmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `z_bug_tracker` (
  `account` varchar(255) NOT NULL,
  `type` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `text` text NOT NULL,
  `id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `priority` int(11) NOT NULL,
  `reply` int(11) NOT NULL,
  `who` int(11) NOT NULL,
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `tag` int(11) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Used by website latestnews/lottery + server data/globalevents/scripts/lottery.lua
CREATE TABLE IF NOT EXISTS `lottery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `item` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
