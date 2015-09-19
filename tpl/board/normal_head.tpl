<!DOCTYPE html>
<html lang="en">
<head>
<title><var $$cfg{TITLE}> &raquo; <if $title><var $title></if><if !$title>/<var $$cfg{SELFPATH}>/ - <var $$cfg{BOARD_NAME}></if></title>
<meta charset="<const CHARSET>" />

<link rel="shortcut icon" href="/img/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/static/css/phutaba.css" />
<loop $stylesheets><link rel="alternate stylesheet" type="text/css" href="/static/css/<var lc($filename)>" title="<var $title>" />
</loop>
<link rel="alternate" type="application/rss+xml" title="RSS" href="<var Wakaba::expand_filename("board.rss", 1)>" />

<if $$cfg{STYLESHEET}><link rel="stylesheet" type="text/css" href="<var $$cfg{STYLESHEET}>" /></if>
<if test_afmod()><link rel="stylesheet" type="text/css" href="/static/css/af.css" /></if>

<link rel="shortcut icon" type="image/x-icon" href="/img/favicon.ico" />
<link rel="icon" type="image/x-icon" href="/img/favicon.ico" />
<link rel="apple-touch-icon-precomposed" href="/img/favicon-152.png" />
<meta name="msapplication-TileImage" content="/img/favicon-144.png" />
<meta name="msapplication-TileColor" content="#ECE9E2" />
<meta name="msapplication-navbutton-color" content="#BFB5A1" />
<meta name="msapplication-config" content="none" />
<if $$cfg{TITLE} && !$thread>
<meta name="application-name" content="<var $$cfg{TITLE}> /<var $$cfg{SELFPATH}>/" />
<meta name="apple-mobile-web-app-title" content="<var $$cfg{TITLE}>" />
</if>

<script type="text/javascript">var style_cookie="<var $$cfg{STYLE_COOKIE}>";</script>
<script type="text/javascript" src="/static/js/wakaba3.js"></script>

<style type="text/css">
<var $$cfg{ADDITIONAL_CSS}>
</style>
</head>

<if $thread><body class="replypage"></if>
<if !$thread><body></if>

<if $isAdmin>
<div id="modpanel" style="display: none">
<div style="display: none; min-width: 250px;" id="banexpireshelp">
<const S_BANEXPIRESDESC>
</div>

<table>
<tr>
	<td><b><const S_BANIPLABEL></b></td><td><input id="ip" type="text" name="ip" size="40" /></td>
</tr>
<tr><td><b><const S_BANMASKLABEL></b></td><td>
<select id="netmask" name="netmask">
  <option value="255.0.0.0">/8 (IPv4 Class A)</option>
  <option value="255.255.0.0" selected="selected">/16 (IPv4 Class B)</option>
  <option value="255.255.255.0">/24 (IPv4 Class C)</option>
  <option value="255.255.255.255">/32 (IPv4 Host)</option>
  <option value="ffff:ffff:ffff:0000:0000:0000:0000:0000">/48 (IPv6)</option>
  <option value="ffff:ffff:ffff:ff00:0000:0000:0000:0000">/56 (IPv6)</option>
  <option value="ffff:ffff:ffff:ffff:0000:0000:0000:0000">/64 (IPv6)</option>
  <option value="ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff">/128 (IPv6 Host)</option>
</select>
</td></tr>
<tr>
	<td><b><const S_BANREASONLABEL></b></td><td><input id="reason" type="text" name="reason" size="40" /></td>
</tr>
<tr>
	<td><label for="expires"><b<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><const S_BANEXPIRESLABEL></b></label></td>
	<td><if !$parsedate and scalar (BAN_DATES)>
		<select id="expires" name="expires">
			<loop (BAN_DATES)>
				<option value="<var $time>"<if $default> selected="selected"</if>><var clean_string($label)></option>
			</loop>
		</select>
	<else>
		<input type="text" id="expires" name="expires" size="16" />
		<if !$parsedate><small><const S_BANSECONDS></small></if>
	</if>
</td></tr>
<tr><td><label for="blame"><b>Ban Sign</b></label></td><td><input id="blame" type="checkbox" name="blame" value="yes" /></td></tr>
</table>
<div id="infobox" style="display: none">
<br />
<b>IP</b>: <span id="r_ip"></span><br />
<b>Netmask</b>: <span id="r_mask"></span><br />
<b>Comment</b>: <span id="r_reason"></span><br />
<b>Post</b>: <span id="r_post"></span><br />
<b>Expires</b>: <span id="r_expires"></span><br />
</div>
<p id="info" style="display: none"><span style="font-weight: bolder; color: #002233;">Info: <span style="font-weight: bolder" id="infodetails"></span></span></p>
<p id="error" style="display: none"><span style="font-weight: bolder; color: #FF0000;">Error: <span style="font-weight: bolder" id="errordetails"></span></span></p>
</div>
</if>

<div class="content">

<script type="text/javascript" src="/static/js/wz_tooltip.js"></script>

<nav>
	<ul class="menu">
	<!-- we do not need nav_boards_admin anymore -->
	<include tpl/nav_boards.html>
	</ul>
	<ul class="menu" id="s-styles">
	<loop $stylesheets><li> <a href="javascript:set_stylesheet_frame('<var $title>','list')"><var $title></a> </li></loop>
	<li><a href="javascript:set_stylesheet_frame(null,'list')">Default</a></li>
	</ul>

	<ul class="menu right">
	<li><a href="#" onclick="show_el('s-styles'); return false;"><const S_JS_STYLES></a></li>
	<li><a href="<var %self>?task=search&amp;section=<var $$cfg{SELFPATH}>"><const S_SEARCH></a></li>
	<include tpl/nav_pages.html>
	</ul>
</nav>

<header>
	<div class="header">
		<div class="banner">
			<a href="/<var $$cfg{SELFPATH}>/">
				<if $$cfg{ENABLE_BANNERZ}><img src="/banner.pl?board=<var $$cfg{SELFPATH}>" alt="<var $$cfg{SELFPATH}>" /></if>
			</a>
		</div>
		<div class="boardname" <if $$cfg{BOARD_DESC}>style="margin-bottom: 5px;"</if>>/<var $$cfg{SELFPATH}>/ &ndash; <var $$cfg{BOARD_NAME}></div>
		<if $$cfg{BOARD_DESC}><div class="slogan">&bdquo;<var $$cfg{BOARD_DESC}>&ldquo;</div></if>
	</div>
</header>

<if !DISABLE_NEW_THREADS or $isAdmin or $thread or $admin><hr /></if>