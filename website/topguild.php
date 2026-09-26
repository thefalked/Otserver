<?php $main_content .=
  '<div style="text-align: center; font-weight: bold;"><h2>Top 10 guilds Em ' .
  $config['server']['serverName'] .
  '</h2></div> 
<center><table border="0" cellspacing="1" cellpadding="4" width="80%"> 
    <tr bgcolor="' .
  $config['site']['vdarkborder'] .
  '"> 
        <td width="10%"><b><font color=white><center>Posição</font></center></b></td> 
        <td width="20%"><b><font color=white><center>Logo</center></b></font></td> 
        <td width="30%"><b><font color=white><center>Nome da Guild</center></b></font></td> 
        <td width="20%"><b><font color=white><center>Kills</center></b></font></td> 
    </tr>';
$i = 0;
foreach (
  $SQL->query('SELECT `g`.`id` AS `id`, `g`.`name` AS `name`,
    `g`.`logo_gfx_name` AS `logo`, COUNT(*) AS `frags`
    FROM `killers` k
    INNER JOIN `player_killers` pk ON `k`.`id` = `pk`.`kill_id`
    INNER JOIN `players` p ON `pk`.`player_id` = `p`.`id`
    INNER JOIN `guild_ranks` gr ON `p`.`rank_id` = `gr`.`id`
    INNER JOIN `guilds` g ON `gr`.`guild_id` = `g`.`id`
   WHERE `k`.`unjustified` = 1 AND `k`.`final_hit` = 1
    GROUP BY `g`.`id`, `g`.`name`, `g`.`logo_gfx_name`
    ORDER BY `frags` DESC, `g`.`name` ASC
    LIMIT 10')
  as $guild
) {
  $i++;
  $main_content .=
    '<tr bgcolor="' .
    (is_int($i / 2) ? $config['site']['lightborder'] : $config['site']['darkborder']) .
    '"> 
        <td>             
            <center>' .
    $i .
    '</center> 
        </td> 
        <td>             
            <center><img src="guilds/' .
    (!empty($guild['logo']) && file_exists('guilds/' . $guild['logo']) ? $guild['logo'] : 'default_logo.gif') .
    '" width="64" height="64" border="0"/></center> 
        </td> 
        <td> 
            <center><a href="?subtopic=guilds&action=show&guild=' .
    $guild['id'] .
    '">' .
    htmlspecialchars($guild['name']) .
    '</a></center> 
        </td> 
        <td> 
            <center>' .
    $guild['frags'] .
    ' kills</center> 
        </td> 
    </tr>';
}
if ($i === 0) {
  $main_content .=
    '<tr bgcolor="' .
    $config['site']['darkborder'] .
    '"><td colspan="4" style="text-align:center;">Nenhuma guilda com frags ainda.</td></tr>';
}
$main_content .= '</table><br />';
