use strict;

BEGIN { require "../lib/wakautils.pl"; }

use constant NORMAL_HEAD_INCLUDE => q{

<!DOCTYPE html>
<html lang="de">
<head>
<title><var strip_html(TITLE)> &raquo; <if $title><var strip_html($title)></if><if !$title>/<var strip_html(BOARD_IDENT)>/ - <var strip_html(BOARD_NAME)></if></title>
<meta charset="<const CHARSET>" />
<link rel="shortcut icon" href="/img/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/css/phutaba.css" />
<if STYLESHEET><link rel="stylesheet" type="text/css" href="<const STYLESHEET>" /></if>
<link rel="stylesheet" type="text/css" href="/css/jquery.ui.css" />
<script type="text/javascript" src="/js/prototype.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.blockUI.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.elastic.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.cookie.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.ui.js"></script>
<script type="text/javascript" src="/js/wakaba3.js"></script>
<if $isAdmin><script type="text/javascript" src="/js/admin.js"></script></if>
<if ENABLE_HIDE_THREADS && !$thread><script type="text/javascript" src="/js/hidethreads.js"></script></if>
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

<if $thread && ENABLE_WEBSOCKET_NOTIFY>
	<script type="text/javascript">
		var thread_id = <var $thread>;
		var board = "<const BOARD_IDENT>";
	</script>
</if>

<style type="text/css">
<const ADDITIONAL_CSS>
</style>
</head>

<if $thread><body class="replypage"></if>
<if !$thread><body></if>

<if $isAdmin>
<div id="modpanel" style="display: none">
<table>
<tr>
<td><b>IP</b></td><td><input id="ip" type="text" name="ip" /></td>
</tr>
<tr>
<td><b>Netmask</b></td><td><input id="netmask" type="text" name="netmask" /></td>
</tr>
<tr>
<td><b>PostID</b></td><td><input id="postid" type="text" name="postid" /></td>
</tr>
<tr>
<td><b>Reason</b></td><td><input id="reason" type="text" name="reason" /></td>
</tr>
</table>
<div id="infobox" style="display: none">
<br />
<b>IP</b>: <span id="r_ip"></span><br />
<b>Netmask</b>: <span id="r_mask"></span><br />
<b>Comment</b>: <span id="r_reason"></span><br />
<b>Post</b>: <span id="r_post"></span><br />
</div>
<p id="info" style="display: none"><span style="font-weight: bolder; color: #002233;">Info: <span style="font-weight: bolder" id="infodetails"></span></span></p>
<p id="error" style="display: none"><span style="font-weight: bolder; color: #FF0000;">Error: <span style="font-weight: bolder" id="errordetails"></span></span></p>
</div>
</if>

<div class="content">

<script type="text/javascript" src="/js/wz_tooltip.js"></script>
<if ENABLE_WEBSOCKET_NOTIFY && $thread && !$locked><script type="text/javascript" src="/js/websock.js"></script></if>

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
				<img src="/banner/<const BOARD_IDENT>" alt="<const BOARD_IDENT>" />
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
	[<a href="<var expand_filename(HTML_SELF)>"><const S_MANARET></a>]
	[<a href="<var $self>?task=mpanel&amp;admin=<var $admin>"><const S_MANAPANEL></a>]
	[<a href="<var $self>?task=bans&amp;admin=<var $admin>"><const S_MANABANS></a>]
	[<a href="<var $self>?task=mpost&amp;admin=<var $admin>"><const S_MANAPOST></a>]
	[<a href="<var $self>?task=logout"><const S_MANALOGOUT></a>]
	<div class="passvalid"><const S_MANAMODE></div>
</if>
};


use constant NORMAL_FOOT_INCLUDE => q{

<footer>
	<p>Powered by <img src="/img/phutaba_icon.png" alt="" /> <strong>Phutaba</strong>.</p>
	<p><em>Report illegal material to <a href="mailto:post-abuse@ernstchan.com">post-abuse@ernstchan.com</a>.</em></p>
</footer>
<nav>
	<ul class="menu_bottom">
} . include("../tpl/nav_boards.html") . q{
	</ul>
</nav>
</div>
</body>
</html>
};


