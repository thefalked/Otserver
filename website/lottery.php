<?PHP
$lottery = $SQL->query('SELECT id, name, item FROM lottery ORDER BY id DESC LIMIT 1;');
foreach($lottery as $result) {
$main_content .= '<center><h1>Lottery</h1></center>
<center>Cada 30 Minutos, Um jogador aleatorio vai ganhar item aleatorio!<br/>
Ultimo Ganhador: <a href="?subtopic=characters&name='.urlencode($result['name']).'">'.$result['name'].'</a> Item: <i>'.$result['item'].'</i> Parabens!</center>';
}
?>