use strict;

BEGIN { require "wakautils.pl"; }

use constant NORMAL_HEAD_INCLUDE => q{

<!DOCTYPE html>
<html lang="de">
<head>
<title><var strip_html(TITLE)> &raquo; <if $title><var strip_html($title)></if><if !$title>/<const BOARD_IDENT>/ - <var strip_html(BOARD_NAME)></if></title>
<meta charset="<const CHARSET>" />

<link rel="stylesheet" type="text/css" href="/css/phutaba.css" />
<if STYLESHEET><link rel="stylesheet" type="text/css" href="<const STYLESHEET>" /></if>
<if test_afmod()><link rel="stylesheet" type="text/css" href="/css/af.css" /></if>
<link rel="shortcut icon" type="image/x-icon" href="/img/favicon.ico" />
<link rel="icon" type="image/x-icon" href="/img/favicon.ico" />
<link rel="apple-touch-icon-precomposed" href="/img/favicon-152.png" />
<meta name="msapplication-TileImage" content="/img/favicon-144.png" />
<meta name="msapplication-TileColor" content="#ECE9E2" />
<meta name="msapplication-navbutton-color" content="#BFB5A1" />
<meta name="msapplication-config" content="none" />
<if TITLE && !$thread>
<meta name="application-name" content="<const TITLE> /<const BOARD_IDENT>/" />
<meta name="apple-mobile-web-app-title" content="<const TITLE>" />
</if>
<script type="text/javascript" src="/js/wakaba3.js"></script>

<if $isAdmin>
	<link rel="stylesheet" type="text/css" href="/css/ui-lightness/jquery-ui-1.10.2.custom.css" />
</if>

<style type="text/css">
<const ADDITIONAL_CSS>
</style>
</head>

<body>

<if $isAdmin>
<div id="modpanel" style="display: none">
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
<tr><td><b><const S_BANDURATION></b></td><td>
<select id="duration" name="duration">
	<option value="86400">1 Tag</option>
	<option value="259200">3 Tage</option>
	<option value="432000">5 Tage</option>
	<option value="604800">1 Woche</option>
	<option value="2419200">4 Wochen</option>
	<option value="">Permanent</option>
</select>
</td></tr>
<tr>
	<td><b><const S_BANREASONLABEL></b></td><td><input id="reason" type="text" name="reason" size="40" /></td>
</tr>
<tr>
	<td colspan="2">
	<label><input id="ban_flag" type="checkbox" name="ban_flag" value="1" checked="checked" /> <b><const S_BANFLAGPOST></b></label>
	</td>
</tr>
</table>
<div id="infobox" style="display: none">
	<br />
	<b><const S_BANIPLABEL></b>: <span id="r_ip"></span><br />
	<b><const S_BANMASKLABEL></b>: <span id="r_mask"></span><br />
	<b>Ende</b>: <span id="r_expires"></span><br />
	<b><const S_BANREASONLABEL></b>: <span id="r_reason"></span><br />
	<b>Post-Nr.</b>: <span id="r_post"></span><br />
</div>
<p id="info" style="display: none"><span style="font-weight: bolder; color: #002233;">Info: <span style="font-weight: bolder" id="infodetails"></span></span></p>
<p id="error" style="display: none"><span style="font-weight: bolder; color: #FF0000;">Error: <span style="font-weight: bolder" id="errordetails"></span></span></p>
</div>
</if>

<div class="content">

<script type="text/javascript" src="/js/wz_tooltip.js"></script>

<nav>
	<ul class="menu">
} . include("../tpl/nav_boards.html") . q{
	</ul>

	<ul class="menu right">
} . include("../tpl/nav_pages.html") . q{
	</ul>
</nav>

<header>
	<div class="header">
		<div class="banner">
			<a href="/<const BOARD_IDENT>/">
				<img src="/banner.pl?board=<const BOARD_IDENT>" alt="Banner" />
			</a>
		</div>
		<div class="boardname" <if BOARD_DESC>style="margin-bottom: 5px;"</if>>/<const BOARD_IDENT>/ &ndash; <const BOARD_NAME></div>
		<if BOARD_DESC><div class="slogan">&bdquo;<const BOARD_DESC>&ldquo;</div></if>
	</div>
</header>

<if !DISABLE_NEW_THREADS or $isAdmin or $thread or $admin><hr /></if>

};


