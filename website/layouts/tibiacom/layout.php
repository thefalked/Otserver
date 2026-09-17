<?php
$seo_server_name = (string) ($config['server']['serverName'] ?? 'Baiak Vip9');
$seo_site_url = rtrim((string) ($config['site']['site_url'] ?? 'https://baiakvip9.servegame.com'), '/');
$seo_subtopic = (string) ($subtopic ?? 'latestnews');
$seo_title = (string) ($title ?? $seo_server_name);
$seo_description = (string) ($config['site']['seo_description'] ?? '');
$seo_og_image_path = (string) ($config['site']['og_image'] ?? '/layouts/tibiacom/images/header/background-artwork.jpg');
$seo_og_image =
  strpos($seo_og_image_path, 'http://') === 0 || strpos($seo_og_image_path, 'https://') === 0
  ? $seo_og_image_path
  : $seo_site_url . '/' . ltrim($seo_og_image_path, '/');
$seo_og_image_width = (int) ($config['site']['og_image_width'] ?? 1600);
$seo_og_image_height = (int) ($config['site']['og_image_height'] ?? 800);
$seo_noindex_pages = [
  'accountmanagement',
  'adminpanel',
  'shopadmin',
  'mail',
  'namelock',
  'pag_retorno',
  'retpagseguro'
];
$seo_robots = in_array($seo_subtopic, $seo_noindex_pages, true)
  ? 'noindex, nofollow'
  : 'index, follow, max-image-preview:large';
$seo_page_descriptions = [
  'latestnews' => $seo_description,
  'createaccount' =>
  'Crie sua conta grátis no ' .
    $seo_server_name .
    '. Cadastro rápido para começar a jogar com rates altos e PvP aberto.',
  'downloads' =>
  'Baixe o cliente do ' .
    $seo_server_name .
    ' e conecte-se ao servidor em poucos minutos.',
  'serverinfo' =>
  'Consulte IP, porta, rates e detalhes técnicos do servidor ' .
    $seo_server_name .
    '.',
  'whoisonline' =>
  'Veja quem está online agora no ' .
    $seo_server_name .
    ' e acompanhe a lista de jogadores em tempo real.',
  'highscores' =>
  'Confira o ranking de skills e levels dos melhores jogadores do ' .
    $seo_server_name .
    '.',
  'characters' =>
  'Busque um personagem no ' .
    $seo_server_name .
    ' e veja level, vocação e dados públicos.',
  'guilds' =>
  'Explore guildas ativas no ' .
    $seo_server_name .
    ', veja membros e encontre um grupo para jogar.',
  'forum' =>
  'Participe do fórum do ' .
    $seo_server_name .
    ': notícias, tutoriais, trocas e discussões da comunidade.',
  'changelog' =>
  'Acompanhe o changelog do ' .
    $seo_server_name .
    ' com patches, balanceamentos e novidades.',
  'tibiarules' =>
  'Leia as regras do ' .
    $seo_server_name .
    ' antes de jogar e evite punições.',
  'team' =>
  'Conheça a staff e a equipe responsável pelo ' .
    $seo_server_name .
    '.',
  'spells' =>
  'Lista de magias disponíveis no ' .
    $seo_server_name .
    ', com vocações e requisitos.',
  'creatures' =>
  'Guia de criaturas e monstros do ' .
    $seo_server_name .
    ', com informações de hunt.',
  'shopsystem' =>
  'Veja itens e vantagens da loja do ' .
    $seo_server_name .
    '.',
  'donate' =>
  'Apoie o ' .
    $seo_server_name .
    ' e confira as opções de doação disponíveis.',
  'vantagens' =>
  'Conheça benefícios e vantagens oferecidos no ' .
    $seo_server_name .
    '.',
  'war' =>
  'Acompanhe guerras de guildas em andamento no ' .
    $seo_server_name .
    '.',
  'frags' =>
  'Estatísticas de frags e confrontos PvP no ' .
    $seo_server_name .
    '.',
  'topguilds' =>
  'Ranking das guildas mais fortes do ' .
    $seo_server_name .
    '.',
  'bans' =>
  'Lista pública de banimentos aplicados no ' .
    $seo_server_name .
    '.',
  'killstatistics' =>
  'Estatísticas de kills e mortes registradas no ' .
    $seo_server_name .
    '.',
  'experiencetable' =>
  'Tabela de experiência por level no ' .
    $seo_server_name .
    '.',
  'archive' =>
  'Arquivo histórico de notícias publicadas no ' .
    $seo_server_name .
    '.',
  'records' =>
  'Recordes e marcas históricas da comunidade do ' .
    $seo_server_name .
    '.',
  'gallery' =>
  'Galeria de imagens enviadas pela comunidade do ' .
    $seo_server_name .
    '.',
  'lottery' =>
  'Participe da loteria e veja sorteios ativos no ' .
    $seo_server_name .
    '.',
  'polls' =>
  'Vote nas enquetes da comunidade do ' .
    $seo_server_name .
    '.',
  'bugtracker' =>
  'Reporte bugs e acompanhe correções do ' .
    $seo_server_name .
    '.',
  'fragers' =>
  'Veja o top de fraggers e o ranking PvP do ' .
    $seo_server_name .
    '.',
  'scrollnews' =>
  'Notícias rápidas e avisos recentes do ' .
    $seo_server_name .
    '.'
];
if ($seo_subtopic === 'latestnews') {
  $seo_canonical = $seo_site_url . '/';
} else {
  $seo_canonical = $seo_site_url . '/?subtopic=' . rawurlencode($seo_subtopic);
}
if (isset($seo_page_descriptions[$seo_subtopic])) {
  $seo_page_description = $seo_page_descriptions[$seo_subtopic];
} else {
  $topic_label = (string) ($topic ?? $seo_subtopic);
  $seo_page_description = $seo_server_name . ' - ' . $topic_label . '.';
}
$seo_json_ld = [
  '@context' => 'https://schema.org',
  '@type' => 'WebSite',
  'name' => $seo_server_name,
  'alternateName' => ['Baiakzik Vip9', 'Baiak Vip9 OTServer'],
  'url' => $seo_site_url . '/',
  'description' => $seo_description,
  'inLanguage' => 'pt-BR'
];
$seo_json_ld_game = null;
if ($seo_subtopic === 'latestnews') {
  $seo_json_ld_game = [
    '@context' => 'https://schema.org',
    '@type' => 'VideoGame',
    'name' => $seo_server_name,
    'alternateName' => 'Baiakzik Vip9',
    'url' => $seo_site_url . '/',
    'description' => $seo_description,
    'image' => $seo_og_image,
    'gamePlatform' => 'PC',
    'applicationCategory' => 'Game',
    'operatingSystem' => 'Windows',
    'genre' => ['MMORPG', 'Open Tibia Server'],
    'inLanguage' => 'pt-BR',
    'offers' => [
      '@type' => 'Offer',
      'price' => '0',
      'priceCurrency' => 'BRL',
      'availability' => 'https://schema.org/InStock'
    ]
  ];
}
?>
<!DOCTYPE html>
<html lang="pt-BR" xmlns="http://www.w3.org/1999/xhtml">

