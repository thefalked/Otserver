<?php if (PHP_VERSION_ID >= 70300) {
  $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || (int) ($_SERVER['SERVER_PORT'] ?? 0) === 443;
  session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'httponly' => true,
    'secure' => $https,
    'samesite' => 'Lax'
  ]);
}
session_start();
if (function_exists('ob_gzhandler')) {
  @ob_start('ob_gzhandler');
} else {
  ob_start();
}
//require('./exaBD.php');
function microtime_float()
{
  [$usec, $sec] = explode(' ', microtime());
  return (float) $usec + (float) $sec;
}
$time_start = microtime_float();

//##### CONFIG #####
include 'config-and-functions.php';
$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';

//##### LOGOUT #####
if ($action == 'logout') {
  unset($_SESSION['account']);
  unset($_SESSION['password']); // legacy key cleanup
}

//##### LOGIN #####
$logged = false;
$group_id_of_acc_logged = 0;
// A2: Gesior Account Manager (id 1 / name "1") stays for the game client only — never AAC session.
$account_manager_denied = false;
if (isset($_SESSION['account'])) {
  $account_logged = $ots->createObject('Account');
  $account_logged->load((int) $_SESSION['account']);
  if ($account_logged->isLoaded() && (int) $account_logged->getId() === 1) {
    unset($_SESSION['account']);
    unset($_SESSION['password']);
    unset($account_logged);
    $logged = false;
    $group_id_of_acc_logged = 0;
    $account_manager_denied = true;
  } elseif ($account_logged->isLoaded()) {
    $logged = true;
    $group_id_of_acc_logged = $account_logged->getPageAccess();
  } else {
    $logged = false;
    unset($_SESSION['account']);
    unset($account_logged);
  }
}
$login_account = isset($_POST['account_login']) ? strtoupper(trim($_POST['account_login'])) : '';
$login_password = isset($_POST['password_login']) ? trim($_POST['password_login']) : '';
if (!$logged && $login_account !== '' && $login_password !== '') {
  if (!csrf_ok()) {
    $logged = false;
  } elseif (!rate_limit('login', 15, 60)) {
    $logged = false;
  } else {
    $login_password_hash = password_ency($login_password);
    $account_logged = $ots->createObject('Account');
    $account_logged->find($login_account);
    if ($account_logged->isLoaded()) {
      if (hash_equals((string) $account_logged->getPassword(), (string) $login_password_hash)) {
        if ((int) $account_logged->getId() === 1) {
          // Password OK for game, but website login is blocked.
          unset($_SESSION['account']);
          unset($_SESSION['password']);
          $logged = false;
          $group_id_of_acc_logged = 0;
          $account_manager_denied = true;
          unset($account_logged);
        } else {
          session_regenerate_id(true);
          $_SESSION['account'] = $account_logged->getId();
          unset($_SESSION['password']);
          $logged = true;
          $account_logged->setCustomField('page_lastday', time());
          $group_id_of_acc_logged = $account_logged->getPageAccess();
        }
      } else {
        $logged = false;
      }
    }
  }
}