use constant MANAGER_HEAD_INCLUDE => NORMAL_HEAD_INCLUDE . q{

<if $admin>
	<!--[<a href="<var expand_filename(HTML_SELF)>"><const S_MANARET></a>]-->
	[<a href="<var $self>?board=<const BOARD_IDENT>&amp;task=show"><const S_MANAPANEL></a>]
	[<a href="<var $self>?board=<const BOARD_IDENT>&amp;task=mpanel"><const S_MANATOOLS></a>]
	[<a href="<var $self>?board=<const BOARD_IDENT>&amp;task=bans"><const S_MANABANS></a>]
	[<a href="<var $self>?board=<const BOARD_IDENT>&amp;task=orphans"><const S_MANAORPH></a>]
	[<a href="<var $self>?board=<const BOARD_IDENT>&amp;task=logout"><const S_MANALOGOUT></a>]
	<div class="passvalid"><const S_MANAMODE></div>
</if>
};


use constant NORMAL_FOOT_INCLUDE => q{

<footer>
	<p>Powered by <img src="/img/phutaba_icon.png" alt="" /> <strong>Phutaba</strong>.</p>
	<if ABUSE_EMAIL><p><em>Report illegal material to <a href="mailto:<const ABUSE_EMAIL>"><const ABUSE_EMAIL></a>.</em></p></if>
</footer>
<nav>
	<ul class="menu_bottom">
} . include("../tpl/nav_boards.html") . q{
	</ul>
</nav>
</div>
<const TRACKING_CODE>

<script type="text/javascript" src="/js/jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.blockUI.js"></script>

<if $isAdmin>
        <script type="text/javascript" src="/js/jquery/jquery-ui-1.10.2.custom.min.js"></script>
        <script type="text/javascript" src="/js/admin.js"></script>
</if>

<if ENABLE_HIDE_THREADS && !$thread>
<script type="text/javascript" src="/js/jquery/jquery.cookie.js"></script>
<script type="text/javascript" src="/js/hidethreads.js"></script>
</if>

<script type="text/javascript">
/* <![CDATA[ */
  $j = jQuery.noConflict();
  $j(document).ready(function() {
    var match;
    if ((match = /#i([0-9]+)/.exec(document.location.toString())) && !document.forms.postform.field4.value) insert(">>" + match[1] + "\n");
    if ((match = /#([0-9]+)/.exec(document.location.toString()))) highlight(match[1]);
    $j('#postform_submit').click(function() {
        $j('.postarea').block({
                message: 'Bitte warten &hellip;',
                css: { fontSize: '2em', color: '#000000', background: '#D7CFC0', border: '1px solid #BFB5A1' },
        });
        setTimeout($j.unblockUI, 5000);
    });

        <if $thread>
        $j('#delform').delegate('span.reflink a', 'click', function (ev) {
                var a = ev.target,
                        sel = window.getSelection().toString();
                ev.preventDefault();
                insert('>>' + a.href.match(/#i(\d+)$/)[1] + '\n' + (sel ? '>' + sel.replace(/\n/g, '\n>') + '\n' : ''));
        });
        </if>

        <if ENABLE_HIDE_THREADS && !$thread>hideThreads('<const BOARD_IDENT>', $j);</if>
  });
/* ]]> */
</script>

<script type="text/javascript">
        var board = '<const BOARD_IDENT>', thread_id = <if $thread><var $thread></if><if !$thread>null</if>;
        var filetypes = '<var get_filetypes()>';
        var msg_expand_field = '<const S_JS_EXPAND>';
        var msg_shrink_field = '<const S_JS_SHRINK>';
        var msg_remove_file = '<const S_JS_REMOVEFILE>';
</script>

<if ENABLE_WEBSOCKET_NOTIFY && $thread && !$locked><script type="text/javascript" src="/js/websock.js"></script></if>
<script type="text/javascript" src="/js/context.js"></script>

</body>
</html>
};


use constant PAGE_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<if !$locked or $isAdmin>
<if !DISABLE_NEW_THREADS or $thread or $isAdmin>
<if $postform>
	<section class="postarea">
	<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
	<input type="hidden" name="task" value="post" />
	<input type="hidden" name="board" value="<const BOARD_IDENT>" />
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<if !$image_inp and !$thread and ALLOW_TEXTONLY>
		<input type="hidden" name="nofile" value="1" />
	</if>

	<div class="trap">
		<input type="text" name="name" size="31" />
		<input type="text" name="link" size="36" />
	</div>	

	<table>
	<tbody id="postTableBody">
		<if $isAdmin>
			<tr><td class="postblock">## Team ##</td>
			<td><label><input type="checkbox" name="as_staff" value="1" />  <const S_POSTASADMIN></label></td></tr>
			<tr><td class="postblock">HTML</td>
			<td><label><input type="checkbox" name="no_format" value="1" /> <const S_NOTAGS2></label></td></tr>
		</if>
	<if !FORCED_ANON or $isAdmin><tr><td class="postblock"><label for="name"><const S_NAME></label></td><td><input type="text" name="field1" id="name" /></td></tr></if>

	<tr><td class="postblock"><label for="subject"><const S_SUBJECT></label></td><td><input type="text" name="field3" id="subject" />
	<input type="submit" id="postform_submit" value="<if $thread><const S_BTREPLY> /<var BOARD_IDENT>/<var $thread></if><if !$thread><const S_BTNEWTHREAD></if>" /></td>
	</tr>

	<if $thread>
	<tr><td class="postblock"><label for="sage"><const S_SAGE></label></td>
	<td><label><input type="checkbox" name="field2" value="sage" id="sage" /> <const S_SAGEDESC></label></td>
	</tr>
	</if>

	<tr><td class="postblock"><label for="field4"><const S_COMMENT></label></td>
	<td id="textField"><textarea id="field4" name="field4" cols="48" rows="6"></textarea> <img onclick="resizeCommentfield('field4', this)" src="/img/icons/expand.png" alt="<const S_IMGEXPAND>" title="<const S_IMGEXPAND>" />
	</td></tr>

	<if $image_inp>
		<tr id="fileUploadField"><td class="postblock"><const S_UPLOADFILE> (max. 4)</td>
		<td id="fileInput"><div><input type="file" name="file" onchange="file_input_change(4)" /></div>
		<if $textonly_inp>[<label><input type="checkbox" name="nofile" value="on" /><const S_NOFILE> ]</label></if>
		</td></tr>
	</if>

	<if $thread><tr id="trgetback"><td class="postblock"><const S_NOKO></td>
	<td>
	<label><input name="gb2" value="board" checked="checked" type="radio" /> <const S_NOKOOFF></label>
	<label><input name="gb2" value="thread" type="radio" /> <const S_NOKOON></label>
	</td></tr>
	</if>

	<if !$isAdmin && need_captcha(CAPTCHA_MODE, CAPTCHA_SKIP, $loc)>
		<tr><td class="postblock"><label for="captcha"><const S_CAPTCHA></label> (<a href="/faq">?</a>) (<var $loc>)</td>
		<td><input type="text" name="captcha" id="captcha" size="10" /> <img alt="" src="/captcha.pl?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>&amp;board=<var BOARD_IDENT>" /></td></tr>
	</if>

	<tr id="passwordField"><td class="postblock"><label for="password"><const S_DELPASS></label></td><td><input type="password" name="password" id="password" /> <const S_DELEXPL></td></tr>
	<tr><td colspan="2">
	<div class="rules">} . include("rules.html") . q{</div></td></tr>
	</tbody>
	</table>
	</form>
	</section>
	<script type="text/javascript">set_inputs("postform")</script>

</if>
</if>
</if>

<if $locked && !$isAdmin>
<p class="locked"><var sprintf S_THREADLOCKED, $thread></p>
</if>

<form id="delform" action="<var $self>" method="post">

<loop $threads>
	<hr />
	<if !$thread>
		<div id="thread_<var $num>">
	</if>

	<if $thread>
		<div id="thread_<var $thread>">
	</if>

		<loop $posts>
			} . include("lib/post_view.inc") . q{
		</loop>

		</div>
	<p style="clear: both;"></p>
</loop>

<if $thread>
<div id="websock_enabled"></div>
</if>

<hr />

<if !$thread>
	<nav>
		<ul class="pagelist">
			<li>
				<if $prevpage>[<a href="<var $prevpage>"><const S_PREV></a>]</if>
				<if !$prevpage>[<const S_PREV>]</if>
			</li>
		<loop $pages>
			<li>
				<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
				<if $current>[<strong><var $page></strong>]</if>
			</li>
		</loop>
			<li>
				<if $nextpage>[<a href="<var $nextpage>"><const S_NEXT></a>]</if>
				<if !$nextpage>[<const S_NEXT>]</if>
			</li>
		</ul>
		<ul class="pagelist">
			<li>[<a href="#top"><const S_TOP></a>]</li>
		</ul>
	</nav>
</if>
<if $thread>
	<nav>
		<ul class="pagelist">
			<li>[<a href="#top"><const S_TOP></a>]</li>
		</ul>
	</nav>
</if>

<div class="delete">
	<input type="hidden" name="task" value="delete" />
	<input type="hidden" name="board" value="<const BOARD_IDENT>" />
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<input type="password" name="password" placeholder="<const S_DELKEY>" />
	<input value="<const S_DELETE>" type="submit" />
</div>

</form>
<script type="text/javascript">set_delpass("delform")</script>

} . NORMAL_FOOT_INCLUDE);


use constant SEARCH_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

	<section class="postarea">
	<form id="searchform" action="<var $self>" method="post">
	<input type="hidden" name="task" value="search" />
	<input type="hidden" name="board" value="<const BOARD_IDENT>" />

	<table>
	<tbody>

		<tr><td class="postblock"><label for="search"><const S_SEARCH><br />
		<const S_MINLENGTH></label></td>
		<td><input type="text" name="find" id="search" value="<var $find>" />
		<input value="<const S_SEARCHSUBMIT>" type="submit" />
		</td></tr>

		<tr><td class="postblock"><const S_OPTIONS></td>
		<td>
		<label><input type="checkbox" name="op"      value="1" <if $oponly>checked="checked"</if> /> <const S_SEARCHOP></label><br />
		<label><input type="checkbox" name="subject" value="1" <if $insubject>checked="checked"</if> /> <const S_SEARCHSUBJECT></label><br />
		<!--<label><input type="checkbox" name="files"   value="1" <if $filenames>checked="checked"</if> /> <const S_SEARCHFILES></label><br />-->
		<label><input type="checkbox" name="comment" value="1" <if $comment>checked="checked"</if> /> <const S_SEARCHCOMMENT></label>
		</td></tr>

	</tbody>
	</table>

	</form>
	</section>

	<if $find>
		<hr />
		<var S_SEARCHFOUND> <var $count>
		<if $count><br /><br /></if>
	</if>

	<loop $posts>
		} . include("lib/post_view.inc") . q{
	</loop>

	<p style="clear: both;"></p>
	<hr />

} . NORMAL_FOOT_INCLUDE);


use constant SINGLE_POST_TEMPLATE => compile_template(q{
<loop $posts>
} . include("lib/post_view.inc") . q{
</loop>
});


use constant OEKAKI_TEMPLATE => compile_template(q{

<html>
<head>
<title><const TITLE> &raquo; <var $title></title>
<style>
body {
    background: #ECE9E2;
    color: #000000;
    font: 10pt sans-serif;
}
</style>
<script language="javascript" type="text/javascript" src="/shi-painter/sp.js"></script>
</head>
<body>
<applet code="c.ShiPainter.class" name="paintbbs" archive="/shi-painter/spainter.jar,/shi-painter/res/<var $type>.zip" WIDTH="100%" height="90%" MAYSCRIPT>
<param name="image_width" value="<var $width>">
<param name="image_height" value="<var $height>">

<param name="dir_resource" value="/shi-painter/res/">
<param name="tt.zip" value="/shi-painter/res/tt.zip">
<param name="res.zip" value="/shi-painter/res/res_<var $type>.zip">
<param name="tools" value="<var $type>">
<param name="layer_count" value="3">
<param name="quality" value="1">

<param name="undo_in_mg" value="15">
<param name="undo" value="30">
<param name="MAYSCRIPT" value="true">
<param name="scriptable" value="true">
<param name="url_exit" value="<var $self>?task=paint&do=proceed&id=<var $tmpid>" />
<param name="url_save" value="<var $self>?task=paint&do=save&id=<var $tmpid>" />
<param name="url_target" value="_self" />

</applet>



</body>
</html>
});


use constant ERROR_HEAD_INCLUDE => q{

<!DOCTYPE html>
<html lang="de">
<head>
	<title><const TITLE> &raquo; <var $error_page></title>
	<meta charset="<const CHARSET>" />
	<link rel="stylesheet" type="text/css" href="/css/phutaba.css" />
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
} . include("../tpl/nav_boards.html") . q{
	</ul>

	<ul class="menu right">
} . include("../tpl/nav_pages.html") . q{
	</ul>
</nav>

<header>
	<div class="header">
		<div class="banner"><a href="/"><img src="/banner.pl" alt="Banner" /></a></div>
		<div class="boardname"><const TITLE></div>
	</div>
</header>

<hr />

<section class="error">
	<p><var $error_title></p>
};

use constant ERROR_FOOT_INCLUDE => q{

</section>
<hr />
<footer>Powered by <img src="/img/phutaba_icon.png" alt="" /> <strong>Phutaba</strong>.</footer>
</div>
<const TRACKING_CODE>
</body>
</html>
};

use constant ERROR_TEMPLATE => compile_template(
    ERROR_HEAD_INCLUDE . q{

<if $error>
<p><var $error></p>
</if>
<if $banned>
<loop $bans>
 <br />
 <p>Deine IP <strong><var $ip></strong>
 <if $showmask>(<var $network>/<var $setbits>)</if> wurde 
 <if $reason>mit der Begr&uuml;ndung <strong><var $reason></strong></if> gesperrt.
 <br />Diese Sperrung 
 <if $expires>l&auml;uft am <strong><var encode_entities(get_date($expires))></strong> ab.</if>
 <if !$expires>gilt f&uuml;r unbestimmte Zeit.</if>
 <br />
</loop>
 <br />Bitte kontaktiere uns im IRC, wenn du wieder posten willst!</p>
</if>
<if $dnsbl>
<p>Deine IP <strong><var $ip></strong> wurde in der Blacklist <strong><var $dnsbl></strong> gelistet.
 Aufgrund dieser Tatsache ist es dir nicht gestattet zu posten. Bitte kontaktiere uns im IRC, wenn du wieder posten willst!</p>
</if>

} . ERROR_FOOT_INCLUDE
);

#
# Admin pages
#


use constant ADMIN_LOGIN_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div align="center"><form action="<var $self>" method="post">
<input type="hidden" name="task" value="admin" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<const S_ADMINPASS>
<input type="password" name="berra" size="8" value="" />
<br />
<label><input type="checkbox" name="savelogin" /> <const S_MANASAVE></label>
<br />
<select name="nexttask">
<option value="show"><const S_MANAPANEL></option>
<option value="mpanel"><const S_MANATOOLS></option>
<option value="bans"><const S_MANABANS></option>
<option value="orphans"><const S_MANAORPH></option>
</select>
<input type="submit" value="<const S_MANASUB>" />
</form></div>

} . NORMAL_FOOT_INCLUDE
);