<head>
  <meta charset="UTF-8" />
  <meta http-equiv="content-language" content="pt-BR" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title><?php echo h($seo_title); ?></title>
  <meta name="description" content="<?php echo h($seo_page_description); ?>" />
  <meta name="robots" content="<?php echo h($seo_robots); ?>" />
  <meta name="author" content="<?php echo h($seo_server_name); ?>" />
  <meta name="theme-color" content="#1a310e" />
  <link rel="canonical" href="<?php echo h($seo_canonical); ?>" />

  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="<?php echo h($seo_server_name); ?>" />
  <meta property="og:locale" content="pt_BR" />
  <meta property="og:title" content="<?php echo h($seo_title); ?>" />
  <meta property="og:description" content="<?php echo h($seo_page_description); ?>" />
  <meta property="og:url" content="<?php echo h($seo_canonical); ?>" />
  <meta property="og:image" content="<?php echo h($seo_og_image); ?>" />
  <meta property="og:image:secure_url" content="<?php echo h($seo_og_image); ?>" />
  <meta property="og:image:type" content="image/jpeg" />
  <meta property="og:image:width" content="<?php echo (int) $seo_og_image_width; ?>" />
  <meta property="og:image:height" content="<?php echo (int) $seo_og_image_height; ?>" />
  <meta property="og:image:alt" content="<?php echo h($seo_server_name . ' - OTServer 8.60'); ?>" />

  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="<?php echo h($seo_title); ?>" />
  <meta name="twitter:description" content="<?php echo h($seo_page_description); ?>" />
  <meta name="twitter:image" content="<?php echo h($seo_og_image); ?>" />
  <meta name="twitter:image:alt" content="<?php echo h($seo_server_name . ' - OTServer 8.60'); ?>" />

  <script type="application/ld+json">
    <?php echo json_encode(
      $seo_json_ld,
      JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP
    ); ?>
  </script>
  <?php if ($seo_json_ld_game !== null) { ?>
    <script type="application/ld+json">
      <?php echo json_encode(
        $seo_json_ld_game,
        JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP
      ); ?>
    </script>
  <?php } ?>

  <link rel="shortcut icon" href="<?php echo h($seo_site_url); ?>/images/server.ico" type="image/x-icon" />
  <link rel="icon" href="<?php echo h($seo_site_url); ?>/images/server.ico" type="image/x-icon" />
  <link rel="apple-touch-icon" href="<?php echo h($seo_site_url); ?>/images/apple-touch-icon.png" sizes="180x180" />
  <?php echo $layout_header; ?>
  <link href="<?php echo $layout_name; ?>/basic.css?v=5" rel="stylesheet" type="text/css">
  <script type="text/javascript">
    var IMAGES = 0;
    IMAGES = '<?php echo $layout_name; ?>/images';
    var g_FormField = '';
    var LINK_ACCOUNT = 0;
    LINK_ACCOUNT = '';
  </script>
  <script type="text/javascript" src="<?php echo $layout_name; ?>/initialize.js?v=3"></script>
  <script type="text/javascript">
    setTimeout("changePage()", 18000);

    function changePage() {
      if (parent.frames.length > 2) {
        if (browserTyp == "ie") {
          parent.location = document.location;
        } else {
          self.top.location = document.location;
        }
      }
    }
  </script>
  <script type="text/javascript">
    /*
    Snow Fall 1 - no images - Java Script
    Visit [Voc precisa estar registrado e conectado para ver este link.]
    for this script and many more
    */

    // Set the number of snowflakes (more than 30 - 40 not recommended)
    var snowmax = 35

    // Set the colors for the snow. Add as many colors as you like
    var snowcolor = new Array("#AAAACC", "#DDDDFF", "#CCCCDD", "#F3F3F3", "#F0FFFF")

    // Set the fonts, that create the snowflakes. Add as many fonts as you like
    var snowtype = new Array("Arial Black", "Arial Narrow", "Times", "Comic Sans MS")

    // Set the letter that creates your snowflake (recommended: * )
    var snowletter = "*"

    // Set the speed of sinking (recommended values range from 0.3 to 2)
    var sinkspeed = 0.6

    // Set the maximum-size of your snowflakes
    var snowmaxsize = 22

    // Set the minimal-size of your snowflakes
    var snowminsize = 8

    // Set the snowing-zone
    // Set 1 for all-over-snowing, set 2 for left-side-snowing
    // Set 3 for center-snowing, set 4 for right-side-snowing
    var snowingzone = 1

    /*
    // * NO CONFIGURATION BELOW HERE *
    */

    // Do not edit below this line
    var snow = new Array()
    var marginbottom
    var marginright
    var timer
    var i_snow = 0
    var x_mv = new Array();
    var crds = new Array();
    var lftrght = new Array();
    var browserinfos = navigator.userAgent
    var ie5 = document.all && document.getElementById && !browserinfos.match(/Opera/)
    var ns6 = document.getElementById && !document.all
    var opera = browserinfos.match(/Opera/)
    var browserok = ie5 || ns6 || opera

    function randommaker(range) {
      rand = Math.floor(range * Math.random())
      return rand
    }

    function initsnow() {
      if (ie5 || opera) {
        marginbottom = document.body.clientHeight
        marginright = document.body.clientWidth
      } else if (ns6) {
        marginbottom = window.innerHeight
        marginright = window.innerWidth
      }
      var snowsizerange = snowmaxsize - snowminsize
      for (i = 0; i <= snowmax; i++) {
        crds[i] = 0;
        lftrght[i] = Math.random() * 15;
        x_mv[i] = 0.03 + Math.random() / 10;
        snow[i] = document.getElementById("s" + i)
        snow[i].style.fontFamily = snowtype[randommaker(snowtype.length)]
        snow[i].size = randommaker(snowsizerange) + snowminsize
        snow[i].style.fontSize = snow[i].size
        snow[i].style.color = snowcolor[randommaker(snowcolor.length)]
        snow[i].sink = sinkspeed * snow[i].size / 5
        if (snowingzone == 1) {
          snow[i].posx = randommaker(marginright - snow[i].size)
        }
        if (snowingzone == 2) {
          snow[i].posx = randommaker(marginright / 2 - snow[i].size)
        }
        if (snowingzone == 3) {
          snow[i].posx = randommaker(marginright / 2 - snow[i].size) + marginright / 4
        }
        if (snowingzone == 4) {
          snow[i].posx = randommaker(marginright / 2 - snow[i].size) + marginright / 2
        }
        snow[i].posy = randommaker(2 * marginbottom - marginbottom - 2 * snow[i].size)
        snow[i].style.left = snow[i].posx
        snow[i].style.top = snow[i].posy
      }
      movesnow()
    }

    function movesnow() {
      for (i = 0; i <= snowmax; i++) {
        crds[i] += x_mv[i];
        snow[i].posy += snow[i].sink
        snow[i].style.left = snow[i].posx + lftrght[i] * Math.sin(crds[i]);
        snow[i].style.top = snow[i].posy

        if (snow[i].posy >= marginbottom - 2 * snow[i].size || parseInt(snow[i].style.left) > (marginright - 3 * lftrght[i])) {
          if (snowingzone == 1) {
            snow[i].posx = randommaker(marginright - snow[i].size)
          }
          if (snowingzone == 2) {
            snow[i].posx = randommaker(marginright / 2 - snow[i].size)
          }
          if (snowingzone == 3) {
            snow[i].posx = randommaker(marginright / 2 - snow[i].size) + marginright / 4
          }
          if (snowingzone == 4) {
            snow[i].posx = randommaker(marginright / 2 - snow[i].size) + marginright / 2
          }
          snow[i].posy = 0
        }
      }
      var timer = setTimeout("movesnow()", 50)
    }

    for (i = 0; i <= snowmax; i++) {
      document.write("<span id='s" + i + "' style='position:absolute;top:-" + snowmaxsize + "'>" + snowletter + "</span>")
    }
    if (browserok) {
      window.onload = initsnow
    }
  </script>
