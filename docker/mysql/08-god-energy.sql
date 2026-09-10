-- God account from Baiak backup (account id 5 / characters), adapted for Docker seed.
-- Password: godadmin (SHA1). Admin character renamed to Energy (was [ADM] Socks).
-- Idempotent: safe on existing volumes via website ensure-schema / re-run.

-- Account
INSERT INTO `accounts` (`name`, `password`, `salt`, `premdays`, `lastday`, `email`, `key`, `blocked`, `warnings`, `group_id`)
SELECT 'god', 'f71b7292f983a6d019178863b061e95e7e757aa8', '', 65535, 0, '', '0', 0, 0, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `accounts` WHERE `name` = 'god');

UPDATE `accounts`
SET
  `password` = 'f71b7292f983a6d019178863b061e95e7e757aa8',
  `premdays` = 65535,
  `page_access` = 3,
  `flag` = 'unknown'
WHERE `name` = 'god';

-- Energy (ADM) — from backup [ADM] Socks on account god
INSERT INTO `players` (
  `name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`,
  `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`,
  `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`,
  `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `rank_id`, `guildnick`, `lastlogout`,
  `blessings`, `balance`, `stamina`, `direction`, `loss_experience`, `loss_mana`, `loss_skills`,
  `loss_containers`, `loss_items`, `premend`, `online`, `marriage`, `promotion`, `deleted`, `description`
)
SELECT
  'Energy', 0, 7, a.`id`, 845, 1,
  7003535, 7003535, 2147483647, 94, 94, 94, 94, 300, 3,
  0, 42020135, 42020135, 0, 100, 1, 155, 57, 6, '',
  14007099, 1, 0, 0, 1, 0, 0, 0, '', 0,
  31, 1000000, 151200000, 2, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, ''
FROM `accounts` a
WHERE a.`name` = 'god'
  AND NOT EXISTS (SELECT 1 FROM `players` p WHERE p.`name` = 'Energy');

-- Rename leftover backup name if present on god account
UPDATE `players` p
INNER JOIN `accounts` a ON a.`id` = p.`account_id` AND a.`name` = 'god'
SET p.`name` = 'Energy', p.`group_id` = 7
WHERE p.`name` = '[ADM] Socks';

INSERT INTO `players` (
  `name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`,
  `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`,
  `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`,
  `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `rank_id`, `guildnick`, `lastlogout`,
  `blessings`, `balance`, `stamina`, `direction`, `loss_experience`, `loss_mana`, `loss_skills`,
  `loss_containers`, `loss_items`, `premend`, `online`, `marriage`, `promotion`, `deleted`, `description`
)
SELECT
  'Test', 0, 1, a.`id`, 1, 0,
  150, 150, 0, 68, 76, 78, 39, 128, 0,
  0, 0, 0, 0, 100, 1, 155, 52, 7, '',
  400, 1, 0, 0, 1, 0, 0, 0, '', 0,
  0, 0, 151200000, 2, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, ''
FROM `accounts` a
WHERE a.`name` = 'god'
  AND NOT EXISTS (SELECT 1 FROM `players` p WHERE p.`name` = 'Test' AND p.`account_id` = a.`id`);

INSERT INTO `players` (
  `name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`,
  `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`,
  `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`,
  `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `rank_id`, `guildnick`, `lastlogout`,
  `blessings`, `balance`, `stamina`, `direction`, `loss_experience`, `loss_mana`, `loss_skills`,
  `loss_containers`, `loss_items`, `premend`, `online`, `marriage`, `promotion`, `deleted`, `description`
)
SELECT
  'Smartbox Test', 0, 1, a.`id`, 100, 1,
  11345, 11345, 15694800, 68, 76, 78, 39, 128, 0,
  104, 66995, 66995, 25642003, 100, 1, 155, 54, 7, '',
  22755, 1, 0, 0, 1, 0, 0, 0, '', 0,
  0, 0, 151200000, 2, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, ''
FROM `accounts` a
WHERE a.`name` = 'god'
  AND NOT EXISTS (SELECT 1 FROM `players` p WHERE p.`name` = 'Smartbox Test');

-- Default skills for Energy / Test / Smartbox Test when missing
INSERT INTO `player_skills` (`player_id`, `skillid`, `value`, `count`)
SELECT p.`id`, s.`skillid`, s.`value`, s.`count`
FROM `players` p
INNER JOIN `accounts` a ON a.`id` = p.`account_id` AND a.`name` = 'god'
CROSS JOIN (
  SELECT 0 AS skillid, 10 AS value, 0 AS count
  UNION ALL SELECT 1, 10, 0
  UNION ALL SELECT 2, 10, 0
  UNION ALL SELECT 3, 10, 0
  UNION ALL SELECT 4, 10, 0
  UNION ALL SELECT 5, 10, 0
  UNION ALL SELECT 6, 10, 0
) AS s
WHERE p.`name` IN ('Energy', 'Test', 'Smartbox Test')
  AND NOT EXISTS (
    SELECT 1 FROM `player_skills` ps
    WHERE ps.`player_id` = p.`id` AND ps.`skillid` = s.`skillid`
  );
