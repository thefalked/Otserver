<?php
// PagSeguro return page disabled (secrets cleared; old callback removed).
http_response_code(410);
header('Content-Type: text/plain; charset=UTF-8');
echo "PagSeguro return disabled.\n";
exit;
