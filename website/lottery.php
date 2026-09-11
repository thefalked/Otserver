<?php $lottery = false;
try {
  $lottery = $SQL->query('SELECT id, name, item FROM lottery ORDER BY id DESC LIMIT 1;');
} catch (PDOException $e) {
  $lottery = false;
}
if ($lottery) {
  foreach ($lottery as $result) {
    $main_content .=
      '<center><h1>Loteria</h1></center>
<center>A cada 30 minutos, um jogador aleatório ganha um item aleatório!<br/>
Último ganhador: <a href="?subtopic=characters&name=' .
      urlencode($result['name']) .
      '">' .
      $result['name'] .
      '</a> Item: <i>' .
      $result['item'] .
      '</i> Parabéns!</center>';
  }
}
?>
