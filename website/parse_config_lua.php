<?php /** Parse TFS config.lua (key = value). Avoids parse_ini_file Lua breakage. */
function parse_config_lua($path)
{
	$config = [];
	$lines = @file($path);
	if (!is_array($lines)) {
		return $config;
	}
	foreach ($lines as $line) {
		$line = trim($line);
		if ($line === '' || substr($line, 0, 2) === '--') {
			continue;
		}
		if (!preg_match('/^([A-Za-z0-9_]+)\s*=\s*(.+)$/', $line, $m)) {
			continue;
		}
		$k = $m[1];
		$v = trim($m[2]);
		if (preg_match('/^"(.*)"$/', $v, $q)) {
			$v = $q[1];
		} elseif (preg_match("/^'(.*)'$/", $v, $q)) {
			$v = $q[1];
		} elseif (in_array(strtolower((string) $v), ['true', 'false'], true)) {
			$v = strtolower($v) === 'true';
		} elseif (is_numeric($v)) {
			$v = $v + 0;
		}
		$config[$k] = $v;
	}
	return $config;
}