</head>

<body onBeforeUnLoad="SaveMenu();" onUnload="SaveMenu();">
  <?php
  if (!isset($news_content)) {
    $news_content = '';
  }
  if (!isset($main_content)) {
    $main_content = '';
  }
  ?>

  <a name="top"></a>
  <div id="ArtworkHelper"
    style="background-image:url(<?php echo $layout_name; ?>/images/header/background-artwork.jpg);">
    <div id="Bodycontainer">
      <div id="ContentRow">
        <div id="MenuColumn">
          <div id="LeftArtwork">
            <img id="Statue_1" src="<?php echo $layout_name; ?>/images/header/animated-statue.gif" alt="<?php echo h($seo_server_name); ?>" />
            <img id="TibiaLogoArtworkTop" src="<?php echo $layout_name; ?>/images/header/tibia-logo-artwork-top.gif"
              onClick="window.location = '?subtopic=latestnews';" alt="<?php echo h($seo_server_name . ' - OTServer 8.60'); ?>" />
            <img id="TibiaLogoArtworkBottom"
              src="<?php echo $layout_name; ?>/images/header/tibia-logo-artwork-bottom.gif" alt="<?php echo h($seo_server_name); ?>" />
            <img id="Statue_2" src="<?php echo $layout_name; ?>/images/header/animated-statue.gif" alt="<?php echo h($seo_server_name); ?>" />
          </div>

          <div id="Loginbox">
            <div id="LoginTop" style="background-image:url(<?php echo $layout_name; ?>/images/general/box-top.gif)">
            </div>
            <div id="BorderLeft" class="LoginBorder"
              style="background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif)"></div>
            <div class="Loginstatus"
              style="background-image:url(<?php echo $layout_name; ?>/images/loginbox/loginbox-textfield-background.gif)">
              <div id="LoginstatusText_1" class="LoginstatusText"
                style="background-image:url(<?php echo $layout_name; ?>/images/loginbox/loginbox-font-you-are-not-logged-in.gif)">
              </div>
            </div>
            <div id="LoginButtonContainer"
              style="background-image:url(<?php echo $layout_name; ?>/images/loginbox/loginbox-textfield-background.gif)">
              <div id="LoginButton"
                style="background-image:url(<?php echo $layout_name; ?>/images/buttons/sbutton.gif)">
                <div onClick="LoginButtonAction();" onMouseOver="MouseOverBigButton(this);"
                  onMouseOut="MouseOutBigButton(this);">
                  <div class="Button"
                    style="background-image:url(<?php echo $layout_name; ?>/images/buttons/sbutton_over.gif)"></div>
                  <div id="ButtonText"></div>
                </div>
              </div>
            </div>
            <div style="clear:both"></div>
            <div class="Loginstatus"
              style="background-image:url(<?php echo $layout_name; ?>/images/loginbox/loginbox-textfield-background.gif)">
              <div id="LoginstatusText_2" onClick="LoginstatusTextAction(this);"
                onMouseOver="MouseOverLoginBoxText(this);" onMouseOut="MouseOutLoginBoxText(this);">
                <div id="LoginstatusText_2_1" class="LoginstatusText"
                  style="background-image:url(<?php echo $layout_name; ?>/images/loginbox/loginbox-font-create-account.gif)">
                </div>
                <div id="LoginstatusText_2_2" class="LoginstatusText"
                  style="background-image:url(<?php echo $layout_name; ?>/images/loginbox/loginbox-font-create-account-over.gif)">
                </div>
              </div>
            </div>
            <div id="BorderRight" class="LoginBorder"
              style="background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif)"></div>
            <div id="LoginBottom" class="Loginstatus"
              style="background-image:url(<?php echo $layout_name; ?>/images/general/box-bottom.gif)"></div>
          </div>

          <div id='Menu'>
            <div id='MenuTop' style='background-image:url(<?php echo $layout_name; ?>/images/general/box-top.gif);'>
            </div>

            <div id='news' class='menuitem'>
              <span onClick="MenuItemAction('news')">
                <div class='MenuButton'
                  style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background.gif);'>
                  <div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'>
                    <div class='Button'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background-over.gif);'>
                    </div>
                    <span id='news_Lights' class='Lights'>
                      <div class='light_lu'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ld'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>

                      <div class='light_ru'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                    </span>
                    <div id='news_Icon' class='Icon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-news.gif);'></div>
                    <div id='news_Label' class='Label'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/label-news.gif);'></div>
                    <div id='news_Extend' class='Extend'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/plus.gif);'></div>
                  </div>
                </div>
              </span>
              <div id='news_Submenu' class='Submenu'>
                <a href='?subtopic=latestnews'>
                  <div id='submenu_latestnews' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_latestnews' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Últimas notícias</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=archive'>
                  <div id='submenu_archive' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_archive' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Arquivo</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=changelog'>
                  <div id='submenu_changelog' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_changelog' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Atualizações</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
              </div>
            </div>

            <div id='account' class='menuitem'>
              <span onClick="MenuItemAction('account')">
                <div class='MenuButton'
                  style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background.gif);'>
                  <div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'>
                    <div class='Button'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background-over.gif);'>
                    </div>
                    <span id='account_Lights' class='Lights'>
                      <div class='light_lu'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ld'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ru'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                    </span>
                    <div id='account_Icon' class='Icon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-account.gif);'></div>
                    <div id='account_Label' class='Label'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/label-account.gif);'></div>
                    <div id='account_Extend' class='Extend'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/plus.gif);'></div>
                  </div>
                </div>
              </span>
              <div id='account_Submenu' class='Submenu'>
                <a href='?subtopic=accountmanagement'>
                  <div id='submenu_accountmanagement' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_accountmanagement' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Minha conta</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=createaccount'>
                  <div id='submenu_createaccount' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_createaccount' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Criar conta</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=tibiarules'>
                  <div id='submenu_tibiarules' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_tibiarules' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Regras do servidor</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=bugtracker'>
                  <div id='submenu_bugtracker' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_bugtracker' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Reportar bug</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <?php
                if ($config['site']['download_page'] == 1) {
                  if ($logged && $group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
                    echo "<a href='?subtopic=adminpanel'>
  <div id='submenu_adminpanel' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                      $layout_name .
                      "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_adminpanel' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                      $layout_name .
                      "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'><font color=\"red\">! Painel admin !</font></div>
    <div class='RightChain' style='background-image:url(" .
                      $layout_name .
                      "/images/general/chain.gif);'></div>
  </div>
</a>";
                  }
                }
                if ($logged && $group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
                  echo "<a href='?subtopic=scrollnews&action=edit_ticker'> 
  <div id='submenu_polls' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'> 
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div> 
    <div id='ActiveSubmenuItemIcon_polls' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div> 
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div> 
  </div> 
</a>";
                }
                if ($logged && $group_id_of_acc_logged > 0) {
                  echo "<a href='?subtopic=namelock'>
  <div id='submenu_namelock' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_namelock' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'><font color=\"red\">! Namelocks !</font></div>
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
  </div>
</a>";
                }
                if ($logged && $group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
                  echo "<a href='?subtopic=polls'>
  <div id='submenu_polls' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_polls' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'><font color=\"red\">! Gerenciar enquetes !</font></div>
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
  </div>
</a>";
                }
                ?>
              </div>
            </div>

            <div id='community' class='menuitem'>
              <span onClick="MenuItemAction('community')">
                <div class='MenuButton'
                  style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background.gif);'>
                  <div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'>
                    <div class='Button'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background-over.gif);'>
                    </div>
                    <span id='community_Lights' class='Lights'>
                      <div class='light_lu'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ld'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ru'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                    </span>
                    <div id='community_Icon' class='Icon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-community.gif);'></div>
                    <div id='community_Label' class='Label'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/label-community.gif);'></div>
                    <div id='community_Extend' class='Extend'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/plus.gif);'></div>

                  </div>
                </div>
              </span>
              <div id='community_Submenu' class='Submenu'>
                <a href='?subtopic=characters'>
                  <div id='submenu_characters' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_characters' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Personagens</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>

                  </div>
                </a>
                <a href='?subtopic=whoisonline'>
                  <div id='submenu_whoisonline' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_whoisonline' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Quem está online</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=highscores'>
                  <div id='submenu_highscores' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_highscores' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Rankings</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=bans'>
                  <div id='submenu_bans' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_bans' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Banimentos</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=guilds'>
                  <div id='submenu_guilds' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>

                    <div id='ActiveSubmenuItemIcon_guilds' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Guildas</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=team'>
                  <div id='submenu_team' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_team' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Suporte</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=war'>
                  <div id='submenu_war' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>

                    <div id='ActiveSubmenuItemIcon_war' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Guerras de guildas</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=topguilds'>
                  <div id='submenu_topguilds' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_topguilds' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Top guildas</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=frags'>
                  <div id='submenu_frags' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_frags' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>
                      <font color="red">Top Frags</font>
                    </div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
              </div>
            </div>
            <?php echo "<div id='forum' class='menuitem'>
         <span onClick=\"MenuItemAction('forum')\">
	 <div class='MenuButton' style='background-image:url(" .
              $layout_name .
              "/images/menu/button-background.gif);'>
	     <div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'><div class='Button' style='background-image:url(" .
              $layout_name .
              "/images/menu/button-background-over.gif);'></div>
               <span id='forum_Lights' class='Lights'>
                <div class='light_lu' style='background-image:url(" .
              $layout_name .
              "/images/menu/green-light.gif);'></div>
                <div class='light_ld' style='background-image:url(" .
              $layout_name .
              "/images/menu/green-light.gif);'></div>
                <div class='light_ru' style='background-image:url(" .
              $layout_name .
              "/images/menu/green-light.gif);'></div>
               </span>
               <div id='forum_Icon' class='Icon' style='background-image:url(" .
              $layout_name .
              "/images/menu/icon-forum.gif);'></div>
               <div id='forum_Label' class='Label' style='background-image:url(" .
              $layout_name .
              "/images/menu/label-forum.gif);'></div>
               <div id='forum_Extend' class='Extend' style='background-image:url(" .
              $layout_name .
              "/images/general/plus.gif);'></div>
             </div>
           </div>
          </span>
       <div id='forum_Submenu' class='Submenu'>
          <a href='?subtopic=forum'>
           <div id='submenu_forum' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
             <div class='LeftChain' style='background-image:url(" .
              $layout_name .
              "/images/general/chain.gif);'></div>
             <div id='ActiveSubmenuItemIcon_forum' class='ActiveSubmenuItemIcon' style='background-image:url(" .
              $layout_name .
              "/images/menu/icon-activesubmenu.gif);'></div>
             <div class='SubmenuitemLabel'>Fórum</div>
             <div class='RightChain' style='background-image:url(" .
              $layout_name .
              "/images/general/chain.gif);'></div>
           </div>
          </a>
        </div>  
       </div>"; ?>
            <div id='library' class='menuitem'>
              <span onClick="MenuItemAction('library')">
                <div class='MenuButton'
                  style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background.gif);'>
                  <div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'>
                    <div class='Button'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/button-background-over.gif);'>
                    </div>
                    <span id='library_Lights' class='Lights'>
                      <div class='light_lu'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ld'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                      <div class='light_ru'
                        style='background-image:url(<?php echo $layout_name; ?>/images/menu/green-light.gif);'></div>
                    </span>
                    <div id='library_Icon' class='Icon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-library.gif);'></div>
                    <div id='library_Label' class='Label'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/label-library.gif);'></div>
                    <div id='library_Extend' class='Extend'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/plus.gif);'></div>
                  </div>
                </div>
              </span>
              <div id='library_Submenu' class='Submenu'>
                <a href='?subtopic=creatures'>
                  <div id='submenu_creatures' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_creatures' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Criaturas</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <a href='?subtopic=spells'>
                  <div id='submenu_spells' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)'
                    onMouseOut='MouseOutSubmenuItem(this)'>
                    <div class='LeftChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                    <div id='ActiveSubmenuItemIcon_spells' class='ActiveSubmenuItemIcon'
                      style='background-image:url(<?php echo $layout_name; ?>/images/menu/icon-activesubmenu.gif);'>
                    </div>
                    <div class='SubmenuitemLabel'>Magias</div>
                    <div class='RightChain'
                      style='background-image:url(<?php echo $layout_name; ?>/images/general/chain.gif);'></div>
                  </div>
                </a>
                <?php
                if ($config['site']['gallery_page'] == 1) {
                  echo "<a href='?subtopic=gallery'>
  <div id='submenu_gallery' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_gallery' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'>Galeria</div>
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
  </div>
</a>";
                }
                if ($config['site']['serverinfo_page'] == 1) {
                  echo "<a href='?subtopic=serverinfo'>
  <div id='submenu_serverinfo' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_serverinfo' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'>Info do servidor</div>
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
  </div>
</a>";
                }
                ?>
                <?php if ($config['site']['shop_system'] == 0) {
                  echo "<div id='shops' class='menuitem'>
<span onClick=\"MenuItemAction('shops')\">
  <div class='MenuButton' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/button-background.gif);'>
    <div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'><div class='Button' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/button-background-over.gif);'></div>
      <span id='shops_Lights' class='Lights'>
        <div class='light_lu' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/green-light.gif);'></div>
        <div class='light_ld' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/green-light.gif);'></div>
        <div class='light_ru' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/green-light.gif);'></div>
      </span>
      <div id='shops_Icon' class='Icon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-shops.gif);'></div>
      <div id='shops_Label' class='Label' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/label-shops.gif);'></div>
      <div id='shops_Extend' class='Extend' style='background-image:url(" .
                    $layout_name .
                    "/images/general/plus.gif);'></div>
    </div>
  </div>
