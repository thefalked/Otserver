<?php if (($_REQUEST['todo'] ?? '') === 'save') {
  csrf_require();
}
if (in_array($action ?? '', ['deleterank', 'addrank', 'saveranks'], true)) {
  csrf_require();
}
if ($action == 'login') {
  if (check_guild_name($_REQUEST['guild'])) {
    $guild = $_REQUEST['guild'];
  }
  if ($_REQUEST['redirect'] == 'guild' || $_REQUEST['redirect'] == 'guilds') {
    $redirect = $_REQUEST['redirect'];
  }
  if (!$logged) {
    $main_content .=
      'Please enter your account number and your password.<br/><a href="?subtopic=createaccount" >Create an account</a> if you do not have one yet.<br/><br/><form action="?subtopic=guilds&action=login&guild=' .
      $guild .
      '&redirect=' .
      $redirect .
      '" method="post" >' .
      csrf_field() .
      '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
      $layout_name .
      '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Account Login</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td class="LabelV" ><span >Account Number:</span></td><td style="width:100%;" ><input type="password" name="account_login" SIZE="10" maxlength="10" ></td></tr><tr><td class="LabelV" ><span >Password:</span></td><td><input type="password" name="password_login" size="30" maxlength="29" ></td></tr>          </table>        </div>  </table></div></td></tr><br/><table width="100%" ><tr align="center" ><td><table border="0" cellspacing="0" cellpadding="0" ><tr><td style="border:0px;" ><div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Submit" alt="Submit" src="' .
      $layout_name .
      '/images/buttons/_sbutton_submit.gif" ></div></div></td><tr></form></table></td><td><table border="0" cellspacing="0" cellpadding="0" ><form action="?subtopic=lostaccount" method="post" >' .
      csrf_field() .
      '<tr><td style="border:0px;" ><div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Account lost?" alt="Account lost?" src="' .
      $layout_name .
      '/images/buttons/_sbutton_accountlost.gif" ></div></div></td></tr></form></table></td></tr></table>';
  } else {
    $main_content .= '<center><h3>Now you are logged. Redirecting...</h3></center>';
    if ($redirect == 'guilds') {
      header('Location: ?subtopic=guilds');
    } elseif ($redirect == 'guild') {
      header('Location: ?subtopic=guilds&action=show&guild=' . $guild);
    } else {
      $main_content .= 'Wrong address to redirect!';
    }
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show list of guilds
if ($action == '') {
  if (count($config['site']['worlds']) > 1) {
    $main_content .=
      '<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH=100%><TR><TD></TD><TD>
<FORM ACTION="" METHOD=get><INPUT TYPE=hidden NAME=subtopic VALUE=guilds><TABLE WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=4><TR><TD BGCOLOR="' .
      $config['site']['vdarkborder'] .
      '" CLASS=white><B>Selecione o Mundo</B></TD></TR><TR><TD BGCOLOR="' .
      $config['site']['darkborder'] .
      '">
    <TABLE BORDER=0 CELLPADDING=1><TR><TD>Mundo: </TD><TD><INPUT TYPE=hidden NAME=subtopic VALUE=guilds><SELECT SIZE="1" NAME="world"><OPTION VALUE="" SELECTED>(Selecione o Mundo)</OPTION>';
    foreach ($config['site']['worlds'] as $id => $world_n) {
      $main_content .= '<OPTION VALUE="' . $id . '">' . $world_n . '</OPTION>';
    }
    $main_content .=
      '</SELECT> </TD><TD><INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_submit.gif">
        </TD></TR></TABLE></TABLE></FORM></TABLE>';
  }
  foreach ($config['site']['worlds'] as $idd => $world_n) {
    if ($idd == (int) ($_REQUEST['world'] ?? -1)) {
      $world_id = $idd;
      $world_name = $world_n;
    }
  }
  if (!isset($world_id)) {
    $world_id = 0;
    $world_name = $config['server']['serverName'];
  }
  $filter = new OTS_SQLFilter();
  $filter->compareField('world_id', (int) $world_id);
  $guilds_list = $ots->createObject('Guilds_List');
  $guilds_list->setFilter($filter);
  $guilds_list->orderBy('name');

  $main_content .=
    '<h2><center><i>Mundo:</i> ' .
    $world_name .
    '</center></h2><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>
	<TR BGCOLOR=' .
    $config['site']['vdarkborder'] .
    '><TD COLSPAN=3 CLASS=white><B>Guilds em ' .
    $world_name .
    '</B></TD></TR>
	<TR BGCOLOR=' .
    $config['site']['darkborder'] .
    '><TD WIDTH=64><B>Logo</B></TD>
	<TD WIDTH=100%><B>Descricao</B></TD>
	<TD WIDTH=56><B>&#160;</B></TD></TR>';
  $showed_guilds = 1;
  if (count($guilds_list) > 0) {
    foreach ($guilds_list as $guild) {
      if (is_int($showed_guilds / 2)) {
        $bgcolor = $config['site']['darkborder'];
      } else {
        $bgcolor = $config['site']['lightborder'];
      }
      $showed_guilds++;
      $guild_logo = $guild->getCustomField('logo_gfx_name');
      foreach (['/', '\\', '..'] as $char) {
        $guild_logo = str_replace($char, '', $guild->getCustomField('logo_gfx_name'));
      }
      if (empty($guild_logo) || !file_exists('guilds/' . $guild_logo)) {
        $guild_logo = 'default_logo.gif';
      }
      $description = h($guild->getCustomField('description'));
      $newlines = ["\r\n", "\n", "\r"];
      $description_with_lines = str_replace($newlines, '<br />', $description, $count);
      if ($count < $config['site']['guild_description_lines_limit']) {
        $description = $description_with_lines;
      }
      $main_content .=
        '<TR BGCOLOR="' .
        $bgcolor .
        '"><TD><IMG SRC="guilds/' .
        h($guild_logo) .
        '" WIDTH=64 HEIGHT=64></TD>
			<TD valign="top"><B>' .
        h($guild->getName()) .
        '</B><BR/>' .
        $description .
        '';
      if ($group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
        $main_content .=
          '<br /><a href="?subtopic=guilds&action=deletebyadmin&guild=' .
          $guild->getId() .
          '">Delete this guild (for ADMIN only!)</a>';
      }
      $main_content .=
        '</TD><TD><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild->getId() .
        '" METHOD=post>' .
        csrf_field() .
        '<TR><TD>
			<INPUT TYPE=image NAME="View" ALT="View" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_view.gif" BORDER=0 WIDTH=120 HEIGHT=18>
			</TD></TR></FORM></TABLE>
			</TD></TR>';
    }
  } else {
    $main_content .=
      '<TR BGCOLOR=' .
      $config['site']['lightborder'] .
      '><TD><IMG SRC="guilds/default_logo.gif" WIDTH=64 HEIGHT=64></TD>
		<TD valign="top"><B>Criar Guild</B><BR/>Atualmente nao a Guilds no Servido. Seja o Primeiro a Criar uma, Pressione o botao "Criar Guild".</TD>
		<TD><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=createguild" METHOD=post>' .
      csrf_field() .
      '<TR><TD>
		<INPUT TYPE=image NAME="Create Guild" ALT="Create Guild" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_createguild.png" BORDER=0 WIDTH=120 HEIGHT=18>
		</TD></TR></FORM></TABLE></TD></TR>';
  }
  $main_content .= '</TABLE><br><br>';
  if ($logged) {
    $main_content .=
      '<TABLE BORDER=0 WIDTH=100%><TR><TD ALIGN=center><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=80 HEIGHT=1 BORDER=0<BR></TD><TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=createguild" METHOD=post>' .
      csrf_field() .
      '<TR><TD>
		<INPUT TYPE=image NAME="Create Guild" ALT="Create Guild" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_createguild.png" BORDER=0 WIDTH=120 HEIGHT=18>
		</TD></TR></FORM></TABLE></TD><TD ALIGN=center><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=80 HEIGHT=1 BORDER=0<BR></TD></TR></TABLE>
		<BR />Caso tenha Problema com guildas
		<BR /><a href="?subtopic=guilds&action=cleanup_players">Cleanup players</a> - Nao pode juntar-se a guilda / ser convidado? Não é possível criar guilda? Tente Cleanup players.
		<BR /><a href="?subtopic=guilds&action=cleanup_guilds">Limpar guildas</a> - Fez guild, voce e um lider, mas nao estao na lista de jogadores? Limpar guildas!';
  } else {
    $main_content .=
      'Before you can create guild you must login.<br><TABLE BORDER=0 WIDTH=100%><TR><TD ALIGN=center><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=80 HEIGHT=1 BORDER=0<BR></TD><TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=login&redirect=guilds" METHOD=post>' .
      csrf_field() .
      '<TR><TD>
		<INPUT TYPE=image NAME="Login" ALT="Login" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_login.gif" BORDER=0 WIDTH=120 HEIGHT=18>
		</TD></TR></FORM></TABLE></TD><TD ALIGN=center><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=80 HEIGHT=1 BORDER=0<BR></TD></TR></TABLE>';
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show guild page
if ($action == 'show') {
  $guild_id = (int) $_REQUEST['guild'];
  $guild_name = $guild_id;
  $guild = $ots->createObject('Guild');
  $guild->load($guild_id);
  if (!$guild->isLoaded()) {
    $guild_errors[] = 'Guild with ID <b>' . $guild_id . '</b> doesn\'t exist.';
  }
  if (!empty($guild_errors)) {
    //show errors
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    //errors and back button
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    //check is it vice or/and leader account (leader has vice + leader rights)
    $guild_leader_char = $guild->getOwner();
    $rank_list = $guild->getGuildRanksList();
    $rank_list->orderBy('level', POT::ORDER_DESC);
    $guild_leader = false;
    $guild_vice = false;
    if ($logged) {
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        $players_from_account_ids[] = $player->getId();
        $player_rank = $player->getRank();
        if (!empty($player_rank)) {
          foreach ($rank_list as $rank_in_guild) {
            if ($rank_in_guild->getId() == $player_rank->getId()) {
              $players_from_account_in_guild[] = $player->getName();
              if ($player_rank->getLevel() > 1) {
                $guild_vice = true;
                $level_in_guild = $player_rank->getLevel();
              }
              if ($guild->getOwner()->getId() == $player->getId()) {
                $guild_vice = true;
                $guild_leader = true;
              }
            }
          }
        }
      }
    }
    //show guild page
    $guild_logo = $guild->getCustomField('logo_gfx_name');
    if (empty($guild_logo) || !file_exists('guilds/' . $guild_logo)) {
      $guild_logo = 'default_logo.gif';
    }
    $description = $guild->getCustomField('description');
    $newlines = ["\r\n", "\n", "\r"];
    $description_with_lines = str_replace($newlines, '<br />', $description, $count);
    if ($count < $config['site']['guild_description_lines_limit']) {
      $description = $description_with_lines;
    }
    $guild_owner = $guild->getOwner();
    if ($guild_owner->isLoaded()) {
      $guild_owner = $guild_owner->getName();
    }
    $main_content .=
      '<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH=100%><TR>
		<TD><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=10 HEIGHT=1 BORDER=0></TD><TD>
		<TABLE BORDER=0 WIDTH=100%>
		<TR><TD WIDTH=64><IMG SRC="guilds/' .
      $guild_logo .
      '" WIDTH=64 HEIGHT=64></TD>
		<TD ALIGN=center WIDTH=100%><H1>' .
      $guild->getName() .
      '</H1></TD>
		<TD WIDTH=64><IMG SRC="guilds/' .
      $guild_logo .
      '" WIDTH=64 HEIGHT=64></TD></TR>
		</TABLE><BR>' .
      $description .
      '<BR><BR><a href="?subtopic=characters&name=' .
      urlencode($guild_owner) .
      '"><b>' .
      $guild_owner .
      '</b></a> is guild leader of <b>' .
      $guild->getName() .
      '</b>.<BR>The guild was founded on ' .
      $config['server']['serverName'] .
      ' on ' .
      date('j F Y', $guild->getCreationData()) .
      '.';
    if ($guild_leader) {
      $main_content .=
        '&nbsp;&nbsp;&nbsp;<a href="?subtopic=guilds&action=manager&guild=' .
        $guild_name .
        '"><IMG SRC="' .
        $layout_name .
        '/images/buttons/sbutton_manageguild.png" BORDER=0 WIDTH=120 HEIGHT=18 alt="Manage Guild"></a>';
    }
    $main_content .=
      '<BR><BR>
		<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>
		<TR BGCOLOR=' .
      $config['site']['vdarkborder'] .
      '><TD COLSPAN=3 CLASS=white><B>Guild Members</B></TD></TR>
		<TR BGCOLOR=' .
      $config['site']['darkborder'] .
      '><TD WIDTH=30%><B>Rank</B></TD>
		<TD WIDTH=70%><B>Name and Title</B></TD></TR>';
    $showed_players = 1;
    foreach ($rank_list as $rank) {
      $players_with_rank = $rank->getPlayersList();
      $players_with_rank->orderBy('name');
      $players_with_rank_number = count($players_with_rank);
      if ($players_with_rank_number > 0) {
        if (is_int($showed_players / 2)) {
          $bgcolor = $config['site']['darkborder'];
        } else {
          $bgcolor = $config['site']['lightborder'];
        }
        $showed_players++;
        $main_content .=
          '<TR BGCOLOR="' .
          $bgcolor .
          '"><TD valign="top">' .
          $rank->getName() .
          '</TD>
				<TD><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%>';
        foreach ($players_with_rank as $player) {
          $main_content .=
            '<TR><TD><FORM ACTION="?subtopic=guilds&action=change_nick&name=' .
            urlencode($player->getName()) .
            '" METHOD=post>' .
            csrf_field() .
            '<A HREF="?subtopic=characters&name=' .
            urlencode($player->getName()) .
            '">' .
            ($player->isOnline()
              ? "<font color=\"green\">" . $player->getName() . '</font>'
              : "<font color=\"red\">" . $player->getName() . '</font>') .
            '</A>';
          $guild_nick = $player->getGuildNick();
          if ($logged) {
            if (in_array($player->getId(), $players_from_account_ids)) {
              $main_content .=
                '(<input type="text" name="nick" value="' .
                htmlentities($player->getGuildNick()) .
                '"><input type="submit" value="Change">)';
            } elseif (!empty($guild_nick)) {
              $main_content .= ' (' . htmlentities($player->getGuildNick()) . ')';
            } elseif (!empty($guild_nick)) {
              $main_content .= ' (' . htmlentities($player->getGuildNick()) . ')';
            }
          }
          if ($level_in_guild > $rank->getLevel() || $guild_leader) {
            if ($guild_leader_char->getName() != $player->getName()) {
              $main_content .=
                '&nbsp;<font size=1>{<a href="?subtopic=guilds&action=kickplayer&guild=' .
                $guild->getId() .
                '&name=' .
                urlencode($player->getName()) .
                '">KICK</a>}</font>';
            }
          }
          $main_content .= '</FORM></TD></TR>';
        }
        $main_content .= '</TABLE></TD></TR>';
      }
    }
    $main_content .= '</TABLE>';
    include 'pot/InvitesDriver.php';
    new InvitesDriver($guild);
    $invited_list = $guild->listInvites();
    $show_accept_invite = 0;
    $show_accept_invite_offline = 0;
    if (count($invited_list) == 0) {
      $main_content .=
        '<BR><BR><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD COLSPAN=2 CLASS=white><B>Invited Characters</B></TD></TR><TR BGCOLOR=' .
        $config['site']['lightborder'] .
        '><TD>No invited characters found.</TD></TR></TABLE>';
    } else {
      $main_content .=
        '<BR><BR><TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD COLSPAN=2 CLASS=white><B>Invited Characters</B></TD></TR>';
      $showed_invited = 1;
      foreach ($invited_list as $invited_player) {
        if (count($account_players) > 0) {
          foreach ($account_players as $player_from_acc) {
            if ($player_from_acc->getName() == $invited_player->getName()) {
              $show_accept_invite++;
              if (!$player_from_acc->isOnline()) {
                $show_accept_invite_offline++;
              }
            }
          }
        }
        if (is_int($showed_invited / 2)) {
          $bgcolor = $config['site']['darkborder'];
        } else {
          $bgcolor = $config['site']['lightborder'];
        }
        $showed_invited++;
        $main_content .=
          '<TR bgcolor="' .
          $bgcolor .
          '"><TD><a href="?subtopic=characters&name=' .
          urlencode($invited_player->getName()) .
          '">' .
          $invited_player->getName() .
          '</a>';
        if ($invited_player->isOnline()) {
          $main_content .= ' <font color="red"><b>(Online)</b></font>';
        } else {
          $main_content .= ' <font color="green"><b>(Offline)</b></font>';
        }
        if ($guild_vice) {
          $main_content .=
            '  (<a href="?subtopic=guilds&action=deleteinvite&guild=' .
            $guild_name .
            '&name=' .
            $invited_player->getName() .
            '">Cancel Invitation</a>)';
        }
        $main_content .= '</TD></TR>';
      }
      $main_content .= '</TABLE>';
    }
    $main_content .=
      '<BR><BR>
		<TABLE BORDER=0 WIDTH=100%><TR><TD ALIGN=center><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=80 HEIGHT=1 BORDER=0<BR></TD>';
    if (!$logged) {
      $main_content .=
        '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=login&guild=' .
        $guild_name .
        '&redirect=guild" METHOD=post>' .
        csrf_field() .
        '<TR><TD>
			<INPUT TYPE=image NAME="Login" ALT="Login" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_login.gif" BORDER=0 WIDTH=120 HEIGHT=18>
			</TD></TR></FORM></TABLE></TD>';
    } else {
      if ($show_accept_invite > 0) {
        if ($show_accept_invite_offline > 0) {
          $main_content .=
            '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=acceptinvite&guild=' .
            $guild_name .
            '" METHOD=post>' .
            csrf_field() .
            '<TR><TD>
				<INPUT TYPE=image NAME="Accept Invite" ALT="Accept Invite" SRC="' .
            $layout_name .
            '/images/buttons/sbutton_acceptinvite.png" BORDER=0 WIDTH=120 HEIGHT=18>
				</TD></TR></FORM></TABLE></TD>';
        } else {
          $main_content .=
            '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD style="text-align:center; max-width:180px;">
				<img src="' .
            $layout_name .
            '/images/buttons/sbutton_acceptinvite.png" BORDER=0 WIDTH=120 HEIGHT=18 style="opacity:0.4; filter:alpha(opacity=40);" alt="Accept Invite (disabled)" title="Logout from the game first" /><br>
				<small><font color="red">Logout invited character first</font></small>
				</TD></TR></TABLE></TD>';
        }
      }
      if ($guild_vice) {
        $main_content .=
          '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=invite&guild=' .
          $guild_name .
          '" METHOD=post>' .
          csrf_field() .
          '<TR><TD>
				<INPUT TYPE=image NAME="Invite Player" ALT="Invite Player" SRC="' .
          $layout_name .
          '/images/buttons/sbutton_inviteplayer.png" BORDER=0 WIDTH=120 HEIGHT=18>
				</TD></TR></FORM></TABLE></TD>';
        $main_content .=
          '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=changerank&guild=' .
          $guild_name .
          '" METHOD=post>' .
          csrf_field() .
          '<TR><TD>
				<INPUT TYPE=image NAME="Change Rank" ALT="Change Rank" SRC="' .
          $layout_name .
          '/images/buttons/sbutton_changerank.png" BORDER=0 WIDTH=120 HEIGHT=18>
				</TD></TR></FORM></TABLE></TD>';
      }
      if ($players_from_account_in_guild > 0) {
        $main_content .=
          '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=leaveguild&guild=' .
          $guild_name .
          '" METHOD=post>' .
          csrf_field() .
          '<TR><TD>
				<INPUT TYPE=image NAME="Leave Guild" ALT="Leave Guild" SRC="' .
          $layout_name .
          '/images/buttons/sbutton_leaveguild.png" BORDER=0 WIDTH=120 HEIGHT=18>
				</TD></TR></FORM></TABLE></TD>';
      }
    }
    $main_content .=
      '<TD ALIGN=center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&world=' .
      $guild->getWorld() .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD>
		<INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18>
		</TD></TR></FORM></TABLE>
		</TD><TD ALIGN=center><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=80 HEIGHT=1 BORDER=0<BR></TD></TR></TABLE>
		</TD><TD><IMG src="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=10 HEIGHT=1 BORDER=0></TD>
		</TR></TABLE></TABLE>';
  }
}

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//change rank of player in guild
if ($action == 'changerank') {
  $guild_name = (int) $_REQUEST['guild'];
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t change rank.';
  }
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (!empty($guild_errors)) {
    //show errors
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    //errors and back button
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    //check is it vice or/and leader account (leader has vice + leader rights)
    $rank_list = $guild->getGuildRanksList();
    $rank_list->orderBy('level', POT::ORDER_DESC);
    $guild_leader = false;
    $guild_vice = false;
    $account_players = $account_logged->getPlayers();
    foreach ($account_players as $player) {
      $player_rank = $player->getRank();
      if (!empty($player_rank)) {
        foreach ($rank_list as $rank_in_guild) {
          if ($rank_in_guild->getId() == $player_rank->getId()) {
            $players_from_account_in_guild[] = $player->getName();
            if ($player_rank->getLevel() > 1) {
              $guild_vice = true;
              $level_in_guild = $player_rank->getLevel();
            }
            if ($guild->getOwner()->getId() == $player->getId()) {
              $guild_vice = true;
              $guild_leader = true;
            }
          }
        }
      }
    }
    //tworzenie listy osob z nizszymi uprawnieniami i rank z nizszym levelem
    if ($guild_vice) {
      foreach ($rank_list as $rank) {
        if ($guild_leader || $rank->getLevel() < $level_in_guild) {
          $ranks[$rid]['0'] = $rank->getId();
          $ranks[$rid]['1'] = $rank->getName();
          $rid++;
          $players_with_rank = $rank->getPlayersList();
          $players_with_rank->orderBy('name');
          if (count($players_with_rank) > 0) {
            foreach ($players_with_rank as $player) {
              if ($guild->getOwner()->getId() != $player->getId() || $guild_leader) {
                $players_with_lower_rank[$sid]['0'] = $player->getName();
                $players_with_lower_rank[$sid]['1'] = $player->getName() . ' (' . $rank->getName() . ')';
                $sid++;
              }
            }
          }
        }
      }
      if ($_REQUEST['todo'] == 'save') {
        $player_name = stripslashes($_REQUEST['name']);
        $new_rank = (int) $_REQUEST['rankid'];
        if (!check_name($player_name)) {
          $change_errors[] = 'Invalid player name format.';
        }
        $rank = $ots->createObject('GuildRank');
        $rank->load($new_rank);
        if (!$rank->isLoaded()) {
          $change_errors[] = 'Rank with this ID doesn\'t exist.';
        }
        if ($level_in_guild <= $rank->getLevel() && !$guild_leader) {
          $change_errors[] = 'You can\'t set ranks with equal or higher level than your.';
        }
        if (empty($change_errors)) {
          $player_to_change = $ots->createObject('Player');
          $player_to_change->find($player_name);
          if (!$player_to_change->isLoaded()) {
            $change_errors[] = 'Player with name ' . $player_name . '</b> doesn\'t exist.';
          } else {
            $player_in_guild = false;
            if ($guild->getName() == $player_to_change->getRank()->getGuild()->getName() || $guild_leader) {
              $player_in_guild = true;
              $player_has_lower_rank = false;
              if ($player_to_change->getRank()->getLevel() < $level_in_guild || $guild_leader) {
                $player_has_lower_rank = true;
              }
            }
          }
          $rank_in_guild = false;
          foreach ($rank_list as $rank_from_guild) {
            if ($rank_from_guild->getId() == $rank->getId()) {
              $rank_in_guild = true;
            }
          }
          if (!$player_in_guild) {
            $change_errors[] = 'This player isn\'t in your guild.';
          }
          if (!$rank_in_guild) {
            $change_errors[] = 'This rank isn\'t in your guild.';
          }
          if (!$player_has_lower_rank) {
            $change_errors[] = 'This player has higher rank in guild than you. You can\'t change his/her rank.';
          }
        }
        if (empty($change_errors)) {
          if ($player_to_change->isOnline()) {
            $change_errors[] = guild_online_error($player_to_change->getName());
          }
        }
        if (empty($change_errors)) {
          save_player_guild_membership($player_to_change, $rank);
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Rank of player <b>' .
            $player_to_change->getName() .
            '</b> has been changed to <b>' .
            $rank->getName() .
            '</b>.</td></tr>          </table>        </div>  </table></div></td></tr><br>';
          unset($players_with_lower_rank);
          unset($ranks);
          $rid = 0;
          $sid = 0;
          foreach ($rank_list as $rank) {
            if ($guild_leader || $rank->getLevel() < $level_in_guild) {
              $ranks[$rid]['0'] = $rank->getId();
              $ranks[$rid]['1'] = $rank->getName();
              $rid++;
              $players_with_rank = $rank->getPlayersList();
              $players_with_rank->orderBy('name');
              if (count($players_with_rank) > 0) {
                foreach ($players_with_rank as $player) {
                  if ($guild->getOwner()->getId() != $player->getId() || $guild_leader) {
                    $players_with_lower_rank[$sid]['0'] = $player->getName();
                    $players_with_lower_rank[$sid]['1'] = $player->getName() . ' (' . $rank->getName() . ')';
                    $sid++;
                  }
                }
              }
            }
          }
        } else {
          $main_content .=
            '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
            $layout_name .
            '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
          foreach ($change_errors as $change_error) {
            $main_content .= '<li>' . $change_error;
          }
          $main_content .=
            '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/>';
        }
      }
      $main_content .=
        '<FORM ACTION="?subtopic=guilds&action=changerank&guild=' .
        $guild_name .
        '&todo=save" METHOD=post>' .
        csrf_field() .
        '
		<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>
		<TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Change Rank</B></TD></TR>
		<TR BGCOLOR=' .
        $config['site']['darkborder'] .
        '><TD>Name: <SELECT NAME="name">';
      foreach ($players_with_lower_rank as $player_to_list) {
        $main_content .= '<OPTION value="' . $player_to_list['0'] . '">' . $player_to_list['1'];
      }
      $main_content .= '</SELECT>&nbsp;Rank:&nbsp;<SELECT NAME="rankid">';
      foreach ($ranks as $rank) {
        $main_content .= '<OPTION value="' . $rank['0'] . '">' . $rank['1'];
      }
      $main_content .=
        '</SELECT>&nbsp;&nbsp;&nbsp;<INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD><TR>
		</TABLE></FORM><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
    } else {
      $main_content .=
        'Error. You are not a leader or vice leader in guild ' .
        $guild->getName() .
        '.<FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></FORM>';
    }
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show guild page
if ($action == 'deleteinvite') {
  //set rights in guild
  $guild_name = (int) $_REQUEST['guild'];
  $name = stripslashes($_REQUEST['name']);
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t delete invitations.';
  }
  if (!check_name($name)) {
    $guild_errors[] = 'Invalid name format.';
  }
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    $rank_list = $guild->getGuildRanksList();
    $rank_list->orderBy('level', POT::ORDER_DESC);
    $guild_leader = false;
    $guild_vice = false;
    $account_players = $account_logged->getPlayers();
    foreach ($account_players as $player) {
      $player_rank = $player->getRank();
      if (!empty($player_rank)) {
        foreach ($rank_list as $rank_in_guild) {
          if ($rank_in_guild->getId() == $player_rank->getId()) {
            $players_from_account_in_guild[] = $player->getName();
            if ($player_rank->getLevel() > 1) {
              $guild_vice = true;
              $level_in_guild = $player_rank->getLevel();
            }
            if ($guild->getOwner()->getId() == $player->getId()) {
              $guild_vice = true;
              $guild_leader = true;
            }
          }
        }
      }
    }
  }
  if (empty($guild_errors)) {
    $player = new OTS_Player();
    $player->find($name);
    if (!$player->isLoaded()) {
      $guild_errors[] = 'Player with name <b>' . $name . '</b> doesn\'t exist.';
    }
  }
  if (!$guild_vice) {
    $guild_errors[] = 'You are not a leader or vice leader of guild <b>' . $guild_name . '</b>.';
  }
  if (empty($guild_errors)) {
    include 'pot/InvitesDriver.php';
    new InvitesDriver($guild);
    $invited_list = $guild->listInvites();
    if (count($invited_list) > 0) {
      $is_invited = false;
      foreach ($invited_list as $invited) {
        if ($invited->getName() == $player->getName()) {
          $is_invited = true;
        }
      }
      if (!$is_invited) {
        $guild_errors[] = '<b>' . $player->getName() . '</b> isn\'t invited to your guild.';
      }
    } else {
      $guild_errors[] = 'No one is invited to your guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    if ($_REQUEST['todo'] == 'save') {
      $guild->deleteInvite($player);
      $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Delete player invitation</B></TD></TR><TR BGCOLOR=' .
        $config['site']['darkborder'] .
        '><TD WIDTH=100%>Player with name <b>' .
        $player->getName() .
        '</b> has been deleted from "invites list".</TD></TR></TABLE><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
    } else {
      $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Delete player invitation</B></TD></TR><TR BGCOLOR=' .
        $config['site']['darkborder'] .
        '><TD WIDTH=100%>Are you sure you want to delete player with name <b>' .
        $player->getName() .
        '</b> from "invites list"?</TD></TR></TABLE><br/><center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><TR><FORM ACTION="?subtopic=guilds&action=deleteinvite&guild=' .
        $guild_name .
        '&name=' .
        $player->getName() .
        '&todo=save" METHOD=post>' .
        csrf_field() .
        '<TD align="right" width="50%"><INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18>&nbsp;&nbsp;</TD></FORM><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<TD>&nbsp;&nbsp;<INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD></TR></FORM></TABLE></center>';
    }
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show guild page
if ($action == 'invite') {
  //set rights in guild
  $guild_name = (int) $_REQUEST['guild'];
  $name = stripslashes($_REQUEST['name']);
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t invite players.';
  }
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    $rank_list = $guild->getGuildRanksList();
    $rank_list->orderBy('level', POT::ORDER_DESC);
    $guild_leader = false;
    $guild_vice = false;
    $account_players = $account_logged->getPlayers();
    foreach ($account_players as $player) {
      $player_rank = $player->getRank();
      if (!empty($player_rank)) {
        foreach ($rank_list as $rank_in_guild) {
          if ($rank_in_guild->getId() == $player_rank->getId()) {
            $players_from_account_in_guild[] = $player->getName();
            if ($player_rank->getLevel() > 1) {
              $guild_vice = true;
              $level_in_guild = $player_rank->getLevel();
            }
            if ($guild->getOwner()->getId() == $player->getId()) {
              $guild_vice = true;
              $guild_leader = true;
            }
          }
        }
      }
    }
  }
  if (!$guild_vice) {
    $guild_errors[] = 'You are not a leader or vice leader of guild <b>' . $guild_name . '</b>.' . $level_in_guild;
  }
  if ($_REQUEST['todo'] == 'save') {
    if (!check_name($name)) {
      $guild_errors[] = 'Invalid name format.';
    }
    if (empty($guild_errors)) {
      $player = new OTS_Player();
      $player->find($name);
      if (!$player->isLoaded()) {
        $guild_errors[] = 'Player with name <b>' . $name . '</b> doesn\'t exist.';
      } else {
        $rank_of_player = $player->getRank();
        if (!empty($rank_of_player)) {
          $guild_errors[] =
            'Player with name <b>' . $name . '</b> is already in guild. He must leave guild before you can invite him.';
        }
      }
    }
    if (empty($guild_errors) && $guild->getWorld() != $player->getWorld()) {
      $guild_errors[] = '<b>' . $player->getName() . '</b> is from other world then your guild.';
    }
    if (empty($guild_errors)) {
      include 'pot/InvitesDriver.php';
      new InvitesDriver($guild);
      $invited_list = $guild->listInvites();
      if (count($invited_list) > 0) {
        foreach ($invited_list as $invited) {
          if ($invited->getName() == $player->getName()) {
            $guild_errors[] = '<b>' . $player->getName() . '</b> is already invited to your guild.';
          }
        }
      }
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } elseif ($_REQUEST['todo'] == 'save') {
    $guild->invite($player);
    $main_content .=
      '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
      $config['site']['vdarkborder'] .
      '><TD CLASS=white><B>Invite player</B></TD></TR><TR BGCOLOR=' .
      $config['site']['darkborder'] .
      '><TD WIDTH=100%>Player with name <b>' .
      $player->getName() .
      '</b> has been invited to your guild.</TD></TR></TABLE><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    $main_content .=
      '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
      $config['site']['vdarkborder'] .
      '><TD CLASS=white><B>Invite player</B></TD></TR><TR BGCOLOR=' .
      $config['site']['darkborder'] .
      '><TD WIDTH=100%><FORM ACTION="?subtopic=guilds&action=invite&guild=' .
      $guild_name .
      '&todo=save" METHOD=post>' .
      csrf_field() .
      'Invite player with name:&nbsp;&nbsp;<INPUT TYPE="text" NAME="name">&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></FORM></TD></TD></TR></TR></TABLE><br/><center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><TR><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TD><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD></TR></FORM></TABLE></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show guild page
if ($action == 'acceptinvite') {
  //set rights in guild
  $guild_name = (int) $_REQUEST['guild'];
  $name = isset($_REQUEST['name']) ? stripslashes($_REQUEST['name']) : '';
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t accept invitations.';
  }
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }

  if (isset($_REQUEST['todo']) && $_REQUEST['todo'] == 'save') {
    if (!check_name($name)) {
      $guild_errors[] = 'Invalid name format.';
    }
    if (empty($guild_errors)) {
      $player = new OTS_Player();
      $player->find($name);
      if (!$player->isLoaded()) {
        $guild_errors[] = 'Player with name <b>' . $name . '</b> doesn\'t exist.';
      } else {
        if ($player->isOnline()) {
          $guild_errors[] =
            'Character <b>' .
            $name .
            '</b> is online. Logout from the game before accepting the invite.';
        }
        $rank_of_player = $player->getRank();
        if ($rank_of_player !== null && $rank_of_player->isLoaded()) {
          $guild_errors[] =
            'Character with name <b>' .
            $name .
            '</b> is already in guild. You must leave guild before you join other guild.';
        }
      }
    }
  }
  if (isset($_REQUEST['todo']) && $_REQUEST['todo'] == 'save') {
    if (empty($guild_errors)) {
      $is_invited = false;
      include_once 'pot/InvitesDriver.php';
      new InvitesDriver($guild);
      $invited_list = $guild->listInvites();
      if (count($invited_list) > 0) {
        foreach ($invited_list as $invited) {
          if ($invited->getName() == $player->getName()) {
            $is_invited = true;
          }
        }
      }
      if (!$is_invited) {
        $guild_errors[] =
          'Character ' . $player->getName() . ' isn\'t invited to guild <b>' . $guild->getName() . '</b>.';
      }
    }
  } else {
    //co jesli nei save
    if (empty($guild_errors)) {
      $acc_invited = false;
      $list_of_invited_players = array();
      $account_players = $account_logged->getPlayers();
      include_once 'pot/InvitesDriver.php';
      new InvitesDriver($guild);
      $invited_list = $guild->listInvites();
      if (count($invited_list) > 0) {
        foreach ($invited_list as $invited) {
          foreach ($account_players as $player_from_acc) {
            if ($invited->getName() == $player_from_acc->getName()) {
              $acc_invited = true;
              $list_of_invited_players[] = $player_from_acc;
            }
          }
        }
      }
    }
    if (empty($acc_invited)) {
      $guild_errors[] = 'Any character from your account isn\'t invited to <b>' . $guild->getName() . '</b>.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    if (isset($_REQUEST['todo']) && $_REQUEST['todo'] == 'save') {
      $guild->acceptInvite($player);
      $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Accept invitation</B></TD></TR><TR BGCOLOR=' .
        $config['site']['darkborder'] .
        '><TD WIDTH=100%>Player with name <b>' .
        $player->getName() .
        '</b> has been added to guild <b>' .
        $guild->getName() .
        '</b>.</TD></TR></TABLE><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
    } else {
      usort($list_of_invited_players, function ($a, $b) {
        return strcasecmp($a->getName(), $b->getName());
      });
      $offline_invites = 0;
      foreach ($list_of_invited_players as $invited_player_obj) {
        if (!$invited_player_obj->isOnline()) {
          $offline_invites++;
        }
      }
      $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Accept invitation</B></TD></TR>';
      $main_content .=
        '<TR BGCOLOR=' .
        $config['site']['lightborder'] .
        '><TD WIDTH=100%>Select character to join guild. Character must be <b>offline</b> in the game.</TD></TR>';
      $main_content .=
        '<TR BGCOLOR=' .
        $config['site']['darkborder'] .
        '><TD>';
      if ($offline_invites > 0) {
        $main_content .=
          '<form action="?subtopic=guilds&action=acceptinvite&guild=' .
          $guild_name .
          '&todo=save" METHOD="post">' .
          csrf_field();
      }
      foreach ($list_of_invited_players as $invited_player_obj) {
        $invited_name = $invited_player_obj->getName();
        $is_online = $invited_player_obj->isOnline();
        if ($is_online) {
          $main_content .=
            '<input type="radio" name="name" value="' .
            htmlspecialchars($invited_name) .
            '" disabled="disabled" />' .
            htmlspecialchars($invited_name) .
            ' <font color="red"><b>(Online - logout first)</b></font><br>';
        } else {
          $main_content .=
            '<input type="radio" name="name" value="' .
            htmlspecialchars($invited_name) .
            '" />' .
            htmlspecialchars($invited_name) .
            ' <font color="green"><b>(Offline)</b></font><br>';
        }
      }
      if ($offline_invites > 0) {
        $main_content .=
          '<br><INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
          $layout_name .
          '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></form>';
      } else {
        $main_content .=
          '<br><font color="red"><b>All invited characters from your account are online. Logout from the game, then refresh this page to accept.</b></font>';
        $main_content .=
          '<br><br><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><FORM ACTION="?subtopic=guilds&action=acceptinvite&guild=' .
          $guild_name .
          '" METHOD=post>' .
          csrf_field() .
          '<TR><TD><INPUT TYPE=image NAME="Refresh" ALT="Refresh" SRC="' .
          $layout_name .
          '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD></TR></FORM></TABLE>';
      }
      $main_content .=
        '</TD></TR></TABLE><br/><center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><TR><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<TD><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD></TR></FORM></TABLE></center>';
    }
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show guild page
if ($action == 'kickplayer') {
  //set rights in guild
  $guild_name = (int) $_REQUEST['guild'];
  $name = stripslashes($_REQUEST['name']);
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t kick characters.';
  }
  if (!check_name($name)) {
    $guild_errors[] = 'Invalid name format.';
  }
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with name <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    $rank_list = $guild->getGuildRanksList();
    $rank_list->orderBy('level', POT::ORDER_DESC);
    $guild_leader = false;
    $guild_vice = false;
    $account_players = $account_logged->getPlayers();
    foreach ($account_players as $player) {
      $player_rank = $player->getRank();
      if (!empty($player_rank)) {
        foreach ($rank_list as $rank_in_guild) {
          if ($rank_in_guild->getId() == $player_rank->getId()) {
            $players_from_account_in_guild[] = $player->getName();
            if ($player_rank->getLevel() > 1) {
              $guild_vice = true;
              $level_in_guild = $player_rank->getLevel();
            }
            if ($guild->getOwner()->getId() == $player->getId()) {
              $guild_vice = true;
              $guild_leader = true;
            }
          }
        }
      }
    }
  }
  if (empty($guild_errors)) {
    if (!$guild_leader && $level_in_guild < 3) {
      $guild_errors[] = 'You are not a leader of guild <b>' . $guild_name . '</b>. You can\'t kick players.';
    }
  }
  if (empty($guild_errors)) {
    $player = new OTS_Player();
    $player->find($name);
    if (!$player->isLoaded()) {
      $guild_errors[] = 'Character <b>' . $name . '</b> doesn\'t exist.';
    } else {
      if ($player->getRank()->getGuild()->getName() != $guild->getName()) {
        $guild_errors[] = 'Character <b>' . $name . '</b> isn\'t from your guild.';
      }
    }
  }
  if (empty($guild_errors)) {
    if ($player->getRank()->getLevel() >= $level_in_guild && !$guild_leader) {
      $guild_errors[] = 'You can\'t kick character <b>' . $name . '</b>. Too high access level.';
    }
  }
  if (empty($guild_errors)) {
    if ($guild->getOwner()->getName() == $player->getName()) {
      $guild_errors[] = 'It\'s not possible to kick guild owner!';
    }
  }
  if (empty($guild_errors) && $player->isOnline()) {
    $guild_errors[] = guild_online_error($player->getName());
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } elseif ($_REQUEST['todo'] == 'save') {
    save_player_guild_membership($player);
    $main_content .=
      '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
      $config['site']['vdarkborder'] .
      '><TD CLASS=white><B>Kick player</B></TD></TR><TR BGCOLOR=' .
      $config['site']['darkborder'] .
      '><TD WIDTH=100%>Player with name <b>' .
      $player->getName() .
      '</b> has been kicked from your guild.</TD></TR></TABLE><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    $main_content .=
      '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
      $config['site']['vdarkborder'] .
      '><TD CLASS=white><B>Kick player</B></TD></TR><TR BGCOLOR=' .
      $config['site']['darkborder'] .
      '><TD WIDTH=100%>Are you sure you want to kick player with name <b>' .
      $player->getName() .
      '</b> da sua guilda?</TD></TR></TABLE><br/><center><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><TR><FORM ACTION="?subtopic=guilds&action=kickplayer&guild=' .
      $guild_name .
      '&name=' .
      $player->getName() .
      '&todo=save" METHOD=post>' .
      csrf_field() .
      '<TD align="right" width="50%"><INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18>&nbsp;&nbsp;</TD></FORM><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TD>&nbsp;&nbsp;<INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></TD></TR></FORM></TABLE></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//show guild page
if ($action == 'leaveguild') {
  //set rights in guild
  $guild_name = (int) $_REQUEST['guild'];
  $name = stripslashes($_REQUEST['name']);
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t leave guild.';
  }
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }

  if (empty($guild_errors)) {
    $guild_owner_id = $guild->getOwner()->getId();
    if ($_REQUEST['todo'] == 'save') {
      if (!check_name($name)) {
        $guild_errors[] = 'Invalid name format.';
      }
      if (empty($guild_errors)) {
        $player = new OTS_Player();
        $player->find($name);
        if (!$player->isLoaded()) {
          $guild_errors[] = 'Character <b>' . $name . '</b> doesn\'t exist.';
        } elseif ($player->getAccount()->getId() != $account_logged->getId()) {
          $guild_errors[] = 'Character <b>' . $name . '</b> isn\'t from your account!';
        }
      }
      if (empty($guild_errors)) {
        $player_loaded_rank = $player->getRank();
        if (!empty($player_loaded_rank) && $player_loaded_rank->isLoaded()) {
          if ($player_loaded_rank->getGuild()->getId() != $guild->getId()) {
            $guild_errors[] = 'Character <b>' . $name . '</b> isn\'t from guild <b>' . $guild->getName() . '</b>.';
          }
        } else {
          $guild_errors[] = 'Character <b>' . $name . '</b> isn\'t in any guild.';
        }
      }
      if (empty($guild_errors)) {
        if ($guild_owner_id == $player->getId()) {
          $guild_errors[] = 'You can\'t leave guild. You are an owner of guild.';
        }
      }
      if (empty($guild_errors) && $player->isOnline()) {
        $guild_errors[] = guild_online_error($player->getName());
      }
    } else {
      $account_players = $account_logged->getPlayers();
      $array_of_player_ig = array();
      $array_of_player_ig_online = array();
      foreach ($account_players as $player_fac) {
        $player_rank = $player_fac->getRank();
        if (!empty($player_rank)) {
          if ($player_rank->getGuild()->getId() == $guild->getId()) {
            if ($guild_owner_id != $player_fac->getId()) {
              if ($player_fac->isOnline()) {
                $array_of_player_ig_online[] = $player_fac->getName();
              } else {
                $array_of_player_ig[] = $player_fac->getName();
              }
            }
          }
        }
      }
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    if ($_REQUEST['todo'] == 'save') {
      save_player_guild_membership($player);
      $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Leave guild</B></TD></TR><TR BGCOLOR=' .
        $config['site']['darkborder'] .
        '><TD WIDTH=100%>Player with name <b>' .
        $player->getName() .
        '</b> leaved guild <b>' .
        $guild->getName() .
        '</b>.</TD></TR></TABLE><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<TR><TD><center><INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
    } else {
      $main_content .=
        '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
        $config['site']['vdarkborder'] .
        '><TD CLASS=white><B>Leave guild</B></TD></TR>';
      if (count($array_of_player_ig) > 0) {
        $main_content .=
          '<TR BGCOLOR=' .
          $config['site']['lightborder'] .
          '><TD WIDTH=100%>Select character to leave guild. Character must be <b>offline</b>.</TD></TR>';
        $main_content .=
          '<TR BGCOLOR=' .
          $config['site']['darkborder'] .
          '><TD>
				<form action="?subtopic=guilds&action=leaveguild&guild=' .
          $guild_name .
          '&todo=save" METHOD="post">' .
          csrf_field() .
          '';
        sort($array_of_player_ig);
        foreach ($array_of_player_ig as $player_to_leave) {
          $main_content .=
            '<input type="radio" name="name" value="' .
            htmlspecialchars($player_to_leave) .
            '" />' .
            htmlspecialchars($player_to_leave) .
            ' <font color="green"><b>(Offline)</b></font><br>';
        }
        if (!empty($array_of_player_ig_online)) {
          sort($array_of_player_ig_online);
          foreach ($array_of_player_ig_online as $player_online_leave) {
            $main_content .=
              '<input type="radio" name="name" value="' .
              htmlspecialchars($player_online_leave) .
              '" disabled="disabled" />' .
              htmlspecialchars($player_online_leave) .
              ' <font color="red"><b>(Online - logout first)</b></font><br>';
          }
        }
        $main_content .= '</TD></TR><br></TABLE>';
      } elseif (!empty($array_of_player_ig_online)) {
        $main_content .=
          '<TR BGCOLOR=' .
          $config['site']['lightborder'] .
          '><TD WIDTH=100%>All characters that can leave this guild are online. Logout first, then refresh this page.</TD></TR>';
      } else {
        $main_content .=
          '<TR BGCOLOR=' .
          $config['site']['lightborder'] .
          '><TD WIDTH=100%>Any of your characters can\'t leave guild.</TD></TR>';
      }
      $main_content .= '<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><tr>';
      if (count($array_of_player_ig) > 0) {
        $main_content .=
          '<td width="130" valign="top"><INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
          $layout_name .
          '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></form></td>';
      }
      $main_content .=
        '<td><FORM ACTION="?subtopic=guilds&action=show&guild=' .
        $guild_name .
        '" METHOD=post>' .
        csrf_field() .
        '<INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
        $layout_name .
        '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></FORM></td></tr></table>';
    }
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//create guild
if ($action == 'createguild') {
  $guild_name = $_REQUEST['guild'] ?? '';
  $name = stripslashes($_REQUEST['name'] ?? '');
  $todo = $_REQUEST['todo'] ?? '';
  $array_of_player_nig = [];
  if (!$logged) {
    $guild_errors[] = 'You are not logged in. You can\'t create guild.';
  }
  if (empty($guild_errors)) {
    $account_players = $account_logged->getPlayers();
    foreach ($account_players as $player) {
      $player_rank = $player->getRank();
      if (empty($player_rank)) {
        if ($player->getLevel() >= $config['site']['guild_need_level']) {
          if (!$config['site']['guild_need_pacc'] || $account_logged->isPremium()) {
            if (!$player->isOnline()) {
              $array_of_player_nig[] = $player->getName();
            }
          }
        }
      }
    }
  }

  if (empty($todo)) {
    if ($logged && count($array_of_player_nig) == 0) {
      $guild_errors[] =
        'On your account all characters are in guilds, online, or have too low level to create new guild. Logout the leader character first.';
    }
  }
  if ($todo == 'save') {
    if (!check_guild_name($guild_name)) {
      $guild_errors[] = 'Invalid guild name format.';
      $guild_name = '';
    }
    if (!check_name($name)) {
      $guild_errors[] = 'Invalid character name format.';
      $name = '';
    }
    if (empty($guild_errors)) {
      $player = $ots->createObject('Player');
      $player->find($name);
      if (!$player->isLoaded()) {
        $guild_errors[] = 'Character <b>' . $name . '</b> doesn\'t exist.';
      }
    }
    if (empty($guild_errors)) {
      $guild = $ots->createObject('Guild');
      $guild->find($guild_name);
      if ($guild->isLoaded()) {
        $guild_errors[] = 'Guild <b>' . $guild_name . '</b> already exist. Select other name.';
      }
    }
    if (empty($guild_errors)) {
      $bad_char = true;
      foreach ($array_of_player_nig as $nick_from_list) {
        if ($nick_from_list == $player->getName()) {
          $bad_char = false;
        }
      }
      if ($bad_char) {
        $guild_errors[] = 'Character <b>' . $name . '</b> isn\'t on your account or is already in guild.';
      }
    }
    if (empty($guild_errors)) {
      if ($player->isOnline()) {
        $guild_errors[] = guild_online_error($player->getName());
      }
      if ($player->getLevel() < $config['site']['guild_need_level']) {
        $guild_errors[] =
          'Character <b>' .
          $name .
          '</b> has too low level. To create guild you need character with level <b>' .
          $config['site']['guild_need_level'] .
          '</b>.';
      }
      if ($config['site']['guild_need_pacc'] && !$account_logged->isPremium()) {
        $guild_errors[] =
          'Character <b>' . $name . '</b> is on FREE account. To create guild you need PREMIUM account.';
      }
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    unset($todo);
  }

  if (($todo ?? '') == 'save') {
    $new_guild = new OTS_Guild();
    $new_guild->setCreationData(time());
    $new_guild->setName($guild_name);
    $new_guild->setOwner($player);
    $new_guild->save();
    $new_guild->setCustomField('description', 'New guild. Leader must edit this text :)');
    $new_guild->setCustomField('creationdata', time());
    $new_guild->setCustomField('world_id', $player->getWorld());
    $ranks = $new_guild->getGuildRanksList();
    $ranks->orderBy('level', POT::ORDER_DESC);
    foreach ($ranks as $rank) {
      if ($rank->getLevel() == 3) {
        save_player_guild_membership($player, $rank);
      }
    }
    $main_content .=
      '<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%><TR BGCOLOR=' .
      $config['site']['vdarkborder'] .
      '><TD CLASS=white><B>Create guild</B></TD></TR><TR BGCOLOR=' .
      $config['site']['darkborder'] .
      '><TD WIDTH=100%><b>Congratulations!</b><br/>You have created guild <b>' .
      $guild_name .
      '</b>. <b>' .
      $player->getName() .
      '</b> is leader of this guild. Now you can invite players, change picture, description and motd of guild. Press submit to open guild manager.</TD></TR></TABLE><br/><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH=100%><FORM ACTION="?subtopic=guilds&action=show&guild=' .
      $new_guild->getId() .
      '" METHOD=post>' .
      csrf_field() .
      '<TR><TD><center><INPUT TYPE=image NAME="Submit" ALT="Submit" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_Submit.gif" BORDER=0 WIDTH=120 HEIGHT=18></center></TD></TR></FORM></TABLE>';
  } else {
    $main_content .=
      'To play on ' .
      $config['server']['serverName'] .
      ' you need an account. 
		All you have to do to create your new account is to enter your email address, password to new account, verification code from picture and to agree to the terms presented below. 
		If you have done so, your account number, password and e-mail address will be shown on the following page and your account and password will be sent 
		to your email address along with further instructions.<BR><BR>
		<FORM ACTION="?subtopic=guilds&action=createguild&todo=save" METHOD=post>' .
      csrf_field() .
      '
		<TABLE WIDTH=100% BORDER=0 CELLSPACING=1 CELLPADDING=4>
		<TR><TD BGCOLOR="' .
      $config['site']['vdarkborder'] .
      '" CLASS=white><B>Create a ' .
      $config['server']['serverName'] .
      ' Account</B></TD></TR>
		<TR><TD BGCOLOR="' .
      $config['site']['darkborder'] .
      '"><TABLE BORDER=0 CELLSPACING=8 CELLPADDING=0>
		  <TR><TD>
		    <TABLE BORDER=0 CELLSPACING=5 CELLPADDING=0>';
    $main_content .= '<TR><TD width="150" valign="top"><B>Leader: </B></TD><TD><SELECT name=\'name\'>';
    if (count($array_of_player_nig) > 0) {
      sort($array_of_player_nig);
      foreach ($array_of_player_nig as $nick) {
        $main_content .= '<OPTION>' . $nick . '</OPTION>';
      }
    }
    $main_content .=
      '</SELECT><BR><font size="1" face="verdana,arial,helvetica">(Name of leader of new guild.)</font></TD></TR>
			<TR><TD width="150" valign="top"><B>Guild name: </B></TD><TD><INPUT NAME="guild" VALUE="" SIZE=30 MAXLENGTH=50><BR><font size="1" face="verdana,arial,helvetica">(Here write name of your new guild.)</font></TD></TR>
			</TABLE>
		  </TD></TR>
		</TABLE></TD></TR>
		</TABLE>
		<BR>
		<TABLE BORDER=0 WIDTH=100%>
		  <TR><TD ALIGN=center>
		    <IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=120 HEIGHT=1 BORDER=0><BR>
		  </TD><TD ALIGN=center VALIGN=top>
		    <INPUT TYPE=image NAME="Submit" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_submit.gif" BORDER=0 WIDTH=120 HEIGHT=18>
		    </FORM>
		  </TD><TD ALIGN=center>
		    <FORM  ACTION="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '
		    <INPUT TYPE=image NAME="Back" ALT="Back" SRC="' .
      $layout_name .
      '/images/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18>
		    </FORM>
		  </TD><TD ALIGN=center>
		    <IMG SRC="/images/general/blank.gif" WIDTH=120 HEIGHT=1 BORDER=0><BR>
		  </TD></TR>
		</TABLE>
		</TD>
		<TD><IMG SRC="' .
      $layout_name .
      '/images/general/blank.gif" WIDTH=10 HEIGHT=1 BORDER=0></TD>
		</TR>
		</TABLE>';
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'manager') {
  $guild_name = (int) $_REQUEST['guild'];
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild_leader_char->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        $main_content .=
          '<center><h2>Welcome to guild manager!</h2></center>Here you can change names of ranks, delete and add ranks, pass leadership to other guild member and delete guild.';
        $main_content .=
          '<br/><br/><table style=\'clear:both\' border=0 cellpadding=0 cellspacing=0 width=\'100%\'>
				<tr bgcolor=' .
          $config['site']['darkborder'] .
          '><td width="170"><font color="red"><b>Option</b></font></td><td><font color="red"><b>Description</b></font></td></tr>
				<tr bgcolor=' .
          $config['site']['lightborder'] .
          '><td width="170"><b><a href="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=passleadership">Pass Leadership</a></b></td><td><b>Pass leadership of guild to other guild member.</b></td></tr>
				<tr bgcolor=' .
          $config['site']['darkborder'] .
          '><td width="170"><b><a href="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=deleteguild">Delete Guild</a></b></td><td><b>Delete guild, kick all members.</b></td></tr>
				<tr bgcolor=' .
          $config['site']['lightborder'] .
          '><td width="170"><b><a href="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=changedescription">Change Description</a></b></td><td><b>Change description of guild.</b></td></tr>
				<tr bgcolor=' .
          $config['site']['darkborder'] .
          '><td width="170"><b><a href="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=changemotd">Change MOTD</a></b></td><td><b>Change MOTD of guild.</b></td></tr>
				<tr bgcolor=' .
          $config['site']['lightborder'] .
          '><td width="170"><b><a href="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=changelogo">Change guild logo</a></b></td><td><b>Upload new guild logo.</b></td></tr>
				</table>';
        $main_content .=
          '<br><div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
          $layout_name .
          '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
          $layout_name .
          '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
          $layout_name .
          '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
          $layout_name .
          '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Add new rank</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
          $layout_name .
          '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
          $layout_name .
          '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
          $layout_name .
          '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
          $layout_name .
          '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td width="120" valign="top">New rank name:</td><td> <form action="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=addrank" method="POST">' .
          csrf_field() .
          '<input type="text" name="rank_name" size="20"><input type="submit" value="Add"></form></td></tr>          </table>        </div>  </table></div></td></tr>';
        $main_content .=
          '<center><h3>Change rank names and levels</h3></center><form action="?subtopic=guilds&action=saveranks&guild=' .
          $guild_name .
          '" method=POST>' .
          csrf_field() .
          '<table style=\'clear:both\' border=0 cellpadding=0 cellspacing=0 width=\'100%\'><tr bgcolor=' .
          $config['site']['vdarkborder'] .
          '><td rowspan="2" width="120" align="center"><font color="white"><b>Delete Rank</b></font></td><td rowspan="2" width="300"><font color="white"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Name</b></font></td><td colspan="3" align="center"><font color="white"><b>Level of RANK in guild</b></font></td></tr><tr bgcolor=' .
          $config['site']['vdarkborder'] .
          '><td align="center" bgcolor="red"><font color="white"><b>Leader (3)</b></font></td><td align="center" bgcolor="yellow"><font color="black"><b>Vice (2)</b></font></td><td align="center" bgcolor="green"><font color="white"><b>Member (1)</b></font></td></tr>';
        foreach ($rank_list as $rank) {
          if (is_int($number_of_rows / 2)) {
            $bgcolor = $config['site']['darkborder'];
          } else {
            $bgcolor = $config['site']['lightborder'];
          }
          $number_of_rows++;
          $main_content .=
            '<tr bgcolor="' .
            $bgcolor .
            '"><td align="center">' .
            csrf_post_action(
              '?subtopic=guilds&guild=' . $guild_name . '&action=deleterank',
              '<img src="' . $layout_name . '/images/news/delete.png" border="0" alt="Delete Rank">',
              ['rankid' => $rank->getId()]
            ) .
            '</td><td><input type="text" name="' .
            $rank->getId() .
            '_name" value="' .
            $rank->getName() .
            '" size="35"></td><td align="center"><input type="radio" name="' .
            $rank->getId() .
            '_level" value="3"';
          if ($rank->getLevel() == 3) {
            $main_content .= ' checked="checked"';
          }
          $main_content .=
            ' /></td><td align="center"><input type="radio" name="' . $rank->getId() . '_level" value="2"';
          if ($rank->getLevel() == 2) {
            $main_content .= ' checked="checked"';
          }
          $main_content .=
            ' /></td><td align="center"><input type="radio" name="' . $rank->getId() . '_level" value="1"';
          if ($rank->getLevel() == 1) {
            $main_content .= ' checked="checked"';
          }
          $main_content .= ' /></td></tr>';
        }
        $main_content .=
          '<tr bgcolor=' .
          $config['site']['vdarkborder'] .
          '><td>&nbsp;</td><td>&nbsp;</td><td colspan="3" align="center"><input type="submit" value="Save All"></td></tr></table></form>';
        $main_content .= '<h3>Ranks info:</h3><b>0. Owner of guild</b> - it\'s highest rank, only one player in guild may has this rank. Player with this rank can:
				<li>Invite/Cancel Invitation/Kick Player from guild
				<li>Change ranks of all players in guild
				<li>Delete guild or pass leadership to other guild member
				<li>Change names, levels(leader,vice,member), add and delete ranks
				<li>Change MOTD, logo and description of guild<hr>
				<b>3. Leader</b> - it\'s second rank in guild. Player with this rank can:
				<li>Invite/Cancel Invitation/Kick Player from guild (only with lower rank than his)
				<li>Change ranks of players with lower rank level ("vice leader", "member") in guild<hr>
				<b>2. Vice Leader</b> - it\'s third rank in guild. Player with this rank can:
				<li>Invite/Cancel Invitation
				<li>Change ranks of players with lower rank level ("member") in guild<hr>
				<b>1. Member</b> - it\'s lowest rank in guild. Player with this rank can:
				<li>Be a member of guild';
        $main_content .=
          '<br/><center><form action="?subtopic=guilds&action=show&guild=' .
          $guild_name .
          '" METHOD=post>' .
          csrf_field() .
          '<div class="BigButton" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
          $layout_name .
          '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'changelogo') {
  $guild_name = (int) $_REQUEST['guild'];
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with name <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild_leader_char->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        $max_image_size_b = $config['site']['guild_image_size_kb'] * 1024;
        $allowed_ext = ['image/gif', 'image/jpg', 'image/pjpeg', 'image/jpeg', 'image/bmp', 'image/png', 'image/x-png'];
        $ext_name = [
          'image/gif' => 'gif',
          'image/jpg' => 'jpg',
          'image/jpeg' => 'jpg',
          'image/pjpeg' => 'jpg',
          'image/bmp' => 'bmp',
          'image/png' => 'png',
          'image/x-png' => 'png'
        ];
        $save_file_name = str_replace(' ', '_', strtolower($guild->getName()));
        $save_path = 'guilds/' . $save_file_name;
        if ($_REQUEST['todo'] == 'save') {
          $file = $_FILES['newlogo'];
          if (is_uploaded_file($file['tmp_name'])) {
            if ($file['size'] > $max_image_size_b) {
              $upload_errors[] =
                'Uploaded image is too big. Size: <b>' .
                $file['size'] .
                ' bytes</b>, Max. size: <b>' .
                $max_image_size_b .
                ' bytes</b>.';
            }
            $imginfo = @getimagesize($file['tmp_name']);
            $allowed_img = [IMAGETYPE_GIF => 'gif', IMAGETYPE_JPEG => 'jpg', IMAGETYPE_PNG => 'png'];
            if ($imginfo === false || !isset($allowed_img[$imginfo[2]])) {
              $upload_errors[] = 'Your file type isn\' allowed. Allowed: <b>gif, jpg, png</b>.';
            } else {
              $extension = $allowed_img[$imginfo[2]];
            }
          } else {
            $upload_errors[] =
              'You didn\'t send file or file is too big. Limit: <b>' .
              $config['site']['guild_image_size_kb'] .
              ' KB</b>.';
          }
          if (empty($upload_errors)) {
            if (!move_uploaded_file($file['tmp_name'], $save_path . '.' . $extension)) {
              $upload_errors[] = 'Sorry! Can\'t save your image.';
            }
          }
          if (empty($upload_errors)) {
            $guild_logo = $guild->getCustomField('logo_gfx_name');
            foreach (['/', '\\', '..'] as $char) {
              $guild_logo = str_replace($char, '', (string) $guild_logo);
            }
            $guild_logo = basename((string) $guild_logo);
            if (empty($guild_logo) || !file_exists('guilds/' . $guild_logo)) {
              $guild_logo = 'default_logo.gif';
            }
            if ($guild_logo != 'default_logo.gif' && $guild_logo != $save_file_name . '.' . $extension) {
              $unlink_path = realpath('guilds/' . $guild_logo);
              $guilds_root = realpath('guilds');
              if (
                $unlink_path !== false &&
                $guilds_root !== false &&
                str_starts_with($unlink_path, $guilds_root . DIRECTORY_SEPARATOR)
              ) {
                unlink($unlink_path);
              }
            }
          }
          //show errors or save file
          if (!empty($upload_errors)) {
            $main_content .=
              '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
              $layout_name .
              '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
            foreach ($upload_errors as $guild_error) {
              $main_content .= '<li>' . $guild_error;
            }
            $main_content .=
              '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
          } else {
            $guild->setCustomField('logo_gfx_name', $save_file_name . '.' . $extension);
          }
        }
        $guild_logo = $guild->getCustomField('logo_gfx_name');
        if (empty($guild_logo) || !file_exists('guilds/' . $guild_logo)) {
          $guild_logo = 'default_logo.gif';
        }
        $main_content .=
          '<center><h2>Change guild logo</h2></center>Here you can change logo of your guild.<BR>Actuall logo: <img src="guilds/' .
          $guild_logo .
          '" HEIGHT="64" WIDTH="64"><BR><BR>';
        $main_content .=
          '<form enctype="multipart/form-data" action="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=changelogo" method="POST">' .
          csrf_field() .
          '
				<input type="hidden" name="todo" value="save" />
				<input type="hidden" name="MAX_FILE_SIZE" value="' .
          $max_image_size_b .
          '" />
				    Select new logo: <input name="newlogo" type="file" />
				    <input type="submit" value="Send new logo" /></form>Only <b>jpg, gif, png, bmp</b> pictures. Max. size: <b>' .
          $config['site']['guild_image_size_kb'] .
          ' KB</b><br>';
        $main_content .=
          '<br/><center><form action="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=manager" METHOD=post>' .
          csrf_field() .
          '<div class="BigButton" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
          $layout_name .
          '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'deleterank') {
  $guild_name = (int) $_REQUEST['guild'];
  $rank_to_delete = (int) $_REQUEST['rankid'];
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with name <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild->getOwner()->getId() == $player->getId()) {
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        $rank = new OTS_GuildRank();
        $rank->load($rank_to_delete);
        if (!$rank->isLoaded()) {
          $guild_errors2[] = 'Rank with ID ' . $rank_to_delete . ' doesn\'t exist.';
        } else {
          if ($rank->getGuild()->getId() != $guild->getId()) {
            $guild_errors2[] = 'Rank with ID ' . $rank_to_delete . ' isn\'t from your guild.';
          } else {
            if (count($rank_list) < 2) {
              $guild_errors2[] = 'You have only 1 rank in your guild. You can\'t delete this rank.';
            } else {
              $players_with_rank = $rank->getPlayersList();
              $players_with_rank_number = count($players_with_rank);
              if ($players_with_rank_number > 0) {
                foreach ($players_with_rank as $player_online_check) {
                  if ($player_online_check->isOnline()) {
                    $guild_errors2[] = guild_online_error($player_online_check->getName());
                    break;
                  }
                }
              }
              if (empty($guild_errors2) && $players_with_rank_number > 0) {
                foreach ($rank_list as $checkrank) {
                  if ($checkrank->getId() != $rank->getId()) {
                    if ($checkrank->getLevel() <= $rank->getLevel()) {
                      $new_rank = $checkrank;
                    }
                  }
                }
                if (empty($new_rank)) {
                  $new_rank = new OTS_GuildRank();
                  $new_rank->setGuild($guild);
                  $new_rank->setLevel($rank->getLevel());
                  $new_rank->setName('New Rank level ' . $rank->getLevel());
                  $new_rank->save();
                }
                foreach ($players_with_rank as $player_in_guild) {
                  save_player_guild_membership($player_in_guild, $new_rank);
                }
              }
              if (empty($guild_errors2)) {
                $rank->delete();
                $saved = true;
              }
            }
          }
        }
        if ($saved) {
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Rank Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Rank <b>' .
            $rank->getName() .
            '</b> has been deleted. Players with this rank has now other rank.</td></tr>          </table>        </div>  </table></div></td></tr>';
        } else {
          $main_content .=
            '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
            $layout_name .
            '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
          foreach ($guild_errors2 as $guild_error) {
            $main_content .= '<li>' . $guild_error;
          }
          $main_content .=
            '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
        }
        //back button
        $main_content .=
          '<br/><center><form action="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=manager" METHOD=post>' .
          csrf_field() .
          '<div class="BigButton" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
          $layout_name .
          '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'addrank') {
  $guild_name = (int) $_REQUEST['guild'];
  $ranknew = $_REQUEST['rank_name'];
  if (empty($guild_errors)) {
    if (!check_rank_name($ranknew)) {
      $guild_errors[] = 'Invalid rank name format.';
    }
    if (!$logged) {
      $guild_errors[] = 'You are not logged.';
    }
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with name <b>' . $guild_name . '</b> doesn\'t exist.';
    }
    if (empty($guild_errors)) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild_leader_char->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        $new_rank = new OTS_GuildRank();
        $new_rank->setGuild($guild);
        $new_rank->setLevel(1);
        $new_rank->setName($ranknew);
        $new_rank->save();
        header('Location: ?subtopic=guilds&guild=' . $guild_name . '&action=manager');
        $main_content .= 'New rank added. Redirecting...';
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    }
    if (!empty($guild_errors)) {
      $main_content .=
        '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
        $layout_name .
        '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
      foreach ($guild_errors as $guild_error) {
        $main_content .= '<li>' . $guild_error;
      }
      $main_content .=
        '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
        $layout_name .
        '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
      $main_content .=
        '<br/><center><form action="?subtopic=guilds&guild=' .
        $guild_name .
        '&action=show" METHOD=post>' .
        csrf_field() .
        '<div class="BigButton" style="background-image:url(' .
        $layout_name .
        '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
        $layout_name .
        '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
        $layout_name .
        '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
    }
  } elseif (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'changedescription') {
  $guild_id = (int) $_REQUEST['guild'];
  $saved = false;
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_id);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_id . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild->getOwner()->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        if (isset($_REQUEST['todo']) && $_REQUEST['todo'] == 'save') {
          $description = stripslashes(
            substr(trim($_REQUEST['description'] ?? ''), 0, $config['site']['guild_description_chars_limit'])
          );
          $guild->setCustomField('description', $description);
          $saved = true;
        }
        $main_content .= '<center><h2>Change guild description</h2></center>';
        if ($saved) {
          $main_content .= '<center><font color="red" size="3"><b>CHANGES HAS BEEN SAVED!</b></font></center><br>';
        }
        $description_rows = max(1, (int) $config['site']['guild_description_lines_limit'] - 1);
        $main_content .= 'Here you can change description of your guild.<BR>';
        $main_content .=
          '<form enctype="multipart/form-data" action="?subtopic=guilds&guild=' .
          $guild_id .
          '&action=changedescription" method="POST">' .
          csrf_field() .
          '
				<input type="hidden" name="todo" value="save" />
				    <textarea name="description" cols="60" rows="' .
          $description_rows .
          '">' .
          htmlspecialchars((string) $guild->getCustomField('description')) .
          '</textarea><br>
				    (max. ' .
          $config['site']['guild_description_lines_limit'] .
          ' lines, max. ' .
          $config['site']['guild_description_chars_limit'] .
          ' chars) <input type="submit" value="Save description" /></form><br>';
        $main_content .=
          '<br/><center><form action="?subtopic=guilds&guild=' .
          $guild_id .
          '&action=manager" METHOD=post>' .
          csrf_field() .
          '<div class="BigButton" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
          $layout_name .
          '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'passleadership') {
  $guild_name = (int) $_REQUEST['guild'];
  $pass_to = stripslashes(trim($_REQUEST['player']));
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($_POST['todo'] == 'save') {
      if (!check_name($pass_to)) {
        $guild_errors2[] = 'Invalid player name format.';
      }
      if (empty($guild_errors2)) {
        $to_player = new OTS_Player();
        $to_player->find($pass_to);
        if (!$to_player->isLoaded()) {
          $guild_errors2[] = 'Player with name <b>' . $pass_to . '</b> doesn\'t exist.';
        }
        if (empty($guild_errors2)) {
          $to_player_rank = $to_player->getRank();
          if (!empty($to_player_rank)) {
            $to_player_guild = $to_player_rank->getGuild();
            if ($to_player_guild->getId() != $guild->getId()) {
              $guild_errors2[] = 'Player with name <b>' . $to_player->getName() . '</b> isn\'t from your guild.';
            }
          } else {
            $guild_errors2[] = 'Player with name <b>' . $to_player->getName() . '</b> isn\'t from your guild.';
          }
        }
        if (empty($guild_errors2) && $to_player->isOnline()) {
          $guild_errors2[] = guild_online_error($to_player->getName());
        }
        if (empty($guild_errors2)) {
          $old_owner = $guild->getOwner();
          if ($old_owner->isLoaded() && $old_owner->isOnline()) {
            $guild_errors2[] = guild_online_error($old_owner->getName());
          }
        }
      }
    }
  }
  if (empty($guild_errors) && empty($guild_errors2)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild_leader_char->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        if ($_POST['todo'] == 'save') {
          // New owner takes Leader. Old owner takes the new owner's previous rank (swap).
          // Fallback: Vice, then Member, then create Vice-Leader if ranks were deleted.
          $leader_rank = null;
          $demote_rank = null;
          if (!empty($to_player_rank) && $to_player_rank->isLoaded() && $to_player_rank->getLevel() < 3) {
            $demote_rank = $to_player_rank;
          }
          foreach ($guild->getGuildRanksList() as $guild_rank) {
            if ($guild_rank->getLevel() == 3) {
              $leader_rank = $guild_rank;
            }
            if ($demote_rank === null && $guild_rank->getLevel() == 2) {
              $demote_rank = $guild_rank;
            }
          }
          if ($demote_rank === null) {
            foreach ($guild->getGuildRanksList() as $guild_rank) {
              if ($guild_rank->getLevel() == 1) {
                $demote_rank = $guild_rank;
                break;
              }
            }
          }
          if ($demote_rank === null) {
            $demote_rank = new OTS_GuildRank();
            $demote_rank->setGuild($guild);
            $demote_rank->setLevel(2);
            $demote_rank->setName('Vice-Leader');
            $demote_rank->save();
          }
          $guild->setOwner($to_player);
          $guild->save();
          if ($leader_rank) {
            save_player_guild_membership($to_player, $leader_rank);
          }
          if ($guild_leader_char->isLoaded()) {
            save_player_guild_membership($guild_leader_char, $demote_rank);
          }
          $saved = true;
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td><b>' .
            $to_player->getName() .
            '</b> is now a Leader of <b>' .
            $guild->getName() .
            '</b>.</td></tr>          </table>        </div>  </table></div></td></tr><br/><center><form action="?subtopic=guilds&guild=' .
            $guild_name .
            '&action=show" METHOD=post>' .
            csrf_field() .
            '<div class="BigButton" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
            $layout_name .
            '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
        } else {
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Pass leadership to: </b><br>
					<form action="?subtopic=guilds&guild=' .
            $guild_name .
            '&action=passleadership" METHOD=post>' .
            csrf_field() .
            '<input type="hidden" name="todo" value="save"><input type="text" size="40" name="player"><input type="submit" value="Save"></form>
					</td></tr>          </table>        </div>  </table></div></td></tr><br/><center><form action="?subtopic=guilds&guild=' .
            $guild_name .
            '&action=manager" METHOD=post>' .
            csrf_field() .
            '<div class="BigButton" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
            $layout_name .
            '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
        }
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (empty($guild_errors) && !empty($guild_errors2)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors2 as $guild_error2) {
      $main_content .= '<li>' . $guild_error2;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds&guild=' .
      $guild_name .
      '&action=passleadership" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    if (!empty($guild_errors2)) {
      foreach ($guild_errors2 as $guild_error2) {
        $main_content .= '<li>' . $guild_error2;
      }
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br><br/><center><form action="?subtopic=guilds&action=show&guild=' .
      $guild_name .
      '" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'deleteguild') {
  $guild_id = (int) $_REQUEST['guild'];
  $guild_display_name = '';
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_id);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_id . '</b> doesn\'t exist.';
    } else {
      $guild_display_name = $guild->getName();
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild->getOwner()->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        if (isset($_POST['todo']) && $_POST['todo'] == 'save') {
          $delete_error = null;
          if (!delete_guild($guild->getId(), $delete_error)) {
            $guild_errors[] = delete_guild_error_message($delete_error);
          } else {
            $saved = true;
          }
        }
        if (!empty($saved)) {
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Guild with name <b>' .
            htmlspecialchars($guild_display_name) .
            '</b> has been deleted.</td></tr>          </table>        </div>  </table></div></td></tr>';
          $main_content .=
            '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
            csrf_field() .
            '<div class="BigButton" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
            $layout_name .
            '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
        } elseif (empty($guild_errors)) {
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Are you sure you want delete guild <b>' .
            htmlspecialchars($guild_display_name) .
            '</b>?<br>
					<form action="?subtopic=guilds&guild=' .
            $guild_id .
            '&action=deleteguild" METHOD=post>' .
            csrf_field() .
            '<input type="hidden" name="todo" value="save"><input type="submit" value="Yes, delete"></form>
					</td></tr>          </table>        </div>  </table></div></td></tr>';
          $main_content .=
            '<br/><center><form action="?subtopic=guilds&guild=' .
            $guild_id .
            '&action=manager" METHOD=post>' .
            csrf_field() .
            '<div class="BigButton" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
            $layout_name .
            '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
        }
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'deletebyadmin') {
  $guild_id = (int) $_REQUEST['guild'];
  $guild_display_name = '';
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_id);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_id . '</b> doesn\'t exist.';
    } else {
      $guild_display_name = $guild->getName();
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      if ($group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
        if (isset($_POST['todo']) && $_POST['todo'] == 'save') {
          $delete_error = null;
          if (!delete_guild($guild->getId(), $delete_error)) {
            $guild_errors[] = delete_guild_error_message($delete_error);
          } else {
            $main_content .=
              '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
              $layout_name .
              '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
              $layout_name .
              '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
              $layout_name .
              '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Guild with name <b>' .
              htmlspecialchars($guild_display_name) .
              '</b> has been deleted.</td></tr>          </table>        </div>  </table></div></td></tr><br/><center><form action="?subtopic=guilds" METHOD=post>' .
              csrf_field() .
              '<div class="BigButton" style="background-image:url(' .
              $layout_name .
              '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
              $layout_name .
              '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
              $layout_name .
              '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
          }
        } else {
          $main_content .=
            '<div class="TableContainer" >  <table class="Table1" cellpadding="0" cellspacing="0" >    <div class="CaptionContainer" >      <div class="CaptionInnerContainer" >        <span class="CaptionEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionBorderTop" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <div class="Text" >Guild Deleted</div>        <span class="CaptionVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></span>        <span class="CaptionBorderBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/table-headline-border.gif);" ></span>        <span class="CaptionEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>        <span class="CaptionEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></span>      </div>    </div>    <tr>      <td>        <div class="InnerTableContainer" >          <table style="width:100%;" ><tr><td>Are you sure you want delete guild <b>' .
            htmlspecialchars($guild_display_name) .
            '</b>?<br>
					<form action="?subtopic=guilds&guild=' .
            $guild_id .
            '&action=deletebyadmin" METHOD=post>' .
            csrf_field() .
            '<input type="hidden" name="todo" value="save"><input type="submit" value="Yes, delete"></form>
					</td></tr>          </table>        </div>  </table></div></td></tr><br/><center><form action="?subtopic=guilds" METHOD=post>' .
            csrf_field() .
            '<div class="BigButton" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
            $layout_name .
            '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
            $layout_name .
            '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
        }
      } else {
        $guild_errors[] = 'You are not an admin!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t delete guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'changemotd') {
  $guild_name = (int) $_REQUEST['guild'];
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with ID <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild->getOwner()->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        if ($_REQUEST['todo'] == 'save') {
          $motd = htmlspecialchars(
            stripslashes(substr(trim($_REQUEST['motd']), 0, $config['site']['guild_motd_chars_limit']))
          );
          $guild->setCustomField('motd', $motd);
          $saved = true;
        }
        $main_content .= '<center><h2>Change guild MOTD</h2></center>';
        if ($saved) {
          $main_content .= '<center><font color="red" size="3"><b>CHANGES HAS BEEN SAVED!</b></font></center><br>';
        }
        $main_content .= 'Here you can change MOTD (Message of the Day, showed in game!) of your guild.<BR>';
        $main_content .=
          '<form enctype="multipart/form-data" action="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=changemotd" method="POST">' .
          csrf_field() .
          '
				<input type="hidden" name="todo" value="save" />
				    <textarea name="motd" cols="60" rows="3">' .
          $guild->getCustomField('motd') .
          '</textarea><br>
				    (max. ' .
          $config['site']['guild_motd_chars_limit'] .
          ' chars) <input type="submit" value="Save MOTD" /></form><br>';
        $main_content .=
          '<br/><center><form action="?subtopic=guilds&guild=' .
          $guild_name .
          '&action=manager" METHOD=post>' .
          csrf_field() .
          '<div class="BigButton" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
          $layout_name .
          '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
          $layout_name .
          '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
    $main_content .=
      '<br/><center><form action="?subtopic=guilds" METHOD=post>' .
      csrf_field() .
      '<div class="BigButton" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton.gif)" ><div onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" ><div class="BigButtonOver" style="background-image:url(' .
      $layout_name .
      '/images/buttons/sbutton_over.gif);" ></div><input class="ButtonText" type="image" name="Back" alt="Back" src="' .
      $layout_name .
      '/images/buttons/_sbutton_back.gif" ></div></div></form></center>';
  }
}

//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'saveranks') {
  $guild_name = (int) $_REQUEST['guild'];
  if (empty($guild_errors)) {
    $guild = $ots->createObject('Guild');
    $guild->load($guild_name);
    if (!$guild->isLoaded()) {
      $guild_errors[] = 'Guild with name <b>' . $guild_name . '</b> doesn\'t exist.';
    }
  }
  if (empty($guild_errors)) {
    if ($logged) {
      $guild_leader_char = $guild->getOwner();
      $rank_list = $guild->getGuildRanksList();
      $rank_list->orderBy('level', POT::ORDER_DESC);
      $guild_leader = false;
      $account_players = $account_logged->getPlayers();
      foreach ($account_players as $player) {
        if ($guild_leader_char->getId() == $player->getId()) {
          $guild_vice = true;
          $guild_leader = true;
          $level_in_guild = 3;
        }
      }
      if ($guild_leader) {
        foreach ($rank_list as $rank) {
          $rank_id = $rank->getId();
          $name = $_REQUEST[$rank_id . '_name'];
          $level = (int) $_REQUEST[$rank_id . '_level'];
          if (check_rank_name($name)) {
            $rank->setName($name);
          } else {
            $ranks_errors[] =
              'Invalid rank name. Please use only a-Z, 0-9 and spaces. Rank ID <b>' . $rank_id . '</b>.';
          }
          if ($level > 0 && $level < 4) {
            $rank->setLevel($level);
          } else {
            $ranks_errors[] = 'Invalid rank level. Contact with admin. Rank ID <b>' . $rank_id . '</b>.';
          }
          $rank->save();
        }
        if (!empty($ranks_errors)) {
          $main_content .=
            '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
            $layout_name .
            '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
          foreach ($ranks_errors as $guild_error) {
            $main_content .= '<li>' . $guild_error;
          }
          $main_content .=
            '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
            $layout_name .
            '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
        } else {
          header('Location: ?subtopic=guilds&action=manager&guild=' . $guild_name);
        }
      } else {
        $guild_errors[] = 'You are not a leader of guild!';
      }
    } else {
      $guild_errors[] = 'You are not logged. You can\'t manage guild.';
    }
  }
  if (!empty($guild_errors)) {
    $main_content .=
      '<div class="SmallBox" >  <div class="MessageContainer" >    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeLeftTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeRightTop" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="ErrorMessage" >      <div class="BoxFrameVerticalLeft" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="BoxFrameVerticalRight" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-vertical.gif);" /></div>      <div class="AttentionSign" style="background-image:url(' .
      $layout_name .
      '/images/content/attentionsign.gif);" /></div><b>The Following Errors Have Occurred:</b><br/>';
    foreach ($guild_errors as $guild_error) {
      $main_content .= '<li>' . $guild_error;
    }
    $main_content .=
      '</div>    <div class="BoxFrameHorizontal" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-horizontal.gif);" /></div>    <div class="BoxFrameEdgeRightBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>    <div class="BoxFrameEdgeLeftBottom" style="background-image:url(' .
      $layout_name .
      '/images/content/box-frame-edge.gif);" /></div>  </div></div><br>';
  }
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'cleanup_players') {
  if ($logged) {
    if ($group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
      $players_list = new OTS_Players_List();
      $players_list->init();
    } else {
      $players_list = $account_logged->getPlayersList();
    }
    if (count($players_list) > 0) {
      foreach ($players_list as $player) {
        $player_rank = $player->getRank();
        if (!empty($player_rank)) {
          if ($player_rank->isLoaded()) {
            $rank_guild = $player_rank->getGuild();
            if (!$rank_guild->isLoaded()) {
              $player->setRank();
              $player->setGuildNick();
              $player->save();
              $changed_ranks_of[] = $player->getName();
              $deleted_ranks[] = 'ID: ' . $player_rank->getId() . ' - ' . $player_rank->getName();
              $player_rank->delete();
            }
          } else {
            $player->setRank();
            $player->setGuildNick('');
            $player->save();
            $changed_ranks_of[] = $player->getName();
          }
        }
      }
      $main_content .= "<b>Deleted ranks (this ranks guilds doesn't exist [bug fix]):</b>";
      if (!empty($deleted_ranks)) {
        foreach ($deleted_ranks as $rank) {
          $main_content .= '<li>' . $rank;
        }
      }
      $main_content .= "<BR /><BR /><b>Changed ranks of players (rank or guild of rank doesn't exist [bug fix]):</b>";
      if (!empty($changed_ranks_of)) {
        foreach ($changed_ranks_of as $name) {
          $main_content .= '<li>' . $name;
        }
      }
    } else {
      $main_content .= '0 players found.';
    }
  } else {
    $main_content .= 'You are not logged in.';
  }
  $main_content .= "<center><h3><a href=\"?subtopic=guilds\">BACK</a></h3></center>";
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'cleanup_guilds') {
  if ($logged) {
    $guilds_list = new OTS_Guilds_List();
    $guilds_list->init();
    if (count($guilds_list) > 0) {
      foreach ($guilds_list as $guild) {
        $error = 0;
        $leader = $guild->getOwner();
        if ($leader->isLoaded()) {
          $leader_rank = $leader->getRank();
          if (!empty($leader_rank)) {
            if ($leader_rank->isLoaded()) {
              $leader_guild = $leader_rank->getGuild();
              if ($leader_guild->isLoaded()) {
                if ($leader_guild->getId() != $guild->getId()) {
                  $error = 1;
                }
              } else {
                $error = 1;
              }
            } else {
              $error = 1;
            }
          } else {
            $error = 1;
          }
        } else {
          $error = 1;
        }
        if ($error == 1) {
          $deleted_guilds[] = $guild->getName();
          $status = delete_guild($guild->getId());
        }
      }
      $main_content .=
        '<b>Deleted guilds (leaders of this guilds are not members of this guild [fix bugged guilds]):</b>';
      if (!empty($deleted_guilds)) {
        foreach ($deleted_guilds as $guild) {
          $main_content .= '<li>' . $guild;
        }
      }
    } else {
      $main_content .= '0 guilds found.';
    }
  } else {
    $main_content .= 'You are not logged in.';
  }
  $main_content .= "<center><h3><a href=\"?subtopic=guilds\">BACK</a></h3></center>";
}
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------//-----------------------------------------------------------------------------
if ($action == 'change_nick') {
  if ($logged) {
    $player_n = stripslashes($_REQUEST['name']);
    $new_nick = stripslashes($_REQUEST['nick']);
    $player = new OTS_Player();
    $player->find($player_n);
    $player_from_account = false;
    if (strlen($new_nick) <= 40) {
      if ($player->isLoaded()) {
        $account_players = $account_logged->getPlayersList();
        if (count($account_players)) {
          foreach ($account_players as $acc_player) {
            if ($acc_player->getId() == $player->getId()) {
              $player_from_account = true;
            }
          }
          if ($player_from_account) {
            if ($player->isOnline()) {
              $main_content .= guild_online_error($player->getName());
            } else {
              $current_rank = $player->getRank();
              if ($current_rank === null || !$current_rank->isLoaded()) {
                $main_content .= 'This player is not in a guild.';
              } else {
                save_player_guild_membership($player, $current_rank, $new_nick);
                $main_content .=
                  'Guild nick of player <b>' .
                  $player->getName() .
                  '</b> changed to <b>' .
                  htmlentities($new_nick) .
                  '</b>.';
                $addtolink = '&action=show&guild=' . $current_rank->getGuild()->getId();
              }
            }
          } else {
            $main_content .= 'This player is not from your account.';
          }
        } else {
          $main_content .= 'This player is not from your account.';
        }
      } else {
        $main_content .= 'Unknow error occured.';
      }
    } else {
      $main_content .= 'Too long guild nick. Max. 30 chars, your: ' . strlen($new_nick);
    }
  } else {
    $main_content .= 'You are not logged.';
  }
  $main_content .= '<center><h3><a href="?subtopic=guilds' . $addtolink . '">BACK</a></h3></center>';
}
