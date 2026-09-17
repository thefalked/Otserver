<?php
$skills = $SQL->query(
  'SELECT * FROM players WHERE deleted = 0 AND group_id < ' .
    $config['site']['players_group_id_block'] .
    ' AND account_id != 1 ORDER BY level DESC LIMIT 5'
); ?>
<style type="text/css" media="all">
  #Themeboxes #Topbar.Toplevelbox {
    position: relative;
    margin-bottom: 10px;
    width: 180px;
    height: auto;
    overflow: hidden;
    background-repeat: no-repeat;
    background-position: top center;
  }

  #Themeboxes #Topbar .top_level {
    position: relative;
    box-sizing: border-box;
    margin: 29px 6px 0;
    width: 168px;
    min-height: 0;
    height: auto;
    z-index: 20;
    padding: 6px 4px 14px;
    font-family: Tahoma, Geneva, sans-serif;
    font-size: 9.2pt;
    color: #fff;
    font-weight: bold;
    text-align: left;
    text-shadow: 0.1em 0.1em #333;
    background-repeat: repeat-y !important;
    background-position: top center;
    overflow: hidden;
  }

  #Themeboxes #Topbar .top_level .rank-row {
    display: block;
    margin: 0 0 6px;
    padding: 0 2px;
    overflow: hidden;
    text-align: left;
  }

  #Themeboxes #Topbar a {
    text-decoration: none;
    cursor: pointer;
  }

  #Themeboxes #Topbar a.topfont {
    display: block;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 12px;
    line-height: 1.25;
    color: #0f0;
    text-decoration: none;
    overflow: hidden;
  }

  #Themeboxes #Topbar a.topfont .rank-name {
    display: block;
    max-width: 100%;
    overflow-wrap: anywhere;
    word-break: break-word;
  }

  #Themeboxes #Topbar a.topfont .rank-level {
    display: block;
    color: #fff;
    font-size: 10px;
    font-weight: normal;
  }

  #Themeboxes #Topbar a:hover.topfont {
    color: #ccc;
    text-decoration: none;
  }

  #Themeboxes #Topbar a:hover.topfont .rank-level {
    color: #ccc;
  }

  #Themeboxes #Topbar .Bottom {
    position: relative !important;
    bottom: auto !important;
    left: auto !important;
    height: 12px;
    width: 180px;
    background-repeat: no-repeat;
  }
</style>

<div id="Topbar" class="Toplevelbox" style="background-image:url(<?php echo $layout_name; ?>/images/top_level.png);">
  <div class="top_level" style="background-image:url(<?php echo $layout_name; ?>/images/bg_top.png);">
    <?php
    $a = 1;
    foreach ($skills as $skill) {
      $name = htmlspecialchars($skill['name'], ENT_QUOTES, 'UTF-8');
      $level = (int) $skill['level'];
      echo '<div class="rank-row"><a href="?subtopic=characters&amp;name=' .
        rawurlencode($skill['name']) .
        '" class="topfont" title="' .
        $name .
        '">' .
        '<span class="rank-name">' .
        $a .
        ' - ' .
        $name .
        '</span>' .
        '<span class="rank-level">Nível: (' .
        $level .
        ')</span>' .
        '</a></div>';
      $a++;
    }
    ?>
  </div>
  <div class="Bottom"
    style="background-image:url(<?php echo $layout_name; ?>/images/general/box-bottom.gif);"></div>
</div>
