<?PHP
$text = isset($_GET['text']) ? (string) $_GET['text'] : '';
if (!mb_check_encoding($text, 'UTF-8')) {
	$text = mb_convert_encoding($text, 'UTF-8', 'ISO-8859-1');
}
$text = trim($text);
// Letters/digits/spaces — Unicode letters allowed (pt-BR accents)
if ($text === '' || mb_strlen($text, 'UTF-8') > 80 || !preg_match('/^[\p{L}\p{N}][\p{L}\p{N} _\-?]{0,79}$/u', $text)) {
	http_response_code(400);
	exit;
}
$dir = realpath(__DIR__ . '/images/head');
if ($dir === false || !is_dir($dir)) {
	http_response_code(500);
	exit;
}
// Hash cache name avoids broken filenames when filesystem/encoding mangles accents
$cacheName = 'h_' . md5($text) . '.png';
$path = $dir . DIRECTORY_SEPARATOR . $cacheName;
$legacyPath = $dir . DIRECTORY_SEPARATOR . $text . '.png';

$fontCandidates = array(
	$dir . '/DejaVuSerif-Bold.ttf',
	$dir . '/martel.ttf',
	'/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf',
);
$font = null;
foreach ($fontCandidates as $candidate) {
	if (is_file($candidate)) {
		$font = $candidate;
		break;
	}
}
$base = $dir . '/headline.png';
if ($font === null || !is_file($base)) {
	http_response_code(500);
	exit;
}

header('Content-Type: image/png');
header('Cache-Control: public, max-age=86400');

if (is_file($path)) {
	$pic = @imagecreatefrompng($path);
	if ($pic !== false) {
		imagepng($pic);
		imagedestroy($pic);
		exit;
	}
}

$image = imagecreatefrompng($base);
if ($image === false) {
	http_response_code(500);
	exit;
}
imagealphablending($image, true);
imagesavealpha($image, true);
$color = imagecolorallocate($image, 240, 209, 164);
imagettftext($image, 14, 0, 4, 20, $color, $font, $text);

// Prefer disk cache when the bind-mount is writable; otherwise stream only.
if (is_writable($dir)) {
	@imagepng($image, $path);
	if (is_file($legacyPath) && realpath($legacyPath) !== realpath($path)) {
		@unlink($legacyPath);
	}
}

imagepng($image);
imagedestroy($image);
?>
