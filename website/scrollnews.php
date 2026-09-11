<?php // News tickers / Posts page (was missing from XAMPP pack)
$access_tickers = $config['site']['access_tickers'] ?? $config['site']['access_news'];
$main_content .= '<br/><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>';
$main_content .=
    '<TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD CLASS=white><B>Posts / News Tickers</B></TD></TR>';

if ($action == 'edit_ticker' || $action == 'newticker') {
    if ($group_id_of_acc_logged >= $access_tickers) {
        if ($action == 'newticker') {
            csrf_require();
            $ticker_text = isset($_POST['new_ticker']) ? stripslashes(trim($_POST['new_ticker'])) : '';
            $ticker_icon = isset($_POST['icon_id']) ? (int) $_POST['icon_id'] : 1;
            if (!empty($ticker_text)) {
                $SQL->query(
                    'INSERT INTO ' .
                        $SQL->tableName('z_news_tickers') .
                        ' (date, author, image_id, text, hide_ticker) VALUES (' .
                        time() .
                        ', ' .
                        $account_logged->getId() .
                        ', ' .
                        $ticker_icon .
                        ', ' .
                        $SQL->quote($ticker_text) .
                        ', 0)'
                );
                $main_content .=
                    '<TR BGCOLOR=' .
                    $config['site']['lightborder'] .
                    '><TD><font color="green"><b>Ticker added.</b></font></TD></TR>';
            }
        }
        $main_content .=
            '<TR BGCOLOR=' .
            $config['site']['darkborder'] .
            '><TD>
      <form action="?subtopic=scrollnews&action=newticker" method="post">
      ' .
            csrf_field() .
            '
      Text:<br/><textarea name="new_ticker" rows="4" cols="60"></textarea><br/>
      Icon id: <input type="text" name="icon_id" value="1" size="3"/>
      <input type="submit" value="Add ticker"/>
      </form>
    </TD></TR>';
    } else {
        $main_content .=
            '<TR BGCOLOR=' . $config['site']['lightborder'] . '><TD>You need admin rights to edit tickers.</TD></TR>';
    }
}

$tickers = $SQL->query('SELECT * FROM `z_news_tickers` WHERE hide_ticker != 1 ORDER BY date DESC LIMIT 50');
$any = false;
foreach ($tickers as $ticker) {
    $any = true;
    $bg = $config['site']['lightborder'];
    $main_content .=
        '<TR BGCOLOR="' .
        $bg .
        '"><TD><small>' .
        date('j M Y, H:i', $ticker['date']) .
        '</small><br/>' .
        nl2br(htmlspecialchars($ticker['text'])) .
        '</TD></TR>';
}
if (!$any) {
    $main_content .= '<TR BGCOLOR=' . $config['site']['lightborder'] . '><TD>No posts yet.</TD></TR>';
}
$main_content .= '</TABLE>';
?>