</span>
</div>
<div id='shops_Submenu' class='Submenu'> 
<a href='?subtopic=donate'>
  <div id='submenu_donate' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_donate' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'><blink style=\"color: green;\">Doar</blink></div>
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
  </div>
</a>
<a href='?subtopic=shopsystem'>
  <div id='submenu_shopsystem' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_shopsystem' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                    $layout_name .
                    "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'><div style=\"color: red;\">Loja</div></div>
    <div class='RightChain' style='background-image:url(" .
                    $layout_name .
                    "/images/general/chain.gif);'></div>
  </div>
</a>";
                  if ($logged) {
                    echo "<a href='?subtopic=shopsystem&action=show_history'>
  <div id='submenu_show_history' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                      $layout_name .
                      "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_show_history' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                      $layout_name .
                      "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'>Hist. de compras</div>
    <div class='RightChain' style='background-image:url(" .
                      $layout_name .
                      "/images/general/chain.gif);'></div>
  </div>
</a>";
                  }
                  if ($logged && $group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
                    echo "<a href='?subtopic=shopadmin'>
  <div id='submenu_shopadmin' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)'>
    <div class='LeftChain' style='background-image:url(" .
                      $layout_name .
                      "/images/general/chain.gif);'></div>
    <div id='ActiveSubmenuItemIcon_shopadmin' class='ActiveSubmenuItemIcon' style='background-image:url(" .
                      $layout_name .
                      "/images/menu/icon-activesubmenu.gif);'></div>
    <div class='SubmenuitemLabel'><font color=red>! Admin da loja !</font></div>
    <div class='RightChain' style='background-image:url(" .
                      $layout_name .
                      "/images/general/chain.gif);'></div>
  </div>
