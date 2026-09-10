<?php
/**
 * Backward-compatible loader for PHPMailer 7.x.
 * Existing site code expects require("phpmailer/class.phpmailer.php") and new PHPMailer().
 */
require_once __DIR__ . '/src/Exception.php';
require_once __DIR__ . '/src/PHPMailer.php';
require_once __DIR__ . '/src/SMTP.php';

if (!class_exists('PHPMailer', false)) {
	/**
	 * Global alias with legacy method names used by this site (PHPMailer 5.x style).
	 */
	class PHPMailer extends \PHPMailer\PHPMailer\PHPMailer
	{
		public function IsSMTP()
		{
			$this->isSMTP();
		}

		public function IsMail()
		{
			$this->isMail();
		}

		public function IsHTML($isHtml = true)
		{
			$this->isHTML($isHtml);
		}

		public function AddAddress($address, $name = '')
		{
			return $this->addAddress($address, $name);
		}

		public function Send()
		{
			return $this->send();
		}
	}
}
