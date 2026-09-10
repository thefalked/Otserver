<?php
/**
 * Idempotent schema / seed fixes for already-initialized MySQL volumes.
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

$files = [
	'/usr/local/share/otserver/07-lottery.sql',
	'/usr/local/share/otserver/08-god-energy.sql',
];

$dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";
$attempts = 15;
$last = null;

for ($i = 1; $i <= $attempts; $i++) {
	try {
		$pdo = new PDO($dsn, $user, $pass, [
			PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
			PDO::MYSQL_ATTR_MULTI_STATEMENTS => true,
		]);
		foreach ($files as $path) {
			if (!is_readable($path)) {
				fwrite(STDERR, "ensure-schema: missing {$path}, skipping file\n");
				continue;
			}
			$sql = file_get_contents($path);
			if ($sql === false || trim($sql) === '') {
				continue;
			}
			$pdo->exec($sql);
			fwrite(STDOUT, 'ensure-schema: applied ' . basename($path) . "\n");
		}
		exit(0);
	} catch (Throwable $e) {
		$last = $e;
		fwrite(STDERR, "ensure-schema: attempt {$i}/{$attempts}: " . $e->getMessage() . "\n");
		sleep(2);
	}
}

fwrite(STDERR, "ensure-schema: gave up: " . ($last ? $last->getMessage() : 'unknown') . "\n");
exit(0);
