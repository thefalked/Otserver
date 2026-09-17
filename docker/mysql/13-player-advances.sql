-- Skill/level advance history for playeradvance.lua and Gesior character page.
-- Idempotent: safe on existing volumes via website ensure-schema / re-run.

CREATE TABLE IF NOT EXISTS `player_advances` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`cid` INT NOT NULL,
	`skill` INT NOT NULL,
	`oldlevel` INT NOT NULL,
	`newlevel` INT NOT NULL,
	`time` BIGINT NOT NULL,
	PRIMARY KEY (`id`),
	KEY `cid` (`cid`)
) ENGINE=InnoDB;
