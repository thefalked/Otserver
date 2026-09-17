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
  '/usr/local/share/otserver/06-gesior-player-cols.sql',
  '/usr/local/share/otserver/07-lottery.sql',
  '/usr/local/share/otserver/08-god-energy.sql',
  '/usr/local/share/otserver/09-hide-sample-chars.sql',
  '/usr/local/share/otserver/10-a2-account-manager.sql',
  '/usr/local/share/otserver/11-gesior-created.sql',
  '/usr/local/share/otserver/12-news-utf8mb4.sql',
  '/usr/local/share/otserver/13-player-advances.sql',
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
    break;
  } catch (Throwable $e) {
    $last = $e;
    fwrite(STDERR, "ensure-schema: connect attempt {$i}/{$attempts}: " . $e->getMessage() . "\n");
    if ($i === $attempts) {
      fwrite(STDERR, "ensure-schema: gave up connecting: " . $e->getMessage() . "\n");
      exit(0);
    }
    sleep(2);
  }
}

foreach ($files as $path) {
  if (!is_readable($path)) {
    fwrite(STDERR, "ensure-schema: missing {$path}, skipping file\n");
    continue;
  }
  $sql = file_get_contents($path);
  if ($sql === false || trim($sql) === '') {
    continue;
  }
  try {
    $pdo->exec($sql);
    fwrite(STDOUT, 'ensure-schema: applied ' . basename($path) . "\n");
  } catch (Throwable $e) {
    fwrite(STDERR, 'ensure-schema: ' . basename($path) . ': ' . $e->getMessage() . "\n");
  }
}

exit(0);
