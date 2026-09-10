<?php
$main_content = "<h1 align=\"center\">Guild Wars</h1>
<script type=\"text/javascript\"><!--
function show_hide(flip)
{
var tmp = document.getElementById(flip);
if(tmp)
tmp.style.display = tmp.style.display == 'none' ? '' : 'none';
}
--></script>
</table>

<table width=\"100%\" border=\"0\" cellpadding=\"3\" cellspacing=\"1\">

<tr bgcolor=\"#512e0b\"><td width=\"40%\"><strong><font color=white>Commandos</font></strong></td><td><strong><font color=white>Descricao</font></strong></td></tr>
<tr style=\"background: #512e0b;\"><td align=\"center\" class=\"white\"><b>Comandos</b></td><td colspan=\"2\" align=\"center\" class=\"white\"><b>Descrição</b></td></tr>
<tr style=\"background: #F1E0C6;\"><td><b>/war invite, nome da guild, limite de frags</b></td><td>Envia um convite para iniciar a guerra. Exemplo: <font color=red><BR>/war invite, Chickens, 150<BR></font><B>(Convida a guilda para a war com contagem de 150 frags)</B></td></tr>
<tr style=\"background: #D4C0A1;\"><td><b>/war invite, nome da guild, limite de frags, dinheiro</b></td><td>Send the invitation to start the war. Example: <font color=red><BR>/war invite, Chickens, 150, 10000</font><br><B> (Convida a guilda para a war com contagem de 150 frags e pagamento de 10000 moedas de ouro <- você precisa doar o dinheiro para a guilda)<B></td></tr>
<tr style=\"background: #F1E0C6;\"><td><b>/war accept, nome da guild</b></td><td>Aceita o Convite para iniciar a War. Exemplo: <font color=red><BR>/war accept, Chickens</font><BR><B>(Aceita a War Contra \"Chickens\".)</b></td></tr>

<tr style=\"background: #D4C0A1;\"><td><b>/war reject, nome da guild</b></td><td>Rejeita o Convite para iniciar a War Exemplo: <font color=red><BR>/war reject, Chickens</font><BR><B>(Rejeita o Convite de Chickens.)</B></td></tr>
<tr style=\"background: #F1E0C6;\"><td><b>/war cancel, nome da guild</b></td><td>Cancela o Convite. Exemplo: <font color=red><BR>/war cancel, Chickens</font><br><b>(Cancela o Convite da Sua guilda contra Chickens.)</b></td></tr>
<tr style=\"background: #D4C0A1;\"><td><b>/balance</b></td><td><B>Mostra o Dinheiro da Guild<B></td></tr>
<tr style=\"background: #F1E0C6;\"><td><b>/balance donate value</b></td><td>Deposita o dinheiro na conta do banco da guilda. Todos os players podem doar. Exemplo: <font color=red><BR>/balance donate 100000 </font><BR><B>(Você doou 100k para o banco da guilda.)</B></td></tr>
<tr style=\"background: #D4C0A1;\"><td><b>/balance pick value</b></td><td>Retira o dinheiro da conta da guilda. Somente o líder pode usar o comando. Exemplo: <font color=red><BR>/balance pick 100000 </font><BR><B>(Você pegou 100k do banco da guilda.)</B></td></tr>
</table>
<table width=\"100%\" border=\"0\" cellspacing=\"1\" cellpadding=\"4\">
<tr>
<td style=\"background: #512e0b\" class=\"white\" width=\"150\"><b>Aggressor</b></td>