use constant POST_PANEL_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div class="dellist"><const S_MANATOOLS></div>

<div class="postarea">

<const S_MANAGEOINFO>
<table><tbody>
<tr><td class="postblock">GeoIP-API</td><td><var $geoip_api></td></tr>
<loop $geoip_results>
	<tr><td class="postblock"><var $file></td><td><var $result></td></tr>
</loop>
</tbody></table>

</div>

<br /><div class="postarea">

<const S_MANADELETE>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" />
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>

</div><br />

<var sprintf S_IMGSPACEUSAGE, get_displaysize($size, DECIMAL_MARK), $files, $posts, $threads>

} . NORMAL_FOOT_INCLUDE
);

use constant DELETE_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><const S_MPDELETEIP></div>

<div class="postarea">
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<input type="hidden" name="ip" value="<var $ip>" />
<input type="hidden" name="mask" value="<var dec_to_dot($mask)>" />
<input type="hidden" name="go" value="1" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><var dec_to_dot($ip)></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><var dec_to_dot($mask)></tr>
<tr><td class="postblock"><const S_BOARD></td><td>/<const BOARD_IDENT>/</tr>
<tr><td class="postblock"><const S_DELALLMSG></td><td><var sprintf S_DELALLCOUNT, $posts, $threads>
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>
</div>

}.NORMAL_FOOT_INCLUDE);

