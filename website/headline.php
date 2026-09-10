<?PHP
$text = isset($_GET['text']) ? (string) $_GET['text'] : '';
// Letters/digits/spaces only — blocks path traversal and control chars
if ($text === '' || mb_strlen($text) > 80 || !preg_match('/^[\p{L}\p{N}][\p{L}\p{N} _\-?]{0,79}$/u', $text)) {
	http_response_code(400);
	exit;
}
$dir = realpath(__DIR__ . '/images/head');
if ($dir === false || !is_dir($dir)) {
	http_response_code(500);
	exit;
}
$path = $dir . DIRECTORY_SEPARATOR . $text . '.png';
$parent = realpath(dirname($path));
if ($parent === false || strpos($parent, $dir) !== 0) {
	http_response_code(400);
	exit;
}
if (!file_exists($path))
{
	$font = $dir . '/martel.ttf';
	$base = $dir . '/headline.png';
	if (!is_file($font) || !is_file($base)) {
		http_response_code(500);
		exit;
	}
	$image = imagecreatefrompng($base);
	imagettftext($image, 18, 0, 4, 20, imagecolorallocate($image, 240, 209, 164), $font, $text);
	imagepng($image, $path);
	imagedestroy($image);
}
$pic = imagecreatefrompng($path);
header('Content-type: image/png');
imagepng($pic);
imagedestroy($pic);
?>
