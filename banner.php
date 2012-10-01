<?php

$board = $_GET['board'];

if(!isset($_GET['board']))
	$board = "/";

switch($board) {
#		case 'fe':
#			$dh = opendir('img/banner/fefe/');
#			$prefix = '/fefe/';
#			break;
		case 'ö':
			$dh = opendir('img/banner/oe/');
			$prefix = '/oe/';
			break;
		default:
			$dh = opendir('img/banner/');
			$prefix = '/';
}


$filearray = array();
while (false !== ($file = readdir($dh))) {
	if(!(substr($file, 0, 1) == ".")) {
		array_push($filearray, $file);
	}
}

srand ((double) microtime() * 1000000);
$randombanner = rand(0,count($filearray)-1);
header("Location: /img/banner{$prefix}{$filearray[$randombanner]}");

?>