</a>";
                  }
                  echo '</div>';
                } ?>
              </div>
            </div>
            <div id='MenuBottom'
              style='background-image:url(<?php echo $layout_name; ?>/images/general/box-bottom.gif);'></div>
          </div>
          <script type='text/javascript'>
            InitializePage();
          </script>
        </div>
        <div id="ContentColumn">
          <div class="Content">
            <div id="ContentHelper">
              <script type="text/javascript" src="<?php echo $layout_name; ?>/newsticker.js"></script>
              <?php echo $news_content; ?>
              <div id="<?php echo $subtopic; ?>" class="Box">
                <div class="Corner-tl"
                  style="background-image:url(<?php echo $layout_name; ?>/images/content/corner-tl.gif);"></div>
                <div class="Corner-tr"
                  style="background-image:url(<?php echo $layout_name; ?>/images/content/corner-tr.gif);"></div>
                <div class="Border_1"
                  style="background-image:url(<?php echo $layout_name; ?>/images/content/border-1.gif);"></div>
                <div class="BorderTitleText"
                  style="background-image:url(<?php echo $layout_name; ?>/images/content/title-background-green.gif);">
                </div>
                <img class="Title" src="headline.php?text=<?php echo rawurlencode($topic); ?>"
                  alt="<?php echo htmlspecialchars($topic, ENT_QUOTES, 'UTF-8'); ?>" />
                <div class="Border_2">
                  <div class="Border_3">
                    <div class="BoxContent"
                      style="background-image:url(<?php echo $layout_name; ?>/images/content/scroll.gif);">
                      <?php echo $main_content; ?>
                    </div>
                  </div>
                </div>
                <div class="Border_1"
                  style="background-image:url(<?php echo $layout_name; ?>/images/content/border-1.gif);"></div>

                <div class="CornerWrapper-b">
                  <div class="Corner-bl"
                    style="background-image:url(<?php echo $layout_name; ?>/images/content/corner-bl.gif);"></div>
                </div>
                <div class="CornerWrapper-b">
                  <div class="Corner-br"
                    style="background-image:url(<?php echo $layout_name; ?>/images/content/corner-br.gif);"></div>
                </div>
              </div>
            </div>
          </div>
          <div id="Footer">
            <?php
            $time_end = microtime_float();
            $time = $time_end - $time_start;
            ?>
            <font color="yellow">&copy; <?php echo date('Y'); ?>
              <?php echo htmlspecialchars($config['server']['serverName'], ENT_QUOTES, 'UTF-8'); ?> —
              Todos os direitos reservados.<br />
              <font color="white">Tempo de carregamento: <?php echo round($time, 4); ?> segundos</font>
            </font>
          </div>
        </div>
        <div id="ThemeboxesColumn">
          <div id="RightArtwork">
            <img id="Monster" src="images/monsters/<?php echo logo_monster(); ?>.gif"
              onClick="window.location = '?subtopic=creatures&amp;creature=<?php echo logo_monster(); ?>';"
              alt="Monstro da semana" />
            <img id="PedestalAndOnline" src="<?php echo $layout_name; ?>/images/header/pedestal-and-online.gif"
              alt="Monster Pedestal and Jogadores online Box" />
            <?php if (count($config['site']['worlds']) > 1) {
              $whoisonlineworld = '?subtopic=whoisonline';
            } else {
              $whoisonlineworld = '?subtopic=whoisonline&world=0';
            } ?>
            <div id="PlayersOnline" onClick="window.location='<?php echo $whoisonlineworld; ?>'">

              <?php
              $update_interval = 2;
              if ($config['status']['serverStatus_online'] == 1) {
                echo $config['status']['serverStatus_players'] . '<br />Jogadores online';
              } else {
                echo '<font color="red"><b>Servidor<br />Offline</b></font>';
              }
              ?>
            </div>
          </div>
          <div id="Themeboxes">
            <?php include $layout_name . '/widget_rank.php'; ?>
            <div id="NewcomerBox" class="Themebox"
              style="background-image:url(<?php echo $layout_name; ?>/images/themeboxes/newcomer/newcomerbox.gif);">
              <br />
              <div class="ThemeboxButton" onClick="BigButtonAction('?subtopic=createaccount')"
                onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);"
                style="background-image:url(<?php echo $layout_name; ?>/images/buttons/sbutton.gif);">
                <div class="BigButtonOver"
                  style="background-image:url(<?php echo $layout_name; ?>/images/buttons/sbutton_over.gif);"></div>
                <div class="ButtonText"
                  style="background-image:url(<?php echo $layout_name; ?>/images/buttons/_sbutton_jointibia.gif);">
                </div>
              </div>
              <div class="Bottom"
                style="background-image:url(<?php echo $layout_name; ?>/images/general/box-bottom.gif);"></div>
            </div>
            <?php if ($config['site']['screenoftheday'] == 1) {
              echo '<div id="ScreenshotBox" class="Themebox" style="background-image:url(' .
                $layout_name .
                '/images/themeboxes/screenshot/screenshotbox.gif);">
      <a href="?subtopic=gallery" >
        <img id="ScreenshotContent" class="ThemeboxContent" src="images/screenshotoftheday.gif" alt="Screenshot of the Day" /></a>
    <div class="Bottom" style="background-image:url(' .
                $layout_name .
                '/images/general/box-bottom.gif);"></div>
    </div>';
            } ?>
            <?php
            $time = time();
            $viewpoll = $SQL->query('SELECT * FROM z_polls where end > ' . $time . ' ORDER BY id DESC LIMIT 1');
            $polls = '';
            $p = null;
            foreach ($viewpoll as $row) {
              $p = $row;
              $polls .= '<center>' . $row['question'] . '</center>';
            }
            if (!empty($p['id'])) {
              echo '<div id="CurrentPollBox" class="Themebox" style="background-image:url(' .
                $layout_name .
                '/images/themeboxes/current-poll/currentpollbox.gif);">
      <div id="CurrentPollText">' .
                $polls .
                '</div>
      <a class="ThemeboxButton" href="?subtopic=polls&id= ' .
                $p['id'] .
                '" onMouseOver="MouseOverBigButton(this);" onMouseOut="MouseOutBigButton(this);" style="background-image:url(' .
                $layout_name .
                '/images/buttons/sbutton.gif);"><div class="BigButtonOver" style="background-image:url(' .
                $layout_name .
                '/images/buttons/sbutton_over.gif);"></div>
        <div class="ButtonText" style="background-image:url(' .
                $layout_name .
                '/images/buttons/_sbutton_votenow.gif);"></div>
      </a>
    <div class="Bottom" style="background-image:url(' .
                $layout_name .
                '/images/general/box-bottom.gif);"></div>
    </div>';
            }
            ?>
            <?php if ($logged && $group_id_of_acc_logged >= $config['site']['access_admin_panel']) {
              echo '<div id="CurrentPollBox" class="Themebox" style="background-image:url(' .
                $layout_name .
                '/images/themeboxes/admin/admin.gif);">
      <div id="CurrentPollText">
	<b><a href="?subtopic=adminpanel"><b>Painel admin</b></a><b><br>
	<b><a href="?subtopic=namelock"><b>Namelocks</b></a><b><br>
	<b><a href="?subtopic=polls"><b>Gerenciar enquetes</b></a><b><br>
	<b><a href="?subtopic=shopadmin"><b>Admin da loja</b></a><b></div>
    <div class="Bottom" style="background-image:url(' .
                $layout_name .
                '/images/general/box-bottom.gif);"></div>
    </div>';
            } ?>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>

</html>
