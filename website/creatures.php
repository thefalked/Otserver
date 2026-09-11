<?php if (empty($_REQUEST['creature'])) {
    //SHOW MONSTERS LIST
    $allowed_order_by = ['name', 'exp', 'health', 'summonable', 'convinceable', 'race'];
    $order = $_REQUEST['order'];
    //generate sql query
    if ($_REQUEST['desc'] == 1) {
        $desc = ' DESC';
    }
    if ($order == 'name') {
        $whereandorder = ' ORDER BY name' . $desc;
    } elseif ($order == 'exp') {
        $whereandorder = ' ORDER BY exp' . $desc . ', name';
    } elseif ($order == 'health') {
        $whereandorder = ' ORDER BY health' . $desc . ', name';
    } elseif ($order == 'summonable') {
        $whereandorder = ' AND summonable = 1 ORDER BY mana' . $desc;
    } elseif ($order == 'convinceable') {
        $whereandorder = ' AND convinceable = 1 ORDER BY mana' . $desc;
    } elseif ($order == 'race') {
        $whereandorder = ' ORDER BY race' . $desc . ', name';
    } else {
        $whereandorder = ' ORDER BY name';
    }
    //send query to database
    $monsters = $SQL->query(
        'SELECT * FROM ' . $SQL->tableName('z_monsters') . ' WHERE hide_creature != 1' . $whereandorder
    );
    $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '>';
    if ($order == 'name' && !isset($_REQUEST['desc'])) {
        $main_content .=
            '<TD CLASS=white width="200"><B><a href="?subtopic=creatures&order=name&desc=1"><font CLASS=white>Name DESC</a></B></TD>';
    } else {
        $main_content .=
            '<TD CLASS=white width="200"><B><a href="?subtopic=creatures&order=name"><font CLASS=white>Nome</a></B></TD>';
    }
    if ($order == 'health' && !isset($_REQUEST['desc'])) {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=health&desc=1"><font CLASS=white>Vida<br/>DESC</a></B></TD>';
    } else {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=health"><font CLASS=white>Vida</a></B></TD>';
    }
    if ($order == 'exp' && !isset($_REQUEST['desc'])) {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=exp&desc=1"><font CLASS=white>Experiencia<br/>DESC</a></B></TD>';
    } else {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=exp"><font CLASS=white>Experiencia</a></B></TD>';
    }
    if ($order == 'summonable' && !isset($_REQUEST['desc'])) {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=summonable&desc=1"><font CLASS=white>Invocaveis<br/>Mana DESC</a></B></TD>';
    } else {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=summonable"><font CLASS=white>Invocaveis<br/>Mana</a></B></TD>';
    }
    if ($order == 'convinceable' && !isset($_REQUEST['desc'])) {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=convinceable&desc=1"><font CLASS=white>Convencível<br/>Mana DESC</a></B></TD>';
    } else {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=convinceable"><font CLASS=white>Convencível<br/>Mana</a></B></TD>';
    }
    if ($order == 'race' && !isset($_REQUEST['desc'])) {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=race&desc=1"><font CLASS=white>Tipo<br/>DESC</a></B></TD></TR>';
    } else {
        $main_content .=
            '<TD CLASS=white><B><a href="?subtopic=creatures&order=race"><font CLASS=white>Tipo</a></B></TD></TR>';
    }
    foreach ($monsters as $monster) {
        if (is_int($number_of_rows / 2)) {
            $bgcolor = $config['site']['lightborder'];
        } else {
            $bgcolor = $config['site']['darkborder'];
        }
        $number_of_rows++;
        $main_content .=
            '<TR BGCOLOR="' .
            $bgcolor .
            '"><TD><a href="?subtopic=creatures&creature=' .
            urlencode($monster['name']) .
            '">' .
            $monster['name'] .
            '</a></TD><TD>' .
            $monster['health'] .
            '</TD><TD>' .
            $monster['exp'] .
            '</TD>';
        if ($monster['summonable']) {
            $main_content .= '<TD>' . $monster['mana'] . '</TD>';
        } else {
            $main_content .= '<TD>---</TD>';
        }
        if ($monster['convinceable']) {
            $main_content .= '<TD>' . $monster['mana'] . '</TD>';
        } else {
            $main_content .= '<TD>---</TD>';
        }
        $main_content .= '<TD>' . ucwords($monster['race']) . '</TD></TR>';
    }

    $main_content .= '</TABLE>';
}
//SHOW INFORMATION ABOUT MONSTER
else {
    $monster_name = stripslashes(trim(ucwords($_REQUEST['creature'])));
    $monster = $SQL
        ->query(
            'SELECT * FROM ' .
                $SQL->tableName('z_monsters') .
                ' WHERE ' .
                $SQL->fieldName('hide_creature') .
                ' != 1 AND ' .
                $SQL->fieldName('name') .
                ' = ' .
                $SQL->quote($monster_name) .
                ';'
        )
        ->fetch();
    if (isset($monster['name'])) {
        $main_content .=
            '<center><h2>' .
            $monster['name'] .
            '</h2></center><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><tr><td>
<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=60%>';
        if (is_int($number_of_rows / 2)) {
            $bgcolor = $config['site']['darkborder'];
        } else {
            $bgcolor = $config['site']['lightborder'];
        }
        $number_of_rows++;
        $main_content .=
            '<tr BGCOLOR="' .
            $bgcolor .
            '"><td width="100"><b>Health: </b></td><td>' .
            $monster['health'] .
            '</td></tr>';
        if (is_int($number_of_rows / 2)) {
            $bgcolor = $config['site']['darkborder'];
        } else {
            $bgcolor = $config['site']['lightborder'];
        }
        $number_of_rows++;
        $main_content .=
            '<tr BGCOLOR="' .
            $bgcolor .
            '"><td width="100"><b>Experiência<br/>dada: </b></td><td>' .
            $monster['exp'] .
            '</td></tr>';
        if (is_int($number_of_rows / 2)) {
            $bgcolor = $config['site']['darkborder'];
        } else {
            $bgcolor = $config['site']['lightborder'];
        }
        $number_of_rows++;
        $main_content .=
            '<tr BGCOLOR="' .
            $bgcolor .
            '"><td width="100"><b>Velocidade como: </b></td><td>' .
            $monster['speed_lvl'] .
            ' level';
        if ($monster['use_haste']) {
            $main_content .= ' (Can use haste)</td></tr>';
        } else {
            $main_content .= '</td></tr>';
        }
        if ($monster['summonable'] == 1) {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['darkborder'];
            } else {
                $bgcolor = $config['site']['lightborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<tr BGCOLOR="' .
                $bgcolor .
                '"><td width="100"><b>Summon: </b></td><td>' .
                $monster['mana'] .
                ' mana</td></tr>';
        } else {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['darkborder'];
            } else {
                $bgcolor = $config['site']['lightborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<tr BGCOLOR="' . $bgcolor . '"><td width="100"><b>Summon: </b></td><td>Impossível</td></tr>';
        }
        if ($monster['convinceable'] == 1) {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['darkborder'];
            } else {
                $bgcolor = $config['site']['lightborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<tr BGCOLOR="' .
                $bgcolor .
                '"><td width="100"><b>Convince: </b></td><td>' .
                $monster['mana'] .
                ' mana</td></tr>';
        } else {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['darkborder'];
            } else {
                $bgcolor = $config['site']['lightborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<tr BGCOLOR="' . $bgcolor . '"><td width="100"><b>Convince: </b></td><td>Impossível</td></tr>';
        }
        $main_content .= '</TABLE></td><td align=left>
<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=40%>
<tr><td align=left>';
        if (file_exists('images/monsters/' . $monster['gfx_name'])) {
            $main_content .= '<img src="images/monsters/' . $monster['gfx_name'] . '" height="128" width="128">';
        } else {
            $main_content .= '<img src="images/monsters/nophoto.png" height="128" width="128">';
        }
        $main_content .= '</td></tr>
</TABLE></td></tr><tr><td>
<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>';
        if (!empty($monster['immunities'])) {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['darkborder'];
            } else {
                $bgcolor = $config['site']['lightborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<tr BGCOLOR="' .
                $bgcolor .
                '"><td width="100"><b>Imunidades: </b></td><td width="100%">' .
                $monster['immunities'] .
                '</td></tr>';
        }
        if (!empty($monster['voices'])) {
            if (is_int($number_of_rows / 2)) {
                $bgcolor = $config['site']['darkborder'];
            } else {
                $bgcolor = $config['site']['lightborder'];
            }
            $number_of_rows++;
            $main_content .=
                '<tr BGCOLOR="' .
                $bgcolor .
                '"><td width="100"><b>Vozes: </b></td><td width="100%">' .
                $monster['voices'] .
                '</td></tr>';
        }
        $main_content .= '</TABLE></td></tr>
</TABLE>';
    } else {
        $main_content .=
            'Monster with name <b>' .
            $monster_name .
            '</b> doesn\'t exist.<br/></br><center><form action="?subtopic=creatures" METHOD=post><div class="BigButton" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
            $layout_name .
            '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
    }
    //back button
    $main_content .=
        '<br/></br><center><form action="?subtopic=creatures" METHOD=post><div class="BigButton" style="background-image:url(' .
        $layout_name .
        '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
        $layout_name .
        '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
        $layout_name .
        '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
}
?>
