-- A2: Account Manager must not have Gesior page_access (website admin menus).
-- Game client login 1/1 unchanged. Idempotent for ensure-schema.
UPDATE `accounts` SET `page_access` = 0 WHERE (`name` = '1' OR `id` = 1) AND `page_access` <> 0;
