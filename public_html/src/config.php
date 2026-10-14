<?php

$config['db']['host'] = getenv('XF_DB_HOST') ?: 'localhost';
$config['db']['port'] = getenv('XF_DB_PORT') ?: 3306;
$config['db']['username'] = getenv('XF_DB_USER') ?: 'mafialiv1';
$config['db']['password'] = getenv('XF_DB_PASSWORD') ?: 'kS6eIYnSlKArdFy';
$config['db']['dbname'] = getenv('XF_DB_NAME') ?: 'mafialiv_forum';
$config['db']['socket'] = null;

// Workspace proxy serves the app under /proxy/<port>/ while Apache sees /.
$prefix = getenv('XF_URL_PREFIX');
if ($prefix) {
	$prefix = '/' . trim($prefix, '/');
	foreach (['REQUEST_URI', 'SCRIPT_NAME', 'PHP_SELF'] as $key) {
		if (!empty($_SERVER[$key]) && strpos($_SERVER[$key], $prefix) !== 0) {
			$_SERVER[$key] = $prefix . $_SERVER[$key];
		}
	}
	if (!empty($_SERVER['HTTP_X_FORWARDED_HOST'])) {
		$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
	}
	if (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https') {
		$_SERVER['HTTPS'] = 'on';
	}
	$config['cookie']['path'] = $prefix;
}
