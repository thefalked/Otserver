<?php
// W10: session rate-limit + softer availability wording
session_start();

function check_account_name($name)
{
  $temp = strspn("$name", 'QWERTYUIOPASDFGHJKLZXCVBNM0123456789');
  if ($temp != strlen($name)) {
    return false;
  }
  if (strlen($name) > 32) {
    return false;
  }
  return (bool) preg_match('/[A-Z0-9]/', $name);
}

function ajax_rate_limit($bucket, $max = 20, $window_sec = 60)
{
  $key = 'rl_' . $bucket;
  $now = time();
  if (!isset($_SESSION[$key]) || !is_array($_SESSION[$key])) {
    $_SESSION[$key] = [];
  }
  $_SESSION[$key] = array_values(
    array_filter($_SESSION[$key], function ($t) use ($now, $window_sec) {
      return $now - (int) $t < $window_sec;
    })
  );
  if (count($_SESSION[$key]) >= $max) {
    return false;
  }
  $_SESSION[$key][] = $now;
  return true;
}

echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>';
if (!ajax_rate_limit('ajax_check_account')) {
  echo '<font color="red">Too many checks. Wait a minute and try again.</font>';
  exit();
}

$config_ini = parse_ini_file('../config/config.ini');
include '../parse_config_lua.php';
$account = strtoupper(trim($_REQUEST['account'] ?? ''));
if (empty($account)) {
  echo '<font color="red">Por favor digite um nome de conta.</font>';
  exit();
}
if (strlen($account) > 0 && strlen($account) < 32) {
  if (!check_account_name($account)) {
    echo '<font color="red">Formato de nome de conta inválido. Use apenas A-Z e números 0-9.</font>';
    exit();
  }
  $server_config = parse_config_lua($config_ini['server_path'] . 'config.lua');
  if (isset($server_config['mysqlHost'])) {
    $mysqlhost = $server_config['mysqlHost'];
    $mysqluser = $server_config['mysqlUser'];
    $mysqlpass = $server_config['mysqlPass'];
    $mysqldatabase = $server_config['mysqlDatabase'];
    $sqlitefile = $server_config['sqliteDatabase'] ?? '';
  } elseif (isset($server_config['sqlHost'])) {
    $mysqlhost = $server_config['sqlHost'];
    $mysqluser = $server_config['sqlUser'];
    $mysqlpass = $server_config['sqlPass'];
    $mysqldatabase = $server_config['sqlDatabase'];
    $sqlitefile = $server_config['sqliteDatabase'] ?? '';
  }
  include '../pot/OTS.php';
  $ots = POT::getInstance();
  if ($server_config['sqlType'] == 'mysql') {
    $ots->connect(POT::DB_MYSQL, [
      'host' => $mysqlhost,
      'user' => $mysqluser,
      'password' => $mysqlpass,
      'database' => $mysqldatabase
    ]);
  } elseif ($server_config['sqlType'] == 'sqlite') {
    $ots->connect(POT::DB_SQLITE, ['database' => $config_ini['server_path'] . $sqlitefile]);
  }
  $account_db = new OTS_Account();
  $account_db->find($account);
  if ($account_db->isLoaded()) {
    echo '<font color="red">Este nome de conta não está disponível.</font>';
  } else {
    echo '<font color="green">Este nome de conta está disponível.</font>';
  }
} else {
  echo '<font color="red">Nome da conta muito longo (máx. 32 caracteres).</font>';
}
