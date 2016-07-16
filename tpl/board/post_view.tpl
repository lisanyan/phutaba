<if !$parent>
	<div class="thread_OP" id="<var $num>">
	<div class="post">
	<header class="thread_head">
</if>

<if $parent>
	<div class="thread_reply" id="<var $num>">
	<div class="doubledash desktop">
	<a href="<var Wakaba::get_reply_link($parent,0)>#<var $num>">&gt;&gt;</a>
	</div>

	<div class="post<if %single> post_new</if>">
	<div class="post_head">
</if>

	<if $$cfg{ENABLE_HIDE_THREADS} && !%thread && !$parent>
		<span class="togglethread">
		<img src="/img/icons/hide.png" title="<var sprintf ($$cfg{S_HIDE}, $num)>" alt="Hide" onclick="hideThread('<var $num>', '<var $$cfg{SELFPATH}>', $j);" />
		</span>
	</if>

	<label>
		<input type="checkbox" name="delete" value="<var $num>" />
		<span class="subject"><var $subject></span>
        <span class="postername"><var $name><if $trip><span class="tripcode"><var $trip></span></if><if $$cfg{DISPLAY_ID} && !$adminpost><span class="posterid">&nbsp;ID: <var  Wakaba::make_id_code(Wakaba::dec_to_dot($ip), $timestamp, $email)></span></if></span>
		<include %TMPLDIR%post_mod_include.tpl>
		<span class="date desktop"><time($timestamp, "futaba", $$locale{S_DATENAMES})></span>
		<span class="date mobile"><time($timestamp, "2ch", $$locale{S_DATENAMES})></span>
	</label>

	<if $$cfg{SSL_ICON} and $secure>
		<span onmouseover="Tip('<var $secure>')" onmouseout="UnTip()"><img src="<var $$cfg{SSL_ICON}>" alt="SSL" /></span>
	</if>

	<if $$cfg{SHOW_COUNTRIES} && !%admin && !$adminpost>
		<var Wakaba::get_user_postinfo($$cfg{SELFPATH},$location,$num)>
	</if>

	<span class="reflink">
        <if !$parent>
            <a href="<var Wakaba::get_reply_link($num,0)>#i<var $num>">No. <var $num></a>
        <else>
            <a href="<var Wakaba::get_reply_link($parent,0)>#i<var $num>">No. <var $num></a>
        </if>
	</span>

	<if !$parent>
		<if $sticky><span class="sticky"><img src="/img/icons/pin.png" onmouseover="Tip('<var $$locale{S_STICKYTITLE}>')" onmouseout="UnTip()" alt="Pin" /></span></if>
		<if $locked><span class="locked"><img src="/img/icons/locked.png" onmouseover="Tip('<var $$locale{S_LOCKEDTITLE}>')" onmouseout="UnTip()" alt="Lock" /></span></if>
		<if !$autosage><if $email><span class="sage"><var $$locale{S_SAGE}></span></if></if>
		<if !$sticky><if $autosage><span class="sage">Bumplimit</span></if></if>
	</if>

	<if $parent>
		<if $email><span class="sage"><var $$locale{S_SAGE}></span></if>
	</if>

	<if !$parent && !%thread>
		<if !$locked><span class="replylink">[<a href="<var Wakaba::get_reply_link($num,0)>"><var $$locale{S_REPLY}></a>]</span>
		</else/><span class="replylink">[<a href="<var Wakaba::get_reply_link($num,0)>"><var $$locale{S_VIEW}></a>]</span></if>
	</if>
	<if !$parent && %thread>[<a href="#bottom"><var $$locale{S_BOTTOM}></a>]</if>
	<if %admin>
		<if !$adminpost>
		<div class="hidden" id="postinfo_<var $num>">
			<var Wakaba::get_postinfo($$cfg{SELFPATH},$location,1)>
		</div>
		<span onmouseover="TagToTip('postinfo_<var $num>', TITLE, '<var $$locale{S_POSTINFO}>', DELAY, 0, CLICKSTICKY, true, WIDTH, -450)" onmouseout="UnTip()">[<var Wakaba::dec_to_dot($ip)>]</span>
		</if>
		<if !$parent>	
			<if !$sticky>
				<span onmouseover="Tip('<var $$locale{S_MPSTICKY}>')" onmouseout="UnTip()">
					<a onclick="return areYouSure(this)" href="<var %self>?task=sticky&amp;thread=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/sticky.png"></a>
				</span>
			</if>

			<if $sticky>
				<span onmouseover="Tip('<var $$locale{S_MPUNSTICKY}>')" onmouseout="UnTip()">
					<a onclick="return areYouSure(this)" href="<var %self>?task=sticky&amp;thread=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/unsticky.png"></a>
				</span>
			</if>
			
			<if !$locked>
				<span onmouseover="Tip('<var $$locale{S_MPLOCK}>')" onmouseout="UnTip()">
					<a onclick="return areYouSure(this)" href="<var %self>?task=lock&amp;thread=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/lock.png"></a>
				</span>
			</if>

			<if $locked>
				<span onmouseover="Tip('<var $$locale{S_MPUNLOCK}>')" onmouseout="UnTip()">
					<a onclick="return areYouSure(this)" href="<var %self>?task=lock&amp;thread=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/unlock.png"></a>
				</span>
			</if>
		
			<if !$autosage>
				<span onmouseover="Tip('<var $$locale{S_MPSETSAGE}>')" onmouseout="UnTip()">
					<a onclick="return areYouSure(this)" href="<var %self>?task=kontra&amp;thread=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/sage.png"></a>
				</span>
			</if>

			<if $autosage>
				<span onmouseover="Tip('<var $$locale{S_MPUNSETSAGE}>')" onmouseout="UnTip()">
					<a onclick="return areYouSure(this)" href="<var %self>?task=kontra&amp;thread=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/unsage.png"></a>
				</span>
			</if>
			
		</if>
		<if !$adminpost>
			<span onmouseover="Tip('<var $$locale{S_MPBAN}>')" onmouseout="UnTip()">
				<a onclick="do_ban('<var Wakaba::dec_to_dot($ip)>', <var $num>, '<var $$cfg{SELFPATH}>')"><img src="/img/icons/ban.png"></a>
			</span>
			<span onmouseover="Tip('<var $$locale{S_MPDELETEALL}>')" onmouseout="UnTip()">
				<a onclick="return areYouSure(this)" href="<var %self>?task=deleteall&amp;ip=<var $ip>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/delete_all.png"></a>
			</span>
		</if>
		<span onmouseover="Tip('<var $$locale{S_MPDELFILE}>')"   onmouseout="UnTip()">
			<a onclick="return areYouSure(this)" href="<var %self>?task=delete&amp;admindel=yes&amp;delete=<var $num>&amp;fileonly=on<if %thread and $parent>&amp;parent=<var %thread></if>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/delete_file.png"></a>
		</span>
		<span onmouseover="Tip('<var $$locale{S_MPDELETE}>')" onmouseout="UnTip()">
			<a onclick="return areYouSure(this)" href="<var %self>?task=delete&amp;admindel=yes&amp;delete=<var $num><if %thread and $parent>&amp;parent=<var %thread></if>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/delete.png"></a>
		</span>
		<span onmouseover="Tip('<var $$locale{S_EDITPOST}>')" onmouseout="UnTip()">
			<a href="<var %self>?task=edit&amp;num=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/edit.png"></a>
		</span>
	</if>

