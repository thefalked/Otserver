-- Kept for manual repair / docs. Prefer website container startup:
--   docker/ensure-schema.php (CREATE TABLE IF NOT EXISTS via website entrypoint)
-- Fresh MySQL volumes also get this from 03-gesior.sql.
CREATE TABLE IF NOT EXISTS `lottery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `item` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