//#### LOAD PAGE ##########
// Canonical homepage is "/". Redirect explicit latestnews query to avoid duplicates.
if (
  isset($_GET['subtopic']) &&
  (string) $_GET['subtopic'] === 'latestnews' &&
  strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET')) === 'GET'
) {
  $seo_redirect_base = rtrim((string) ($config['site']['site_url'] ?? ''), '/');
  if ($seo_redirect_base !== '') {
    header('Location: ' . $seo_redirect_base . '/', true, 301);
    exit;
  }
}
if (empty($_REQUEST['subtopic'])) {
  $_REQUEST['subtopic'] = 'latestnews';
  $subtopic = 'latestnews';
}
$main_content = '';
$topic = '';
$subtopic = isset($_REQUEST['subtopic']) ? $_REQUEST['subtopic'] : 'latestnews';
switch ($_REQUEST['subtopic']) {
  case 'latestnews':
    $topic = 'Últimas notícias';
    $subtopic = 'latestnews';
    include 'latestnews.php';
    break;

  case 'lottery':
    $topic = 'Sistema de loteria';
    $subtopic = 'lottery';
    include 'lottery.php';
    break;

  case 'creatures':
    $topic = 'Criaturas';
    $subtopic = 'creatures';
    include 'creatures.php';
    break;

  case 'scrollnews':
    $topic = 'Notícias em rolagem';
    $subtopic = 'scrollnews';
    include 'scrollnews.php';
    break;

  case 'spells':
    $topic = 'Magias';
    $subtopic = 'spells';
    include 'spells.php';
    break;

  case 'bugtracker':
    $topic = 'Reportar bugs';
    $subtopic = 'bugtracker';
    include 'bug.php';
    break;

  case 'experiencetable':
    $topic = 'Tabela de experiência';
    $subtopic = 'experiencetable';
    include 'experiencetable.php';
    break;

  case 'characters':
    $topic = 'Personagens';
    $subtopic = 'characters';
    include 'characters.php';
    break;

  case 'whoisonline':
    $topic = 'Quem está online';
    $subtopic = 'whoisonline';
    include 'whoisonline.php';
    break;

  case 'highscores':
    $topic = 'Recordes';
    $subtopic = 'highscores';
    include 'highscores.php';
    break;

  case 'killstatistics':
    $topic = 'Últimas mortes';
    $subtopic = 'killstatistics';
    include 'killstatistics.php';
    break;

  case 'guilds':
    $topic = 'Guildas';
    $subtopic = 'guilds';
    include 'guilds.php';
    break;

  case 'frags':
    $topic = 'Top Frags';
    $subtopic = 'frags';
    include 'frags.php';
    break;

  case 'topguilds':
    $topic = 'Top guildas';
    $subtopic = 'topguilds';
    include 'topguild.php';
    break;

  case 'accountmanagement':
    $topic = 'Minha conta';
    $subtopic = 'accountmanagement';
    include 'accountmanagement.php';
    break;

  case 'createaccount':
    $topic = 'Criar conta';
    $subtopic = 'createaccount';
    include 'createaccount.php';
    break;

  case 'tibiarules':
    $topic = 'Regras do servidor';
    $subtopic = 'tibiarules';
    include 'tibiarules.php';
    break;

  case 'adminpanel':
    $topic = 'Painel admin';
    $subtopic = 'adminpanel';
    include 'adminpanel.php';
    break;

  case 'retpagseguro':
    include 'retpagseguro.php';
    exit();
    break;
    break;

  case 'vantagens':
    $topic = 'Vantagens';
    $subtopic = 'vantagens';
    include 'vantagens.php';
    break;

  case 'forum':
    $topic = 'Fórum';
    $subtopic = 'forum';
    include 'forum.php';
    break;

  case 'team':
    $subtopic = 'team';
    $topic = 'Suporte';
    include 'team.php';
    break;

  case 'downloads':
    $subtopic = 'downloads';
    $topic = 'Downloads';
    include 'downloads.php';
    break;

  case 'serverinfo':
    $subtopic = 'serverinfo';
    $topic = 'Info do servidor';
    include 'serverinfo.php';
    break;

  case 'shopsystem':
    $subtopic = 'shopsystem';
    $topic = 'Loja';
    include 'shopsystem.php';
    break;

  case 'donate':
    $subtopic = 'donate';
    $topic = 'Doar';
    include 'donate.php';
    break;

  case 'gallery':
    $subtopic = 'gallery';
    $topic = 'Galeria';
    include 'gallery.php';
    break;

  case 'namelock':
    $subtopic = 'namelock';
    $topic = 'Gerenciador de namelock';
    include 'namelocks.php';
    break;

  case 'archive':
    $subtopic = 'archive';
    $topic = 'Arquivo';
    include 'archive.php';
    break;

  case 'mail':
    $subtopic = 'mail';
    $topic = 'Envio de e-mails em massa';
    include 'mail.php';
    break;

  case 'shopadmin':
    $subtopic = 'shopadmin';
    $topic = 'Admin da loja';
    include 'shopadmin.php';
    break;

  case 'records':
    $subtopic = 'records';
    $topic = 'Recordes de jogadores online';
    include 'records.php';
    break;

  case 'bans':
    $subtopic = 'bans';
    $topic = 'Banimentos';
    include 'bans.php';
    break;

  case 'polls':
    $topic = 'Enquetes';
    $subtopic = 'polls';
    include 'polls.php';
    break;

  case 'changelog':
    $topic = 'Atualizações';
    $subtopic = 'changelog';
    include 'changelog.php';
    break;

  case 'fragers':
    $topic = 'Top Fraggers';
    $subtopic = 'fragers';
    include 'fragers.php';
    break;
  case 'war':
    $subtopic = 'war';
    $topic = 'Guerras de guildas';
    include 'war.php';
    break;
  case 'pag_retorno':
    $topic = 'Retorno PagSeguro';
    $subtopic = 'pag_retorno';
    include 'pag_retorno.php';
    exit();
    break;
}

if (empty($topic)) {
  $title = $GLOBALS['config']['server']['serverName'] . ' - OTS';
  $main_content .= 'Tópico inválido. Não foi possível carregar a página.';
} elseif ($subtopic === 'latestnews') {
  $title = $GLOBALS['config']['server']['serverName'] . ' - OTServer 8.60 Baiakzik Vip9';
} else {
  $title = $GLOBALS['config']['server']['serverName'] . ' - ' . $topic;
}

//#####LAYOUT#####
$layout_header = '<script type=\'text/javascript\'>
function GetXmlHttpObject()
{
var xmlHttp=null;
try
  {
  xmlHttp=new XMLHttpRequest();
  }
catch (e)
  {
  try
    {
    xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
    }
  catch (e)
    {
    xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
  }
return xmlHttp;
}

function MouseOverBigButton(source)
{
  source.firstChild.style.visibility = "visible";
}
function MouseOutBigButton(source)
{
  source.firstChild.style.visibility = "hidden";
}
function BigButtonAction(path)
{
  window.location = path;
}
var';
if ($logged) {
  $layout_header .= "loginStatus=1; loginStatus='true';";
} else {
  $layout_header .= "loginStatus=0; loginStatus='false';";
}
$layout_header .= " var activeSubmenuItem='" . $subtopic . "';</script>";
include $layout_name . '/layout.php';
ob_end_flush();