use constant PAGE_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<if !$locked>
<if !DISABLE_NEW_THREADS or $thread or $isAdmin>
<if $postform>
	<section class="postarea">
	<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">

	<input type="hidden" name="task" value="post" />
	<if $isAdmin>
		<input type="hidden" name="admin" value="<var $admin>" />
	</if>
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
			<td><label><input type="checkbox" name="as_admin" value="1" />  <const S_POSTASADMIN></label></td></tr>
		</if>
		<if $isAdmin>
			<tr><td class="postblock">HTML</td>
			<td><label><input type="checkbox" name="no_format" value="1" /> <const S_NOTAGS2></label></td></tr>
		</if>
	<if !FORCED_ANON or $isAdmin><tr><td class="postblock"><const S_NAME></td><td><input type="text" name="field1" size="28" /></td></tr></if>

	<tr><td class="postblock"><const S_SUBJECT></td><td><input type="text" name="field3" size="35" />
	<input type="submit" id="postform_submit" value="<if $thread><const S_BTREPLY> /<var BOARD_IDENT>/<var $thread></if><if !$thread><const S_BTNEWTHREAD></if>" /></td>
	</tr>

	<if $thread>
	<tr><td class="postblock"><const S_SAGE></td>
	<td><label><input type="checkbox" name="field2" value="sage" /> <const S_SAGEDESC></label></td>
	</tr>
	</if>

	<tr><td class="postblock"><const S_COMMENT></td>
	<td><textarea id="field4" name="field4" cols="48" rows="6"></textarea> <img onclick="resizeCommentfield('field4', this)" src="/img/icons/expand.png" alt="<const S_IMGEXPAND>" title="<const S_IMGEXPAND>" />
	</td></tr>

	<if $image_inp>
		<tr id="fileUploadField"><td class="postblock"><const S_UPLOADFILE> (max. 4)</td>
		<td id="fileInput"><div><input type="file" name="file" size="35" onchange="file_input_change(4)" /></div>
		<if $textonly_inp>[<label><input type="checkbox" name="nofile" value="on" /><const S_NOFILE> ]</label></if>
		</td></tr>
	</if>

	<if $thread><tr id="trgetback"><td class="postblock"><const S_NOKO></td>
	<td>
	<label><input name="gb2" value="board" checked="checked" type="radio" /> <const S_NOKOOFF></label>
	<label><input name="gb2" value="thread" type="radio" /> <const S_NOKOON></label>
	</td></tr>
	</if>

	<if use_captcha(ENABLE_CAPTCHA, $loc)>
		<tr><td class="postblock"><const S_CAPTCHA> (<a href="/faq">?</a>) (<var $loc>)</td><td><input type="text" name="captcha" size="10" /> <img alt="" src="/lib/captcha.pl?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>&amp;board=<var BOARD_IDENT>" /></td></tr>
	</if>

	<tr id="passwordField"><td class="postblock"><const S_DELPASS></td><td><input type="password" name="password" size="8" /> <const S_DELEXPL></td></tr>
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

<if $locked>
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
			} . include("../lib/templates/post_view.inc") . q{
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
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<input type="password" name="password" placeholder="<const S_DELKEY>" />
	<input value="<const S_DELETE>" type="submit" />
</div>

</form>
<script type="text/javascript">set_delpass("delform")</script>

} . NORMAL_FOOT_INCLUDE);