<if $parent>
	</div>
</if>

<if !$parent>
	</header>
</if>

<div class="post_body">

<if scalar $files>
<div class="files<if scalar($files) eq 1> files-single</if>">
<loop $files>

<if $thumbnail><div class="file"></if>
<if !$thumbnail><div class="file filebg"></if>
	<div class="hidden" id="imageinfo_<var Wakaba::md5_hex($image)>">
		<strong>Имя файла:</strong> <var Wakaba::clean_string($uploadname)><br />
		<hr />
		<var Wakaba::get_pretty_html($info_all, "\n\t\t")>
	</div>
	<div class="filename"><var $$locale{S_PICNAME}><a target="_blank" title="<var Wakaba::clean_string($uploadname)>" href="<var Wakaba::expand_image_filename($image)><if !$external_upload>/<var Wakaba::get_urlstring(Wakaba::clean_string($uploadname))></if>"><var Wakaba::clean_string($displayname)></a></div>
	<div class="filesize"><var Wakaba::get_displaysize($size, $$cfg{DECIMAL_MARK})><if $width && $height>, <var $width>&nbsp;&times;&nbsp;<var $height></if><if $info>, <var $info></if></div>
	<if $thumbnail>
		<div class="filelink" id="exlink-<var Wakaba::md5_hex($image)>">
		<a target="_blank" href="<var Wakaba::expand_image_filename($image)>" onclick="return expand(this, <var ($width  || 0)>, <var ($height  || 0)>, <var ($tn_width  || 0)>, <var ($tn_height  || 0)>, '<var Wakaba::expand_filename($thumbnail)>', '<var Wakaba::get_extension($image)>')" onmouseover="TagToTip('imageinfo_<var Wakaba::md5_hex($image)>', TITLE, '<var $$locale{S_FILEINFO}>', WIDTH, -450)" onmouseout="UnTip()">
			<img src="<var Wakaba::expand_filename($thumbnail)>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" />
		</a>
		</div>
	</if>
	<if !$thumbnail>
		<if !$size>
			<div class="filedeleted"><var $$locale{S_FILEDELETED}></div>
		</if>
		<if $size>
			<if $$cfg{DELETED_THUMBNAIL}>
				<a target="_blank" href="<var Wakaba::expand_image_filename($$cfg{DELETED_IMAGE})>">
					<img src="<var Wakaba::expand_filename($$cfg{DELETED_THUMBNAIL})>" width="<var $tn_width>" height="<var $tn_height>" alt="" />
				</a>
			</else/>
				<div class="filetype">
					<a onmouseover="TagToTip('imageinfo_<var Wakaba::md5_hex($image)>', TITLE, '<var $$locale{S_FILEINFO}>', WIDTH, -450)" onmouseout="UnTip()" target="_blank" href="<var Wakaba::expand_image_filename($image)>">
						<var Wakaba::get_extension($uploadname)>
					</a>
				</div>
			</if>
		</if>		
	</if>
</div>

</loop></div>
</if>

	<div class="text">
		<if $abbrev>
			<div class="hidden" id="posttext_full_<var $num>">
				<var $comment_full>
			</div>
		</if>

		<div id="posttext_<var $num>">
			<var $comment>
			<if $abbrev>
				<p class="tldr">
					[<a href="<var Wakaba::get_reply_link($num,$parent)>" onclick="return expand_post('<var $num>')"><var $abbrev></a>]
				</p>
			</if>
		</div>
		<if $banned><var $$locale{S_BANNED}></if>
	</div>

</div>
</div>

</div>

<if !$parent>
	<if %omitmsg>
		<aside class="omittedposts">
			<var %omitmsg>
		</aside>
	</if>
</if>
