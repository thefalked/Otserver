<?php
if ($logged) {
    // type (1 = question; 2 = answer)
    // status (1 = open; 2 = new message; 3 = closed;)

    $dark = $config['site']['darkborder'];
    $light = $config['site']['lightborder'];

    $priority = array(1 => "Low", "Normal", "Emergency");
    $tags = array(1 => "[MAP]", "[WEBSITE]", "[CLIENT]", "[MONSTER]", "[NPC]", "[OTHER]");

    if ($group_id_of_acc_logged >= $config['site']['access_admin_panel'] and $_REQUEST['control'] == "true") {
        $bug_acc = isset($_REQUEST['acc']) ? (int) $_REQUEST['acc'] : 0;
        $bug_id = isset($_REQUEST['id']) ? (int) $_REQUEST['id'] : 0;
        if (empty($_REQUEST['id']) and empty($_REQUEST['acc']) or !is_numeric($_REQUEST['acc'] ?? '') or !is_numeric($_REQUEST['id'] ?? ''))
            $bug[1] = $SQL->query('SELECT * FROM ' . $SQL->tableName('z_bug_tracker') . ' where `type` = 1 order by `uid` desc');

        if ($bug_id > 0 and $bug_acc > 0)
            $bug[2] = $SQL->query('SELECT * FROM ' . $SQL->tableName('z_bug_tracker') . ' where `account` = ' . $bug_acc . ' and `id` = ' . $bug_id . ' and `type` = 1')->fetch();

        if ($bug_id > 0 and $bug_acc > 0) {
            if (!empty($_REQUEST['reply']))
                $reply = true;

            $account = $ots->createObject('Account');
            $account->load($bug_acc);
            $account->isLoaded();
            $players = $account->getPlayersList();

            if (!$reply) {
                if ($bug[2]['status'] == 2)
                    $value = "<font color=gray><b>ESPERA</b> <img src=images/bug/waiting.gif></font>";
                elseif ($bug[2]['status'] == 4)
                    $value = "<font color=green><b>APOIADO</b></font> <img src=images/bug/ok.png>";
                elseif ($bug[2]['status'] == 3)
                    $value = "<font color=red><b>Não é um bug</b></font> <img src=images/bug/closed.png>";
                elseif ($bug[2]['status'] == 1)
                    $value = "<font color=#4169E1><b>Nova Resposta</b></font> <img src=images/bug/new.png>";

                $main_content .= '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD COLSPAN=2 CLASS=white><B>Bugs Reportados</B></TD></TR>';
                $main_content .= '<TR BGCOLOR="' . $dark . '"><td width=40%><img src=images/bug/report.png> <b>Subject:</b></td><td> ' . h($tags[$bug[2]['tag']] ?? '') . ' ' . h($bug[2]['subject']) . '  ' . $value . '</td></tr>';
                $main_content .= '<TR BGCOLOR="' . $light . '"><td><img src=images/bug/pri.gif> <b>Prioridade:</b></td><td> <img src=images/bug/' . $bug[2]['priority'] . '.png> ' . h($priority[$bug[2]['priority']] ?? '') . '';
                $main_content .= '<TR BGCOLOR="' . $dark . '"><td><img src=images/bug/tibia.png> <b>Postado Por:</b></td><td>';


                foreach ($players as $player) {
                    $main_content .= '<img src=images/bug/t.png> ' . h($player->getName()) . '<br>';
                }

                $main_content .= '</td></tr>';
                $main_content .= '<TR BGCOLOR="' . $light . '"><td colspan=2><img src=images/bug/des.png><b>Descricao:</b></td></tr>';
                $main_content .= '<TR BGCOLOR="' . $dark . '"><td colspan=2>' . nl2br(h($bug[2]['text'])) . '</td></tr>';
                $main_content .= '</TABLE>';

                $answers = $SQL->query('SELECT * FROM ' . $SQL->tableName('z_bug_tracker') . ' where `account` = ' . $bug_acc . ' and `id` = ' . $bug_id . ' and `type` = 2 order by `reply`');

                $ot = $config['site']['worlds'];

                foreach ($answers as $answer) {
                    if ($answer['who'] == 1)
                        $who = "<img src=images/bug/staff.gif> <font color=red><b>SUPORTE</b></font>";
                    else
                        $who = "<img src=images/bug/player.gif> <font color=green><b>JOGADOR</b></font>";

                    $main_content .= '<br><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD COLSPAN=2 CLASS=white><B>Answer #' . $answer['reply'] . '</B></TD></TR>';
                    $main_content .= '<TR BGCOLOR="' . $dark . '"><td width=70%><img src=images/bug/tibia.png><i><b>Posted by:</b></i></td><td>' . $who . '</td></tr>';
                    $main_content .= '<TR BGCOLOR="' . $light . '"><td colspan=2><img src=images/bug/des.png><i><b>Description:</b></i></td></tr>';
                    $main_content .= '<TR BGCOLOR="' . $dark . '"><td colspan=2>' . nl2br(h($answer['text'])) . '</td></tr>';
                    $main_content .= '</TABLE>';
                }
                if ($bug[2]['status'] < 3)
                    $main_content .= '<br><a href="index.php?subtopic=bugtracker&control=true&id=' . $bug_id . '&acc=' . $bug_acc . '&reply=true"><b>[REPLY]</b></a>';
            } else {
                if ($bug[2]['status'] < 3) {
                    $reply = $SQL->query('SELECT MAX(reply) FROM `z_bug_tracker` where `account` = ' . $bug_acc . ' and `id` = ' . $bug_id . ' and `type` = 2')->fetch();
                    $reply = $reply[0] + 1;
                    $iswho = $SQL->query('SELECT * FROM `z_bug_tracker` where `account` = ' . $bug_acc . ' and `id` = ' . $bug_id . ' and `type` = 2 order by `reply` desc limit 1')->fetch();

                    if (isset($_POST['finish'])) {
                        csrf_require();
                        if (empty($_POST['text']))
                            $error[] = "<font color=black><b>Descrição não pode ser vazio.</b></font>";
                        if ($iswho['who'] == 1)
                            $error[] = "<font color=black><b>Você deve esperar pela resposta do usuário.</b></font>";
                        $status = (int) ($_POST['status'] ?? 0);
                        if (!in_array($status, array(2, 3, 4), true))
                            $error[] = "<font color=black><b>Estado não pode ser vazio.</b></font>";


                        if (!empty($error)) {
                            foreach ($error as $errors)
                                $main_content .= '' . $errors . '<br>';
                        } else {
                            $type = 2;
                            $INSERT = $SQL->query('INSERT INTO `z_bug_tracker` (`account`,`id`,`text`,`reply`,`type`, `who`) VALUES (' . $SQL->quote($bug_acc) . ',' . $SQL->quote($bug_id) . ',' . $SQL->quote($_POST['text']) . ',' . $SQL->quote($reply) . ',' . $SQL->quote($type) . ',' . $SQL->quote(1) . ')');
                            $UPDATE = $SQL->query('UPDATE `z_bug_tracker` SET `status` = ' . $status . ' where `account` = ' . $bug_acc . ' and `id` = ' . $bug_id);
                            header('Location: index.php?subtopic=bugtracker&control=true&id=' . $bug_id . '&acc=' . $bug_acc);
                        }
                    }
                    $main_content .= '<br><form method="post" action="">' . csrf_field() . '<table><tr><td>Message:</i></td><td><textarea name="text" rows="3" cols="25"></textarea></td></tr><tr><td><br><font color=gray><b>EM PROGRESSO</b></font> <img src=images/bug/waiting.gif></td><td><input type=radio name=status value=2></td></tr><tr><td><font color=green><b>APOIADO <img src=http://www.binarybiz.com/support/faq/admin/images/success.gif></b></font></td><td><input type=radio name=status value=4></td></tr><tr><td><font color=red><b>Não é um bug <img src=http://www.iscr.com/imagenes/menu/cancel.gif></b></font></td><td><input type=radio name=status value=3></td></tr></table><br><input type="submit" name="finish" value="Submit" class="input2"/></form>';
                } else {
                    $main_content .= "<br><font color=black><b>Você não pode adicionar resposta ao tópico bug fechado.</b></font>";
                }
            }

            $post = true;
        }
        if (!$post) {
            $main_content .= '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD colspan=2 CLASS=white><B>Bug Tracker Admin</B></TD></TR>';
            $i = 1;
            foreach ($bug[1] as $report) {


                if ($report['status'] == 2)
                    $value = "<font color=gray><b>ESPERA</b> <img src=images/bug/waiting.gif></font>";
                elseif ($report['status'] == 3)
                    $value = "<font color=red><b>Não é um bug</b></font> <img src=images/bug/closed.png>";
                elseif ($report['status'] == 4)
                    $value = "<font color=green><b>APOIADO</b></font> <img src=images/bug/ok.png>";
                elseif ($report['status'] == 1)
                    $value = "<font color=#4169E1><b>Nova Resposta</b></font> <img src=images/bug/new.png>";

                if (is_int($i / 2)) {
                    $bgcolor = $dark;
                } else {
                    $bgcolor = $light;
                }

                $main_content .= '<TR BGCOLOR="' . $bgcolor . '"><td width=75%><img src=images/bug/' . $report['priority'] . '.png> <a href="index.php?subtopic=bugtracker&control=true&id=' . (int) $report['id'] . '&acc=' . (int) $report['account'] . '">' . h($tags[$report['tag']] ?? '') . ' ' . h($report['subject']) . '</a></td><td>' . $value . '</td></tr>';

                $showed = true;
                $i++;
            }
            $main_content .= '</TABLE>';
        }
    } else {
        $acc = $account_logged->getId();
        $account_players = $account_logged->getPlayersList();

        foreach ($account_players as $player) {
            $allow = true;
        }

        if (!empty($_REQUEST['id']))
            $id = (int) $_REQUEST['id'];
        else
            $id = 0;

        if (empty($_REQUEST['id']))
            $bug[1] = $SQL->query('SELECT * FROM ' . $SQL->tableName('z_bug_tracker') . ' where `account` = ' . $account_logged->getId() . ' and `type` = 1 order by `id` desc');

        if (!empty($_REQUEST['id']) and $id > 0)
            $bug[2] = $SQL->query('SELECT * FROM ' . $SQL->tableName('z_bug_tracker') . ' where `account` = ' . $account_logged->getId() . ' and `id` = ' . $id . ' and `type` = 1')->fetch();
        else
            $bug[2] = NULL;

        if (!empty($_REQUEST['id']) and $bug[2] != NULL) {
            if (!empty($_REQUEST['reply']))
                $reply = true;

            if (!$reply) {


                if ($bug[2]['status'] == 1)
                    $value = "<font color=gray><b>ESPERA</b> <img src=images/bug/waiting.gif></font>";
                elseif ($bug[2]['status'] == 2)
                    $value = "<font color=#4169E1><b>nova resposta</b></font> <img src=images/bug/new.png>";
                elseif ($bug[2]['status'] == 3)
                    $value = "<font color=red><b>Não é um bug</b></font> <img src=images/bug/closed.png>";
                elseif ($bug[2]['status'] == 4)
                    $value = "<font color=green><b>APOIADO</b></font> <img src=images/bug/ok.png>";


                $main_content .= '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD COLSPAN=2 CLASS=white><B>Reportar Bug</B></TD></TR>';
                $main_content .= '<TR BGCOLOR="' . $dark . '"><td width=40%><img src=images/bug/report.png><b> Subject:</b></td><td> ' . h($tags[$bug[2]['tag']] ?? '') . ' ' . h($bug[2]['subject']) . ' ' . $value . '</td></tr>';
                $main_content .= '<TR BGCOLOR="' . $light . '"><td><img src=images/bug/pri.gif> <b>Prioridade:</b></td><td> <img src=images/bug/' . $bug[2]['priority'] . '.png> ' . h($priority[$bug[2]['priority']] ?? '') . '';

                $main_content .= '<TR BGCOLOR="' . $dark . '"><td><img src=images/bug/tibia.png> <b>Postado Por:</b></td><td>';
                $main_content .= '<img src=images/bug/t.png> You <br>';


                $main_content .= '<TR BGCOLOR="' . $light . '"><td colspan=2><img src=images/bug/des.png><b>Descricao:</b></td></tr>';
                $main_content .= '<TR BGCOLOR="' . $dark . '"><td colspan=2>' . nl2br(h($bug[2]['text'])) . '</td></tr>';
                $main_content .= '</TABLE>';

                $answers = $SQL->query('SELECT * FROM ' . $SQL->tableName('z_bug_tracker') . ' where `account` = ' . $account_logged->getId() . ' and `id` = ' . $id . ' and `type` = 2 order by `reply`');
                foreach ($answers as $answer) {
                    if ($answer['who'] == 1)
                        $who = "<img src=images/bug/staff.gif> <font color=red><b>APOIO</b></font>";
                    else
                        $who = "<img src=images/bug/player.gif> <font color=green><b>VOCÊ</b></font>";

                    $main_content .= '<br><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD COLSPAN=2 CLASS=white><B>Answer #' . $answer['reply'] . '</B></TD></TR>';
                    $main_content .= '<TR BGCOLOR="' . $dark . '"><td width=70%><img src=images/bug/tibia.png><i><b> Postado Por:</b></i></td><td>' . $who . '</td></tr>';
                    $main_content .= '<TR BGCOLOR="' . $light . '"><td colspan=2><img src=images/bug/des.png><i><b>Descricao:</b></i></td></tr>';
                    $main_content .= '<TR BGCOLOR="' . $dark . '"><td colspan=2>' . nl2br(h($answer['text'])) . '</td></tr>';
                    $main_content .= '</TABLE>';
                }
                if ($bug[2]['status'] != 3)
                    $main_content .= '<br><a href="index.php?subtopic=bugtracker&id=' . $id . '&reply=true"><b>[REPLY]</b></a>';
            } else {
                if ($bug[2]['status'] != 3) {
                    $reply = $SQL->query('SELECT MAX(reply) FROM `z_bug_tracker` where `account` = ' . $acc . ' and `id` = ' . $id . ' and `type` = 2')->fetch();
                    $reply = $reply[0] + 1;
                    $iswho = $SQL->query('SELECT * FROM `z_bug_tracker` where `account` = ' . $acc . ' and `id` = ' . $id . ' and `type` = 2 order by `reply` desc limit 1')->fetch();

                    if (isset($_POST['finish'])) {
                        csrf_require();
                        if (empty($_POST['text']))
                            $error[] = "<font color=black><b>Descrição não pode ser vazio.</b></font>";
                        if ($iswho['who'] == 0)
                            $error[] = "<font color=black><b>Você deve esperar pela resposta do administrador.</b></font>";
                        if (!$allow)
                            $error[] = "<font color=black><b>Você não possui uma personagem conta.</b></font>";

                        if (!empty($error)) {
                            foreach ($error as $errors)
                                $main_content .= '' . $errors . '<br>';
                        } else {
                            $type = 2;
                            $INSERT = $SQL->query('INSERT INTO `z_bug_tracker` (`account`,`id`,`text`,`reply`,`type`) VALUES (' . $SQL->quote($acc) . ',' . $SQL->quote($id) . ',' . $SQL->quote($_POST['text']) . ',' . $SQL->quote($reply) . ',' . $SQL->quote($type) . ')');
                            $UPDATE = $SQL->query('UPDATE `z_bug_tracker` SET `status` = 1 where `account` = ' . $acc . ' and `id` = ' . $id . '');
                            header('Location: index.php?subtopic=bugtracker&id=' . $id . '');
                        }
                    }
                    $main_content .= '<br><form method="post" action="">' . csrf_field() . '<table><tr><td><i>Descricao</i></td><td><textarea name="text" rows="15" cols="35"></textarea></td></tr></table><br><input type="submit" name="finish" value="Submit" class="input2"/></form>';
                } else {
                    $main_content .= "<br><font color=black><b>Você não pode adicionar resposta ao tópico bug fechado.</b></font>";
                }
            }

            $post = true;
        } elseif (!empty($_REQUEST['id']) and $bug[2] == NULL) {
            $main_content .= '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD CLASS=white><B>Reportar Bug</B></TD></TR>';
            $main_content .= '<TR BGCOLOR="' . $dark . '"><td><i>Bug não existe.</i></td></tr>';
            $main_content .= '</TABLE>';
            $post = true;
        }

        if (!$post) {
            if ($_REQUEST['add'] != TRUE) {
                $main_content .= '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' . $config['site']['vdarkborder'] . '><TD colspan=2 CLASS=white><B>Reportar Bug</B></TD></TR>';
                foreach ($bug[1] as $report) {
                    if ($report['status'] == 1)
                        $value = "<font color=gray><b>ESPERA</b> <img src=images/bug/waiting.gif></font>";
                    elseif ($report['status'] == 2)
                        $value = "<font color=#4169E1><b>Nova Resposta</b></font> <img src=images/bug/new.png>";
                    elseif ($report['status'] == 3)
                        $value = "<font color=red><b>Não é um bug</b></font> <img src=images/bug/closed.png>";
                    elseif ($report['status'] == 4)
                        $value = "<font color=green><b>APOIADO</b></font> <img src=images/bug/ok.png>";

                    if (is_int($report['id'] / 2)) {
                        $bgcolor = $dark;
                    } else {
                        $bgcolor = $light;
                    }

                    $main_content .= '<TR BGCOLOR="' . $bgcolor . '"><td width=75%><img src=images/bug/' . $report['priority'] . '.png> <a href="index.php?subtopic=bugtracker&id=' . $report['id'] . '">' . h($tags[$report['tag']] ?? '') . ' ' . h($report['subject']) . '</a></td><td>' . $value . '</td></tr>';

                    $showed = true;
                }

                if (!$showed) {
                    $main_content .= '<TR BGCOLOR="' . $dark . '"><td><i>Voces nao relataram quaisquer bugs.</i></td></tr>';
                }
                $main_content .= '</TABLE>';

                $main_content .= '<br><a href="index.php?subtopic=bugtracker&add=true"><b>[ADD REPORT]</b></a>';
            } elseif ($_REQUEST['add'] == TRUE) {
                $thread = $SQL->query('SELECT * FROM `z_bug_tracker` where `account` = ' . $acc . ' and `type` = 1 order by `id` desc')->fetch();
                $id_next = $SQL->query('SELECT MAX(id) FROM `z_bug_tracker` where `account` = ' . $acc . ' and `type` = 1')->fetch();
                $id_next = $id_next[0] + 1;

                if (empty($thread))
                    $thread['status'] = 3;

                if (isset($_POST['submit'])) {
                    csrf_require();
                    if ($thread['status'] != 3)
                        $error[] = "<font color=black><b>Pode ser apenas um fio bug aberto.</b></font>";
                    if (empty($_POST['subject']))
                        $error[] = "<font color=black><b>Assunto não pode ser vazio.</b></font>";
                    if (empty($_POST['text']))
                        $error[] = "<font color=black><b>Descrição não pode ser vazio.</b></font>";
                    if (!$allow)
                        $error[] = "<font color=black><b>Você não possui uma personagem conta.</b></font>";
                    if (empty($_POST['tags']))
                        $error[] = "<font color=black><b>Tag não pode ser vazio.</b></font>";

                    if (!empty($error)) {
                        foreach ($error as $errors)
                            $main_content .= '' . $errors . '<br>';
                    } else {
                        $type = 1;
                        $status = 1;
                        $tag = (int) $_POST['tags'];
                        $prio = (int) $_POST['priority'];
                        $INSERT = $SQL->query('INSERT INTO `z_bug_tracker` (`account`,`id`,`text`,`type`,`subject`,`status`,`tag`,`priority`) VALUES (' . $SQL->quote($acc) . ',' . $SQL->quote($id_next) . ',' . $SQL->quote($_POST['text']) . ',' . $SQL->quote($type) . ',' . $SQL->quote($_POST['subject']) . ',' . $SQL->quote($status) . ',' . $SQL->quote($tag) . ',' . $SQL->quote($prio) . ')');
                        header('Location: index.php?subtopic=bugtracker&id=' . $id_next . '');
                    }

                }
                $main_content .= '<br><form method="post" action="">' . csrf_field() . '<font size=4><b>Reportar Bug</b></font><br><br><br><table><tr><td><img src=images/bug/report.png> <b>Assunto:</b></td><td><input type=text name="subject"/></td></tr><tr><td><img src=images/bug/des.png><b>Descricao:</b></td><td><textarea name="text" rows="4" cols="15"></textarea></td></tr><tr><td><img src=images/bug/tag.png> <b>TAG:</b></td><td><select name="tags"><option value="">SELECT</option>';

                for ($i = 1; $i <= count($tags); $i++) {
                    $main_content .= '<option value="' . $i . '">' . $tags[$i] . '</option>';
                }

                $main_content .= '</td></tr><tr><td><br><img src=images/bug/pri.gif> <b>Prioridade:</b></td><td><br><select name="priority"><option value="">SELECT</option>';

                for ($i = 1; $i <= count($priority); $i++) {
                    $main_content .= '<option value="' . $i . '">' . $priority[$i] . '</option>';
                }


                $main_content .= '</select></tr></tr></table><br><input type="submit" name="submit" value="Submit" class="input2"/></form>';
            }
        }
    }

    if ($group_id_of_acc_logged >= $config['site']['access_admin_panel'] and empty($_REQUEST['control'])) {
        $main_content .= '<br><br><a href="index.php?subtopic=bugtracker&control=true">[ADMIN PANEL]</a>';
    }
} else {
    $main_content .= 'Digite seu nome de conta e sua senha.<br/><a href="?subtopic=createaccount" >Create an account</a> if you do not have one yet.<br/><br/><form action="?subtopic=bugtracker" method="post" >' . csrf_field() . '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' . $layout_name . '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' . $layout_name . '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' . $layout_name . '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' . $layout_name . '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Account Login</div>        <span class="CaptionVerticalRight" style="background-image:url(' . $layout_name . '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' . $layout_name . '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' . $layout_name . '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' . $layout_name . '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td class="LabelV" ><span >Account Name:</span></td><td style="width:100%;" ><input type="password" name="account_login" SIZE="10" maxlength="10" ></td></tr><tr><td class="LabelV" ><span >Password:</span></td><td><input type="password" name="password_login" size="30" maxlength="29" ></td></tr>          </table>        </div>  </table></div></td></tr><br/><table width="100%" ><tr align="center" ><td><table border="0" cellspacing="0" cellpadding="0" ><tr><td style="border:0px;" ><div class="BigButton" style="background-image:url(' . $layout_name . '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' . $layout_name . '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Submit" alt="Submit" src="' . $layout_name . '/images/buttons/_sbutton_submit.gif" ></div></div></td><tr></form></table></td><td><table border="0" cellspacing="0" cellpadding="0" ><form action="?subtopic=lostaccount" method="post" >' . csrf_field() . '<tr><td style="border:0px;" ><div class="BigButton" style="background-image:url(' . $layout_name . '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' . $layout_name . '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Account lost?" alt="Account lost?" src="' . $layout_name . '/images/buttons/_sbutton_accountlost.gif" ></div></div></td></tr></form></table></td></tr></table>';
}
?>