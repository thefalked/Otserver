<?php
/**
 * Idempotent schema fixes for already-initialized MySQL volumes.
 * docker-entrypoint-initdb.d only runs on first volume create.
 */
declare(strict_types=1);

$host = getenv('MYSQL_HOST') ?: 'mysql';
$port = getenv('MYSQL_PORT') ?: '3306';
$db = getenv('MYSQL_DATABASE') ?: '';
$user = getenv('MYSQL_USER') ?: '';
$pass = getenv('MYSQL_PASSWORD') ?: '';

if ($db === '' || $user === '') {
	fwrite(STDERR, "ensure-schema: MYSQL_DATABASE/MYSQL_USER not set, skipping\n");
	exit(0);
}

$dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";
$sql = <<<'SQL'
CREATE TABLE IF NOT EXISTS `lottery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `item` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
SQL;

$attempts = 15;
$last = null;
for ($i = 1; $i <= $attempts; $i++) {
	try {
		$pdo = new PDO($dsn, $user, $pass, [
			PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
		]);
		$pdo->exec($sql);
		fwrite(STDOUT, "ensure-schema: lottery table ready\n");
		exit(0);
	} catch (Throwable $e) {
		$last = $e;
		fwrite(STDERR, "ensure-schema: attempt {$i}/{$attempts}: " . $e->getMessage() . "\n");
		sleep(2);
	}
}

fwrite(STDERR, "ensure-schema: gave up: " . ($last ? $last->getMessage() : 'unknown') . "\n");
exit(0); // do not block Apache; PHP pages still guard missing tables