use constant BAN_PANEL_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div class="dellist"><const S_MANABANS></div>

<div class="postarea">
<table><tbody><tr><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="ipban" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANDURATION></td><td><select name="string">
<option value="86400">1 Tag</option>
<option value="259200">3 Tage</option>
<option value="432000">5 Tage</option>
<option value="604800">1 Woche</option>
<option value="2419200">4 Wochen</option>
<option value="">Permanent</option>
</select></td></tr>
<tr><td class="postblock"><const S_BANREASONLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANIP>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="whitelist" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWHITELIST>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="wordban" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<table><tbody>
<tr><td class="postblock"><const S_BANWORDLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWORD>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="trust" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<table><tbody>
<tr><td class="postblock"><const S_BANTRUSTTRIP></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANTRUST>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom" colspan="3">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="asban" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<table><tbody>
<tr><td class="postblock"><const S_BANASNUMLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANASNUM>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

</td></tr></tbody></table>
</div><br />

<if $filter ne 'off'>[<a href="<var $self>?task=bans&amp;filter=off#tbl"><const S_BANSHOWALL></a>]</if>
<if $filter eq 'off'>[<a href="<var $self>?task=bans#tbl"><const S_BANFILTER></a>]</if>
<a id="tbl"></a>
<table align="center"><tbody>
<tr class="managehead"><const S_BANTABLE></tr>

