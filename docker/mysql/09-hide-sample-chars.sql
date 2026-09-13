-- Hide Gesior vocation Sample templates from the login charlist (account 1/1).
-- Rows stay in DB so website character creation can still clone them.
-- Idempotent: safe on existing volumes via website ensure-schema / re-run.

UPDATE `players`
SET `deleted` = 1
WHERE `name` IN ('Rook Sample', 'Sorcerer Sample', 'Druid Sample', 'Paladin Sample', 'Knight Sample')
  AND `deleted` = 0;
