<?php
// PagSeguro callback disabled: old script used removed mysql_* APIs and hardcoded DB credentials.
// Re-enable only after a PDO rewrite using env secrets (AAC_PAGSEGURO_*).
http_response_code(410);
header('Content-Type: text/plain; charset=UTF-8');
echo "Payment callback disabled.\n";
exit;