use constant SINGLE_POST_TEMPLATE => compile_template(q{
<loop $posts>
} . include("../lib/templates/post_view.inc") . q{
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
	<link rel="shortcut icon" href="/img/favicon.ico" />
	<link rel="stylesheet" type="text/css" href="/css/style.css" />
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
		<div class="banner"><a href="/"><img src="/banner-redir.pl" alt="Ernstchan" /></a></div>
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
</body>
</html>
};

use constant ERROR_TEMPLATE => compile_template(
    ERROR_HEAD_INCLUDE . q{

<if $error>
<p><var $error></p>
</if>
<if $banned>
<p>Deine IP <strong><var $ip></strong> wurde wegen <strong><var $reason></strong> auf unbestimmte Zeit gesperrt.
 Bitte kontaktiere uns im IRC wenn du wieder posten willst!</p>
</if>
<if $dnsbl>
<p>Deine IP <strong><var $ip></strong> wurde in der Blacklist <strong><var $dnsbl></strong> gelistet.
 Aufgrund dieser Tatsache ist es dir nicht gestattet zu posten. Bitte kontaktiere uns im IRC wenn du wieder posten willst!</p>
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
<const S_ADMINPASS>
<input type="password" name="berra" size="8" value="" />
<br />
<label><input type="checkbox" name="savelogin" /> <const S_MANASAVE></label>
<br />
<select name="nexttask">
<option value="mpanel"><const S_MANAPANEL></option>
<option value="bans"><const S_MANABANS></option>
<option value="mpost"><const S_MANAPOST></option>
</select>
<input type="submit" value="<const S_MANASUB>" />
</form></div>

} . NORMAL_FOOT_INCLUDE
);

use constant POST_PANEL_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div class="dellist"><const S_MANAPANEL></div>

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="delete" />
<input type="hidden" name="admin" value="<var $admin>" />

<div class="delbuttons">
<input type="submit" value="<const S_MPDELETE>" />
<input type="submit" name="archive" value="<const S_MPARCHIVE>" />
<input type="reset" value="<const S_MPRESET>" />
[<label><input type="checkbox" name="fileonly" value="on" /><const S_MPONLYPIC></label>]
</div>

<table align="center" style="white-space: nowrap"><tbody>
<tr class="managehead"><const S_MPTABLE></tr>

<loop $posts>
	<if !$parent><tr class="managehead"><th colspan="6"></th> </tr></if>

	<tr class="row<var $rowtype>">

	<if !$image><td></if>
	<if $image><td rowspan="<var $imagecount+1>"></if>
	<if $parent>
		<label><input type="checkbox" name="delete" value="<var $num>" /><big><b><var $num></b></big>&nbsp;&nbsp;</label></td>
	</if>
	<if !$parent>
		<label><input type="checkbox" name="delete" value="<var $num>" /><big><b><var $num></b></big>&nbsp;&nbsp;</label>
		<if $sticky_isnull>
			[<a href="<var $self>?admin=<var $admin>&amp;task=sticky&amp;threadid=<var $num>"><const S_MPSTICKY></a>]
		</if>
		<if !$sticky_isnull>
			[<a href="<var $self>?admin=<var $admin>&amp;task=sticky&amp;threadid=<var $num>"><const S_MPUNSTICKY></a>]
		</if>
		<if $locked>
			[<a href="<var $self>?admin=<var $admin>&amp;task=lock&amp;threadid=<var $num>"><const S_MPUNLOCK></a>]
		</if>
		<if !$locked>
			[<a href="<var $self>?admin=<var $admin>&amp;task=lock&amp;threadid=<var $num>"><const S_MPLOCK></a>]
		</if>
		<if $autosage>
			[<a href="<var $self>?admin=<var $admin>&amp;task=kontra&amp;threadid=<var $num>"><const S_MPUNSETSAGE></a>]
		</if>
		<if !$autosage>
			[<a href="<var $self>?admin=<var $admin>&amp;task=kontra&amp;threadid=<var $num>"><const S_MPSETSAGE></a>]
		</if>

		</td>
	</if>

	<td><var make_date($timestamp,"tiny")></td>
	<td><var clean_string(substr $subject,0,20)></td>
	<td><b><var clean_string(substr $name,0,30)><var $trip></b></td>
	<td><var clean_string(substr $comment,0,30)></td>
	<td><var dec_to_dot($ip)>
		[<a href="<var $self>?admin=<var $admin>&amp;task=deleteall&amp;ip=<var $ip>"><const S_MPDELETEALL></a>]
		[<a onclick="do_ban('<var dec_to_dot($ip)>', <var $num>, '<const BOARD_IDENT>', '<var $admin>')"><const S_MPBAN></a>]
	</td>

	</tr>
	<if $image>
		<tr class="row<var $rowtype>">
		<td colspan="5"><small>
		<const S_PICNAME><a href="<var expand_filename(clean_path($image))>"><var clean_string($image)></a>
		(<var $size> B, <var $width>x<var $height>)&nbsp; MD5: <var $md5>
		</small></td></tr>
	</if>
	<if $image1>
		<tr class="row<var $rowtype>">
		<td colspan="5"><small>
		<const S_PICNAME><a href="<var expand_filename(clean_path($image1))>"><var clean_string($image1)></a>
		(<var $size1> B, <var $width1>x<var $height1>)&nbsp; MD5: <var $md51>
		</small></td></tr>
	</if>
	<if $image2>
		<tr class="row<var $rowtype>">
		<td colspan="5"><small>
		<const S_PICNAME><a href="<var expand_filename(clean_path($image2))>"><var clean_string($image2)></a>
		(<var $size2> B, <var $width2>x<var $height2>)&nbsp; MD5: <var $md52>
		</small></td></tr>
	</if>
	<if $image3>
		<tr class="row<var $rowtype>">
		<td colspan="5"><small>
		<const S_PICNAME><a href="<var expand_filename(clean_path($image3))>"><var clean_string($image3)></a>
		(<var $size3> B, <var $width3>x<var $height3>)&nbsp; MD5: <var $md53>
		</small></td></tr>
	</if>
</loop>

</tbody></table>

	<table class="paginator" border="1"><tbody><tr><td>Seiten:</td><if $prevpage><td>

	[<a href="<var $prevpage>"><const S_PREV></a>]
	</td></if><td>

	<loop $pages>
		<if !$current><a href="<var $filename>"><var $page+1></a></if>
		<if $current>[<b><var $page+1></b>]</if>
	</loop>

	</td><if $nextpage><td>

	[<a href="<var $nextpage>"><const S_NEXT></a>]

	</td></if></tr></tbody></table>


<div class="delbuttons">
<input type="submit" value="<const S_MPDELETE>" />
<input type="submit" name="archive" value="<const S_MPARCHIVE>" />
<input type="reset" value="<const S_MPRESET>" />
[<label><input type="checkbox" name="fileonly" value="on" /><const S_MPONLYPIC></label>]
</div>

</form>

<br /><div class="postarea">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" />
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>

</div><br />

<var sprintf S_IMGSPACEUSAGE,int($size/1024)>

} . NORMAL_FOOT_INCLUDE
);

