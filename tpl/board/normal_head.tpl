<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="<const Wakaba::CHARSET>" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title><var $$cfg{TITLE}> &raquo; <if $title><var $title></if><if !$title>/<var $$cfg{SELFPATH}>/ - <var $$cfg{BOARD_NAME}></if></title>

<link rel="shortcut icon" href="/img/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/static/css/phutaba.css" />
<loop $stylesheets><link rel="alternate stylesheet" type="text/css" href="/static/css/<var lc($filename)>" title="<var $title>" />
</loop>
<link rel="alternate" type="application/rss+xml" title="RSS" href="<var Wakaba::expand_filename("board.rss", 1)>" />

<if Wakaba::test_afmod($$cfg{ENABLE_AFMOD})><link rel="stylesheet" type="text/css" href="/static/css/af.css" /></if>

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

<style type="text/css">
<var $$cfg{ADDITIONAL_CSS}>
</style>
</head>

<if $thread><body class="replypage"></if>
<if !$thread><body></if>

<if $admin>
<div id="modpanel" style="display: none">

<table>
<tr>
	<td><b><var $$locale{S_BANIPLABEL}></b></td><td><input id="ip" type="text" name="ip" size="40" /></td>
</tr>
<tr><td><b><var $$locale{S_BANMASKLABEL}></b></td><td>
<include %TMPLDIR%netmask_select.tpl>
</td></tr>
<tr>
	<td><b><var $$locale{S_BANREASONLABEL}></b></td><td><input id="reason" type="text" name="reason" size="40" /></td>
</tr>
<tr>
	<td><label for="expires"><b><var $$locale{S_BANEXPIRESLABEL}>&nbsp;</b></label></td>
	<td><include %TMPLDIR%duration_select.tpl></td>
</tr>
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

<div id="overlay">
  <div id="settings" class="settings">
	<div class="settingsTitle">
	  <span><var $$locale{S_JS_SETTINGS}></span>
	</div>
	<hr />
	<div class="title">
	  <span><var $$locale{S_JS_STYLES}></span>
	</div>
	<div class="info">
	  <loop $stylesheets>[<a href="javascript:set_stylesheet_frame('<var $title>','list')"><var $title></a>] </loop>
	  [<a href="javascript:set_stylesheet_frame(null,'list')">Default</a>]
	</div>
	<hr />
	<div id="settingsConfig"></div>
	<hr />
	<div class="settingsDone">
	  [<a href="javascript:void(0)" id="navmenu1"><var $$locale{S_JS_DONE}></a>]
	</div>
  </div>
</div>

<div class="content">
<script type="text/javascript" src="/static/vendor/wz_tooltip.js"></script>

<nav>
	<ul class="menu">
	<!-- we do not need nav_boards_admin anymore -->
	<include tpl/nav_boards.html>
	</ul>

	<ul class="menu right">
	<li><a href="javascript:void(0)" id="navmenu0"><var $$locale{S_OPTIONS}></a></li>
	<li><a href="<var %self>?task=search&amp;section=<var $$cfg{SELFPATH}>"><var $$locale{S_SEARCH}></a></li>
	<include tpl/nav_pages.html>
	</ul>
</nav>

<header>
	<div class="header">
		<div class="banner">
			<a href="/<var $$cfg{SELFPATH}>/">
				<if $$cfg{ENABLE_BANNERS}><img src="/banner.pl?board=<var $$cfg{SELFPATH}>" alt="<var $$cfg{SELFPATH}>" /></if>
			</a>
		</div>
		<div class="boardname" <if $$cfg{BOARD_DESC}>style="margin-bottom: 5px;"</if>>/<var $$cfg{SELFPATH}>/ &ndash; <var $$cfg{BOARD_NAME}></div>
		<if $$cfg{BOARD_DESC}><div class="slogan">&bdquo;<var $$cfg{BOARD_DESC}>&ldquo;</div></if>
	</div>
</header>

<if $postform or $admin or $locked><hr id="postform_hr"/></if>