<td style=\"background: #512e0b\" class=\"white\"><b>Estatisticas</b></td>
<td style=\"background: #512e0b\" class=\"white\" width=\"150\"><b>Inimigo</b></td>
</tr><tr style=\"background: #512e0b;\">";
$count = 0;
foreach($SQL->query('SELECT * FROM `guild_wars` WHERE `status` IN (1,4) OR ((`end` >= (UNIX_TIMESTAMP() - 604800) OR `end` = 0) AND `status` IN (0,5));') as $war)
{
$a = $ots->createObject('Guild');
$a->load($war['guild_id']);
if(!$a->isLoaded())
continue;
$e = $ots->createObject('Guild');
$e->load($war['enemy_id']);
if(!$e->isLoaded())
continue;
$alogo = $a->getCustomField('logo_gfx_name');
if(empty($alogo) || !file_exists('guilds/' . $alogo))
$alogo = 'default_logo.gif';
$elogo = $e->getCustomField('logo_gfx_name');
if(empty($elogo) || !file_exists('guilds/' . $elogo))
$elogo = 'default_logo.gif';
$count++;
$main_content .= "<tr style=\"background: " . (is_int($count / 2) ? $config['site']['darkborder'] : $config['site']['lightborder']) . ";\">
<td align=\"center\"><a href=\"?subtopic=guilds&action=show&guild=".$a->getId()."\"><img src=\"guilds/".$alogo."\" width=\"64\" height=\"64\" border=\"0\"/><br />".$a->getName()."</a></td>
<td class=\"white\" align=\"center\">";
switch($war['status'])
{
case 0:
{
$main_content .= "<b>Convite pendente</b><br />Convidado em " . date("M d Y, H:i:s", $war['begin']) . " de " . ($war['end'] > 0 ? (($war['end'] - $war['begin']) / 86400) : "unspecified") . " dias. O limite de frags é " . $war['frags'] . " frags, " . ($war['payment'] > 0 ? "com pagamento de " . $war['payment'] . " bronze coins." : "sem qualquer pagamento.")."<br />Expirará em três dias.";
break;
}
case 3:
{
$main_content .= "<s>Convite Cancelado</s><br />Enviado convite em " . date("M d Y, H:i:s", $war['begin']) . ", Cancelado Em " . date("M d Y, H:i:s", $war['end']) . ".";
break;
}
case 2:
{
$main_content .= "Convite Rejeitado<br />Convidado Em " . date("M d Y, H:i:s", $war['begin']) . ", Rejeitado Em " . date("M d Y, H:i:s", $war['end']) . ".";
break;
}
case 1:
{
$main_content .= "<font size=\"12\"><span style=\"color: red;\">" . $war['guild_kills'] . "</span><span style=\"color: #5A2800;\"> : </span><span style=\"color: lime;\">" . $war['enemy_kills'] . "</span></font><br /><br /><span style=\"color: #5A2800; font-weight: bold;\">A guerra começou em " . date("d M Y, H:i:s", $war['begin']) . ($war['end'] > 0 ? ", acabará em " . date("d M Y, H:i:s", $war['end']) : "") . ".<br />O limite de frags é de " . $war['frags'] . " frags<br /> " . ($war['payment'] > 0 ? "com pagamento de " . $war['payment'] . " bronze coins." : "Não foi definido pagamento para os ganhadores.</span>");
break;
}
case 4:
{
$main_content .= "<font size=\"12\"><span style=\"color: red;\">" . $war['guild_kills'] . "</span> : <span style=\"color: lime;\">" . $war['enemy_kills'] . "</span></font><br /><br /><span style=\"color: darkred;\">Fim Pendente</span><br />Começa Em " . date("d M Y, H:i:s", $war['begin']) . ", signed armstice on " . date("d M Y, H:i:s", $war['end']) . ".<br />Expirará depois de alcançar " . $war['frags'] . " frags. ".($war['payment'] > 0 ? "O Pagamento é de " . $war['payment'] . " bronze coins." : "Não há pagamento definido.");
break;
}
case 5:
{
$main_content .= "<i>Terminou</i><br /><span style=\"color: black;Começa Em " . date("d M Y, H:i:s", $war['begin']) . ", Termina Em " . date("d M Y, H:i:s", $war['end']) . ". Estatistica de Frags: <span style=\"color: red;\">" . $war['guild_kills'] . "</span> Para <span style=\"color: lime;\">" . $war['enemy_kills'] . "</span>.";
break;
}
default:
{
$main_content .= "Desconhecido, entre em contato com gamemaster.";
break;
}
}
$main_content .= "<br /><br /><a onclick=\"show_hide('war-details:" . $war['id'] . "'); return false;\" style=\"cursor: pointer;\">&raquo; Details &laquo;</a></td>
<td align=\"center\"><a href=\"?subtopic=guilds&action=show&guild=".$e->getId()."\"><img src=\"guilds/".$elogo."\" width=\"64\" height=\"64\" border=\"0\"/><br />".$e->getName()."</a></td>
</tr>
<tr id=\"war-details:" . $war['id'] . "\" style=\"display: none; background: " . (is_int($count / 2) ? $config['site']['darkborder'] : $config['site']['lightborder']) . ";\">
<td colspan=\"3\">";
if(in_array($war['status'], array(1,4,5)))
{
$deaths = $SQL->query('SELECT `pd`.`id`, `pd`.`date`, `gk`.`guild_id` AS `enemy`, `p`.`name`, `pd`.`level`
FROM `guild_kills` gk
LEFT JOIN `player_deaths` pd ON `gk`.`death_id` = `pd`.`id`
LEFT JOIN `players` p ON `pd`.`player_id` = `p`.`id`
WHERE `gk`.`war_id` = ' . $war['id'] . ' AND `p`.`deleted` = 0
ORDER BY `pd`.`date` DESC')->fetchAll();
if(!empty($deaths))
{
foreach($deaths as $death)
{
$killers = $SQL->query('SELECT `p`.`name` AS `player_name`, `p`.`deleted` AS `player_exists`, `k`.`war` AS `is_war`
FROM `killers` k
LEFT JOIN `player_killers` pk ON `k`.`id` = `pk`.`kill_id`
LEFT JOIN `players` p ON `p`.`id` = `pk`.`player_id`
WHERE `k`.`death_id` = ' . $death['id'] . '
ORDER BY `k`.`final_hit` DESC, `k`.`id` ASC')->fetchAll();
$count = count($killers); $i = 0;
$others = false;
$main_content .= date("j M Y, H:i", $death['date']) . " <span style=\"font-weight: bold; color: " . ($death['enemy'] == $war['guild_id'] ? "red" : "lime") . ";\">+</span>
<a href=\"/characters/" . urlencode($death['name']) . "\"><b>".$death['name']."</b></a> ";
foreach($killers as $killer)
{
$i++;
if($killer['is_war'] != 0)
{
if($i == 1)
$main_content .= "Morto no level <b>".$death['level']."</b> Por ";
else if($i == $count && $others == false)
$main_content .= " e Por ";
else
$main_content .= ", ";
if($killer['player_exists'] == 0)
$main_content .= "<a href=\"/characters/".urlencode($killer['player_name'])."\">";
$main_content .= $killer['player_name'];
if($killer['player_exists'] == 0)
$main_content .= "</a>";
}
else
$others = true;
if($i == $count)
{
if($others == true)
$main_content .= " e Alguns Outros";
$main_content .= ".<br />";
}
}
}
}
else
$main_content .= "<center>Não houve frags nesta guerra até agora.</center>";
}
else
$main_content .= "<center>Esta war não começou ainda.</center>";
$main_content .= "</td>
</tr>";
}
if($count == 0)
$main_content .= "<tr style=\"background: ".$config['site']['darkborder'].";\">
<td colspan=\"3\">Não tem wars ativas no momento.</td>
</tr>";
$main_content .= "</table>";
?>