<loop $bans>
	<if $divider><tr class="managehead"><th colspan="7"></th></tr></if>

	<tr class="row<var $rowtype>">

	<if $type eq 'ipban'>
		<td>IP</td>
		<td><img src="/img/flags/<var $flag>.PNG"> <var dec_to_dot($ival1)></td><td>/<var get_mask_len($ival2)> (<var dec_to_dot($ival2)>)</td>
	</if>
	<if $type eq 'wordban'>
		<td>Word</td>
		<td colspan="2"><var $sval1></td>
	</if>
	<if $type eq 'trust'>
		<td>NoCap</td>
		<td colspan="2"><var $sval1></td>
	</if>
	<if $type eq 'whitelist'>
		<td>Whitelist</td>
		<td><img src="/img/flags/<var $flag>.PNG"> <var dec_to_dot($ival1)></td><td>/<var get_mask_len($ival2)> (<var dec_to_dot($ival2)>)</td>
	</if>
	<if $type eq 'asban'>
		<td>ASNum</td>
		<td colspan="2"><var $sval1></td>
	</if>

	<td><var $comment></td>
	<td>
		<if $date>
			<var $date>
		</if>
		<if !$date>
			<i>none</i>
		</if>
	</td>	
	<td>
	<if $type eq 'ipban'>
		<if $sval1><var make_date($sval1, '2ch')></if>
		<if !$sval1>never</if>
	</if>
	<if $type ne 'ipban'>-</if>
	</td>
	<td><a href="<var $self>?task=removeban&amp;board=<const BOARD_IDENT>&amp;num=<var $num>"><const S_BANREMOVE></a></td>
	</tr>
