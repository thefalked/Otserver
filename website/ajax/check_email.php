<?php
// W10: session rate-limit + softer availability wording
session_start();

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

$ok = '/[a-zA-Z0-9._-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,4}/';
echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>';
if (!ajax_rate_limit('ajax_check_email')) {
  echo '<font color="red">Too many checks. Wait a minute and try again.</font>';
  exit();
}

$config['site_ini'] = parse_ini_file('../config/config.ini');
include '../parse_config_lua.php';
include '../config/config.php';
$email = trim($_REQUEST['email'] ?? '');
if (empty($email)) {
  echo '<font color="red">Por favor digite um e-mail.</font>';
  exit();
}
if (strlen($email) < 255) {
  if (preg_match($ok, $email)) {
    if ($config['site']['one_email']) {
      $server_config = parse_config_lua($config['site_ini']['server_path'] . 'config.lua');
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
        $ots->connect(POT::DB_SQLITE, ['database' => $config['site_ini']['server_path'] . $sqlitefile]);
      }
      $email_db = new OTS_Account();
      $email_db->findByEMail($email);
      if ($email_db->isLoaded()) {
        echo '<font color="red">Este e-mail não está disponível.</font>';
      } else {
        echo '<font color="green">Este e-mail está disponível.</font>';
      }
    } else {
      echo '<font color="green">Este e-mail está disponível.</font>';
    }
  } else {
    echo '<font color="red">Formato de e-mail incorreto.</font>';
  }
} else {
  echo '<font color="red">E-mail muito longo (máx. 255 caracteres).</font>';
}
