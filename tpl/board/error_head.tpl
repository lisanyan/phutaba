<!DOCTYPE html>
<html lang="en">
<head>
	<title><var $$cfg{TITLE}> &raquo; <var $error_page></title>
	<meta charset="<const CHARSET>" />
	<link rel="stylesheet" type="text/css" href="/static/css/phutaba.css" />
	<link rel="shortcut icon" type="image/x-icon" href="/img/favicon.ico" />
	<link rel="icon" type="image/x-icon" href="/img/favicon.ico" />
	<link rel="apple-touch-icon-precomposed" href="/img/favicon-152.png" />
	<meta name="msapplication-TileImage" content="/img/favicon-144.png" />
	<meta name="msapplication-TileColor" content="#ECE9E2" />
	<meta name="msapplication-navbutton-color" content="#BFB5A1" />
	<meta name="msapplication-config" content="none" />
</head>

<body>
<div class="content">

<nav>
	<ul class="menu">
<include tpl/nav_boards.html>
	</ul>

	<ul class="menu right">
<include tpl/nav_pages.html>
	</ul>
</nav>

<header>
	<div class="header">
		<div class="banner"><a href="/"><if $$cfg{ENABLE_BANNERZ}><img src="/banner.pl" alt="" /></if></a></div>
		<div class="boardname"><var $$cfg{TITLE}></div>
	</div>
</header>

<hr />

<div class="error">
	<div class="title"><var $error_title></div>