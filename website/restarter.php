<?php
// Windows TASKKILL / Baiak-Map.bat restarter — disabled under Linux Docker.
if (!isset($group_id_of_acc_logged) || $group_id_of_acc_logged < $config['site']['access_admin_panel']) {
	$title = $GLOBALS['config']['server']['serverName'] . ' - OTS';
	$main_content .= 'Invalid subtopic. Can\'t load page.';
	return;
}

$main_content .= '<div class="TableContainer"><table class="Table1" width="100%" cellpadding="4">'
	. '<tr><td><b>Server restarter</b></td></tr>'
	. '<tr><td>This tool used Windows <code>TASKKILL</code> / <code>Baiak-Map.bat</code> and is '
	. '<b>disabled</b> on the Linux Docker stack. Use <code>docker compose restart otserver</code> instead.'
	. '</td></tr></table></div>';
