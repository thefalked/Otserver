<?php
// W2: admin ACL + POST + CSRF (no GET mutations)
if ($logged && $account_logged->getPageAccess() >= $config['site']['access_admin_panel']) {
  if (!empty($action) && ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    csrf_require();
    $name = trim((string) ($_POST['name'] ?? ''));
    $name_new = trim((string) ($_POST['name_new'] ?? ''));
    $player = new OTS_Player();
    $player->find($name);
    if ($player->isLoaded() && $player->isNameLocked()) {
      if ($name_new == $player->getOldName()) {
        if ($action == 'accept') {
          $main_content .=
            '<font color="green">Changed name from <b>' .
            h($player->getName()) .
            '</b> to <b>' .
            h($player->getOldName()) .
            '</b>.</font>';
          $player->setCustomField('old_name', $player->getName());
          $player->setCustomField('name', $player->getOldName());
          $player->setCustomField('nick_verify', 1);
          $player->removeNameLock();
        } elseif ($action == 'reject') {
          $main_content .=
            '<font color="green">Rejected proposition of change name from <b>' .
            h($player->getName()) .
            '</b> to <b>' .
            h($player->getOldName()) .
            '</b>.</font>';
          $player->setCustomField('old_name', '');
        }
      } else {
        $main_content .= '<font color="red">Invalid new name. Try again.</font><br>';
      }
    } else {
      $main_content .= '<font color="red">Player with this name doesn\'t exist or isn\'t namelocked.</font><br>';
    }
  } elseif (!empty($action)) {
    $main_content .= '<font color="red">Use the Accept/Reject buttons (POST required).</font><br>';
  }
  $main_content .= '<h2>First 50 namelocked players</h2>';
  $main_content .=
    '<table><tr bgcolor="' .
    $config['site']['vdarkborder'] .
    '"><td><font color="white"><b>- New nick proposition -</b></font></td><td><font color="white"><b>- ACCEPT -</b></font></td><td><font color="white"><b>- REJECT -</b></font></td></tr>';
  $number_of_rows = 1;
  $players_info = $SQL->query(
    "SELECT `players`.`name`, `players`.`old_name` AS `name_new` FROM `bans`, `players` WHERE `players`.`old_name` != '' AND `bans`.`value` = `players`.`id` AND `bans`.`active` = 1"
  );
  foreach ($players_info->fetchAll() as $player) {
    if (is_int($number_of_rows / 2)) {
      $bgcolor = $config['site']['darkborder'];
    } else {
      $bgcolor = $config['site']['lightborder'];
    }
    $number_of_rows++;
    $main_content .=
      '<tr bgcolor="' .
      $bgcolor .
      '"><td>' .
      h($player['name_new']) .
      '</td><td><form style="display:inline" method="post" action="?subtopic=namelock&action=accept">' .
      csrf_field() .
      '<input type="hidden" name="name" value="' .
      h($player['name']) .
      '"><input type="hidden" name="name_new" value="' .
      h($player['name_new']) .
      '"><button type="submit" style="background:none;border:none;padding:0;color:green;cursor:pointer;font:inherit"><font color="green">Accept</font></button></form></td><td><form style="display:inline" method="post" action="?subtopic=namelock&action=reject">' .
      csrf_field() .
      '<input type="hidden" name="name" value="' .
      h($player['name']) .
      '"><input type="hidden" name="name_new" value="' .
      h($player['name_new']) .
      '"><button type="submit" style="background:none;border:none;padding:0;color:red;cursor:pointer;font:inherit"><font color="red">Reject</font></button></form></td></tr>';
  }
  $main_content .= '</TABLE>';
} else {
  $main_content .= 'You are not logged or you dont have access to this site.';
}
?>
