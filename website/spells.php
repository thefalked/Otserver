<?php $allowed_order_by = ['name', 'spell', 'spell_type', 'mana', 'lvl', 'mlvl', 'soul'];
$vocation_id = $_REQUEST['vocation_id'] ?? '';
$order = $_REQUEST['order'] ?? '';
$number_of_rows = 0;
if (in_array($order, $allowed_order_by)) {
    $orderby = $order;
} else {
    $orderby = 'name';
}

$spells = $SQL->query('SELECT * FROM z_spells WHERE hide_spell != 1 ORDER BY ' . $orderby . ', lvl');
$main_content .=
    '<FORM ACTION="?subtopic=spells" METHOD=post>
<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>
<TR BGCOLOR=' .
    $config['site']['vdarkborder'] .
    '><TD CLASS=white><B>Pesquisar Magia</B></TD></TR>
<TR BGCOLOR=' .
    $config['site']['darkborder'] .
    '><TD>Apenas a Vocacao <SELECT NAME="vocation_id">';
$main_content .= '<OPTION VALUE="a:a" ';
if ('a:a' == $vocation_id) {
    $main_content .= 'SELECTED';
}
$main_content .= '>All';

foreach ($vocation_name[0] as $prom => $arr) {
    foreach ($arr as $voc_id => $voc_name) {
        $main_content .= '<OPTION VALUE="' . $prom . ';' . $voc_id . '"';
        if ($prom . ';' . $voc_id == $vocation_id && $vocation_id != 'a:a' && $vocation_id != '') {
            $main_content .= ' SELECTED';
        }
        $main_content .= '/>' . $voc_name;
    }
}
$main_content .=
    '</SELECT><input type="hidden" name="order" value="' .
    $orderby .
    '">&nbsp;&nbsp;&nbsp;<INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
    $layout_name .
    '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD><TR>
</TABLE></FORM>';

$main_content .=
    '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
    $config['site']['vdarkborder'] .
    '><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=name"><font CLASS=white>Nome</a></B></TD><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=spell"><font CLASS=white>Sentenca</a></B></TD><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=spell_type"><font CLASS=white>Tipo<br/>(contagem)</a></B></TD><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=mana"><font CLASS=white>Mana</a></B></TD><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=lvl"><font CLASS=white>Exp.<br/>Level</a></B></TD><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=mlvl"><font CLASS=white>Magic<br/>Level</a></B></TD><TD CLASS=white><B><a href="?subtopic=spells&vocation_id=' .
    $vocation_id .
    '&order=soul"><font CLASS=white>Alma</a></B></TD><TD CLASS=white><B>PACC</B></TD><TD CLASS=white><B>Para<br/>Vocacoes:</B></TD></TR>';
if ($vocation_id != 'a:a' && $vocation_id != '') {
    foreach ($vocation_name[0] as $prom => $arr) {
        foreach ($arr as $voc_id => $voc_name) {
            if ($prom . ';' . $voc_id == $vocation_id) {
                $voc_n = $voc_name;
            }
        }
    }
    foreach ($spells as $spell) {
        $spell_vocations = explode(',', $spell['vocations']);
        if (in_array($vocation_id, $spell_vocations) || empty($spell['vocations'])) {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['lightborder'];
            } else {
                $bgcolor = $config['site']['darkborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<TR BGCOLOR="' . $bgcolor . '"><TD>' . $spell['name'] . '</TD><TD>' . $spell['spell'] . '</TD>';
            if ($spell['spell_type'] == 'conjure') {
                $main_content .= '<TD>' . $spell['spell_type'] . '(' . $spell['conj_count'] . ')</TD>';
            } else {
                $main_content .= '<TD>' . $spell['spell_type'] . '</TD>';
            }
            $main_content .=
                '<TD>' .
                $spell['mana'] .
                '</TD><TD>' .
                $spell['lvl'] .
                '</TD><TD>' .
                $spell['mlvl'] .
                '</TD><TD>' .
                $spell['soul'] .
                '</TD><TD>' .
                $spell['pacc'] .
                '</TD><TD>' .
                $voc_n .
                '</TD></TR>';
        }
    }
} else {
    foreach ($spells as $spell) {
        $spell_vocations = explode(',', $spell['vocations']);
        $showed_vocations = 0;
        $vocs = '';
        foreach ($spell_vocations as $voc) {
            $voc_info = explode(';', $voc);
            if (isset($voc_info[0], $voc_info[1]) && !empty($vocation_name[0][$voc_info[0]][$voc_info[1]])) {
                $vocs .= $vocation_name[0][$voc_info[0]][$voc_info[1]];
                if ($showed_vocations != count($spell_vocations)) {
                    $vocs .= '<br/>';
                }
            }
        }
        if (is_int($number_of_rows / 2)) {
            $bgcolor = $config['site']['lightborder'];
        } else {
            $bgcolor = $config['site']['darkborder'];
        }
        $number_of_rows++;
        $main_content .=
            '<TR BGCOLOR="' . $bgcolor . '"><TD>' . $spell['name'] . '</TD><TD>' . $spell['spell'] . '</TD>';
        if ($spell['spell_type'] == 'conjure') {
            $main_content .= '<TD>' . $spell['spell_type'] . '(' . $spell['conj_count'] . ')</TD>';
        } else {
            $main_content .= '<TD>' . $spell['spell_type'] . '</TD>';
        }
        $main_content .=
            '<TD>' .
            $spell['mana'] .
            '</TD><TD>' .
            $spell['lvl'] .
            '</TD><TD>' .
            $spell['mlvl'] .
            '</TD><TD>' .
            $spell['soul'] .
            '</TD><TD>' .
            $spell['pacc'] .
            '</TD><TD><font size="1">' .
            $vocs .
            '</font></TD></TR>';
    }
}

$main_content .= '</TABLE>';
?>