</loop>

</tbody></table><br />

} . NORMAL_FOOT_INCLUDE
);


use constant ADMIN_ORPHANS_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div class="dellist"><const S_MANAORPH>, <const S_BOARD>: /<const BOARD_IDENT>/ (<var $file_count> Files, <var $thumb_count> Thumbs)</div>

<div class="postarea">

<form action="<var $self>" method="post">

<table><tbody>
	<tr class="managehead"><const S_ORPHTABLE></tr>
	<loop $files>
		<tr class="row<var $rowtype>">
		<td><a target="_blank" href="<var expand_filename($name)>"><const S_MANASHOW></a></td>
		<td><label><input type="checkbox" name="file" value="<var $name>" checked="checked" /><var $name></label></td>
		<td><var make_date($modified, '2ch')></td>
		<td align="right"><var get_displaysize($size, DECIMAL_MARK)></td>
		</tr>
	</loop>
</tbody></table><br />

<loop $thumbs>
	<div class="file">
	<label><input type="checkbox" name="file" value="<var $name>" checked="checked" /><var $name></label><br />
	<var make_date($modified, '2ch')> (<var get_displaysize($size, DECIMAL_MARK)>)<br />
	<img src="<var expand_filename($name)>" />
	</div>
</loop>

<p style="clear: both;"></p>

<input type="hidden" name="task" value="movefiles" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<input value="<const S_MPARCHIVE>" type="submit" />
</form>

</div>

} . NORMAL_FOOT_INCLUDE
);


use constant ADMIN_EDIT_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div class="dellist"><const S_MPEDIT> (/<const BOARD_IDENT>/<var $postid>)</div>

<div align="center"><em><const S_NOTAGS></em></div>

<div class="postarea">
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="save" />
<input type="hidden" name="board" value="<const BOARD_IDENT>" />
<input type="hidden" name="post" value="<var $postid>" />

<table><tbody>
	<tr><td class="postblock"><label for="name"><const S_NAME></label></td><td><input type="text" name="field1" id="name" value="<var $name>" /></td></tr>
	<tr><td class="postblock"><label for="subject"><const S_SUBJECT></label></td><td><input type="text" name="field3" id="subject" value="<var $subject>" />
	<input type="submit" value="<const S_SUBMIT>" /></td></tr>
	<tr><td class="postblock"><label for="field4"><const S_COMMENT></label></td>
	<td id="textField"><textarea id="field4" name="field4" cols="80" rows="14"><var $comment></textarea>
	</td></tr>
</tbody></table></form></div><hr />


} . NORMAL_FOOT_INCLUDE
);

1;
