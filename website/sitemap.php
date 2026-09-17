<?php
header('Content-Type: application/xml; charset=UTF-8');

$config = [];
include __DIR__ . '/config/config.php';
$site_url = rtrim((string) ($config['site']['site_url'] ?? 'https://baiakvip9.servegame.com'), '/');

$pages = [
  ['path' => '/', 'priority' => '1.0', 'changefreq' => 'daily', 'file' => 'latestnews.php'],
  ['path' => '/?subtopic=createaccount', 'priority' => '0.9', 'changefreq' => 'monthly', 'file' => 'createaccount.php'],
  ['path' => '/?subtopic=downloads', 'priority' => '0.9', 'changefreq' => 'weekly', 'file' => 'downloads.php'],
  ['path' => '/?subtopic=serverinfo', 'priority' => '0.8', 'changefreq' => 'weekly', 'file' => 'serverinfo.php'],
  ['path' => '/?subtopic=whoisonline', 'priority' => '0.8', 'changefreq' => 'hourly', 'file' => 'whoisonline.php'],
  ['path' => '/?subtopic=highscores', 'priority' => '0.8', 'changefreq' => 'daily', 'file' => 'highscores.php'],
  ['path' => '/?subtopic=characters', 'priority' => '0.7', 'changefreq' => 'daily', 'file' => 'characters.php'],
  ['path' => '/?subtopic=guilds', 'priority' => '0.7', 'changefreq' => 'daily', 'file' => 'guilds.php'],
  ['path' => '/?subtopic=forum', 'priority' => '0.7', 'changefreq' => 'daily', 'file' => 'forum.php'],
  ['path' => '/?subtopic=changelog', 'priority' => '0.7', 'changefreq' => 'weekly', 'file' => 'changelog.php'],
  ['path' => '/?subtopic=tibiarules', 'priority' => '0.6', 'changefreq' => 'monthly', 'file' => 'tibiarules.php'],
  ['path' => '/?subtopic=team', 'priority' => '0.6', 'changefreq' => 'monthly', 'file' => 'team.php'],
  ['path' => '/?subtopic=spells', 'priority' => '0.6', 'changefreq' => 'monthly', 'file' => 'spells.php'],
  ['path' => '/?subtopic=creatures', 'priority' => '0.6', 'changefreq' => 'monthly', 'file' => 'creatures.php'],
  ['path' => '/?subtopic=experiencetable', 'priority' => '0.5', 'changefreq' => 'monthly', 'file' => 'experiencetable.php'],
  ['path' => '/?subtopic=killstatistics', 'priority' => '0.5', 'changefreq' => 'daily', 'file' => 'killstatistics.php'],
  ['path' => '/?subtopic=frags', 'priority' => '0.5', 'changefreq' => 'daily', 'file' => 'frags.php'],
  ['path' => '/?subtopic=fragers', 'priority' => '0.5', 'changefreq' => 'daily', 'file' => 'fragers.php'],
  ['path' => '/?subtopic=topguilds', 'priority' => '0.5', 'changefreq' => 'daily', 'file' => 'topguild.php'],
  ['path' => '/?subtopic=war', 'priority' => '0.5', 'changefreq' => 'daily', 'file' => 'war.php'],
  ['path' => '/?subtopic=shopsystem', 'priority' => '0.6', 'changefreq' => 'weekly', 'file' => 'shopsystem.php'],
  ['path' => '/?subtopic=donate', 'priority' => '0.5', 'changefreq' => 'monthly', 'file' => 'donate.php'],
  ['path' => '/?subtopic=archive', 'priority' => '0.4', 'changefreq' => 'weekly', 'file' => 'archive.php'],
  ['path' => '/?subtopic=records', 'priority' => '0.4', 'changefreq' => 'weekly', 'file' => 'records.php'],
  ['path' => '/?subtopic=vantagens', 'priority' => '0.5', 'changefreq' => 'monthly', 'file' => 'vantagens.php'],
  ['path' => '/?subtopic=gallery', 'priority' => '0.4', 'changefreq' => 'weekly', 'file' => 'gallery.php'],
  ['path' => '/?subtopic=polls', 'priority' => '0.4', 'changefreq' => 'weekly', 'file' => 'polls.php'],
  ['path' => '/?subtopic=scrollnews', 'priority' => '0.4', 'changefreq' => 'daily', 'file' => 'scrollnews.php']
];

echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";
foreach ($pages as $page) {
  $loc = htmlspecialchars($site_url . $page['path'], ENT_XML1 | ENT_QUOTES, 'UTF-8');
  $source = __DIR__ . '/' . $page['file'];
  $mtime = is_file($source) ? filemtime($source) : time();
  $lastmod = gmdate('Y-m-d', $mtime);
  echo "  <url>\n";
  echo '    <loc>' . $loc . "</loc>\n";
  echo '    <lastmod>' . $lastmod . "</lastmod>\n";
  echo '    <changefreq>' . $page['changefreq'] . "</changefreq>\n";
  echo '    <priority>' . $page['priority'] . "</priority>\n";
  echo "  </url>\n";
}
echo "</urlset>\n";