use constant BAN_PANEL_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div class="dellist"><const S_MANABANS></div>

<div class="postarea">
<table><tbody><tr><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="ipban" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANIP>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="whitelist" />
<input type="hidden" name="admin" value="<var $admin>" />
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
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANWORDLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWORD>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="trust" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANTRUSTTRIP></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANTRUST>" /></td></tr>
</tbody></table></form>

</td></tr></tbody></table>
</div><br />

<table align="center"><tbody>
<tr class="managehead"><const S_BANTABLE></tr>

<loop $bans>
	<if $divider><tr class="managehead"><th colspan="9"></th></tr></if>

	<tr class="row<var $rowtype>">

	<if $type eq 'ipban'>
		<td>IP</td>
		<td><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></td>
	</if>
	<if $type eq 'wordban'>
		<td>Word</td>
		<td><var $sval1></td>
	</if>
	<if $type eq 'trust'>
		<td>NoCap</td>
		<td><var $sval1></td>
	</if>
	<if $type eq 'whitelist'>
		<td>Whitelist</td>
		<td><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></td>
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
		<if get_ip_info(1, $ival1)>
			<var get_ip_info(1, $ival1)>
		</if>
		<if get_ip_info(1, $ival1) eq undef>
			<i>none</i>
		</if>
	</td>
	<td>
  <em>wird erneuert</em>
	</td>
	<td>
  <em>wird erneuert</em>
	</td>
	<td><a href="<var $self>?admin=<var $admin>&amp;task=removeban&amp;num=<var $num>"><const S_BANREMOVE></a></td>
	</tr>
</loop>

</tbody></table><br />

} . NORMAL_FOOT_INCLUDE
);
    # <if get_as_description(get_ip_info(1, $ival1))>
    #   <var get_as_description(get_ip_info(1, $ival1))>
    # </if>
    # <if get_as_description(get_ip_info(1, $ival1)) eq undef>
    #   <i>none</i>
    # </if>
    # <if get_ip_info(2, $ival1)>
    #   <img title="<var get_ip_info(2, $ival1)>" onmouseover="Tip('<var code2country(get_ip_info(2, $ival1))>')" onmouseout="UnTip()" src="/img/flags/<var get_ip_info(2, $ival1)>.PNG" />
    # </if>
    # <if get_ip_info(2, $ival1) eq undef>
    #   <i>none</i>
    # </if>


use constant ADMIN_POST_TEMPLATE => compile_template(
    MANAGER_HEAD_INCLUDE . q{

<div align="center"><em><const S_NOTAGS></em></div>

<div class="postarea">
<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
<input type="hidden" name="task" value="post" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="no_captcha" value="1" />
<input type="hidden" name="no_format" value="1" />

<table><tbody>
<tr><td class="postblock"><const S_SUBJECT></td><td><input type="text" name="field3" size="35" />
<input type="submit" value="<const S_SUBMIT>" /></td></tr>
<tr><td class="postblock"><const S_SAGE></td><td><input type="checkbox" name="field2" value="sage" /></td></tr>
<tr><td class="postblock"><const S_COMMENT></td><td><textarea name="field4" cols="48" rows="4"></textarea></td></tr>
<tr><td class="postblock"><const S_UPLOADFILE></td><td><input type="file" name="file" size="35" />
[<label><input type="checkbox" name="nofile" value="on" /><const S_NOFILE> ]</label>
</td></tr>
<tr><td class="postblock"><const S_PARENT></td><td><input type="text" name="parent" size="8" /></td></tr>
<tr><td class="postblock"><const S_DELPASS></td><td><input type="password" name="password" size="8" /><const S_DELEXPL></td></tr>
</tbody></table></form></div><hr />
<script type="text/javascript">set_inputs("postform")</script>

} . NORMAL_FOOT_INCLUDE
);

1;
