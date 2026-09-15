<?php

/** Status protocol helpers (same counts as TFS status.cpp / otservlist). */

function otserver_status_port(array $server): int
{
  $port = (int) ($server['statusPort'] ?? 0);
  if ($port <= 0) {
    $port = (int) ($server['loginPort'] ?? 7171);
  }
  return $port;
}

function otserver_status_request_packet(bool $withPlayers = false): string
{
  $body = chr(255) . chr(255) . 'info';
  if ($withPlayers) {
    $body .= chr(1);
  }
  return chr(strlen($body)) . chr(0) . $body;
}

function otserver_status_roster_from_xml(string $data): array
{
  if (!preg_match('/<players[^>]*>([^<]*)<\/players>/s', $data, $m)) {
    return [];
  }
  $roster = [];
  foreach (explode(';', trim($m[1])) as $entry) {
    if ($entry === '') {
      continue;
    }
    $parts = explode(',', $entry, 3);
    if (count($parts) < 3) {
      continue;
    }
    $roster[] = [
      'name' => $parts[0],
      'vocation' => (int) $parts[1],
      'level' => (int) $parts[2],
      'promotion' => 0,
    ];
  }
  return $roster;
}

function otserver_status_fetch(string $host, int $port, bool $withPlayers = true): ?array
{
  $sock = @fsockopen($host, $port, $errno, $errstr, 1);
  if (!$sock) {
    return null;
  }
  fwrite($sock, otserver_status_request_packet($withPlayers));
  $data = '';
  while (!feof($sock)) {
    $chunk = fgets($sock, 10000000);
    if ($chunk === false) {
      break;
    }
    $data .= $chunk;
  }
  fclose($sock);
  if ($data === '' || !preg_match('/players online="(\d+)" max="(\d+)"/', $data, $playersMatch)) {
    return null;
  }
  $uptime = 0;
  if (preg_match('/uptime="(\d+)"/', $data, $uptimeMatch)) {
    $uptime = (int) $uptimeMatch[1];
  }
  $monsters = 0;
  if (preg_match('/monsters total="(\d+)"/', $data, $monstersMatch)) {
    $monsters = (int) $monstersMatch[1];
  }
  return [
    'players' => (int) $playersMatch[1],
    'max' => (int) $playersMatch[2],
    'uptime' => $uptime,
    'monsters' => $monsters,
    'roster' => otserver_status_roster_from_xml($data),
    'raw' => $data,
  ];
}

function otserver_status_roster_decode(?string $encoded): array
{
  if ($encoded === null || $encoded === '') {
    return [];
  }
  $json = base64_decode($encoded, true);
  if ($json === false || $json === '') {
    $json = $encoded;
  }
  $decoded = json_decode($json, true);
  return is_array($decoded) ? $decoded : [];
}
