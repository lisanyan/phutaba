<if !$parent || $standalone>
	<div class="thread_OP" id="<var $postnum>">
	<div class="post">
	<header class="thread_head">
</if>

<if $parent && !$standalone>
	<div class="thread_reply" id="<var $postnum>">
	<div class="doubledash desktop">
	<a href="<var Wakaba::get_reply_link($parent,0)>#<var $postnum>">&gt;&gt;</a>
	</div>

	<div class="post<if %single> post_new</if>">
	<div class="post_head">
</if>

	<if $$cfg{ENABLE_HIDE_THREADS} && !%thread && !$parent && !$standalone>
		<span class="togglethread">
		<img src="/img/icons/hide.png" title="<var sprintf ($$cfg{S_HIDE}, $postnum)>" alt="Hide" onclick="hideThread('<var $postnum>', '<var $$cfg{SELFPATH}>', $j);" />
		</span>
	</if>

	<label>
		<input type="checkbox" name="num" value="<var $postnum>" />
		<span class="subject"><var $subject></span>
        <span class="postername"><var $name><if $trip><span class="tripcode"><var $trip></span></if><if $$cfg{DISPLAY_ID} && !$adminpost><span class="posterid">&nbsp;ID: <var  Wakaba::make_id_code(Wakaba::dec_to_dot($ip), $timestamp, $email)></span></if></span>
		<if $adminpost><span class="teampost">## Team ##</span></if>
		<span class="date desktop"><var Wakaba::make_date($timestamp, "futaba", $$locale{S_DATENAMES})></span>
		<span class="date mobile"><var Wakaba::make_date($timestamp, "2ch", $$locale{S_DATENAMES})></span>
	</label>

	<if $$cfg{SSL_ICON} and $secure>
		<span onmouseover="Tip('<var $secure>')" onmouseout="UnTip()"><img src="<var $$cfg{SSL_ICON}>" alt="SSL" /></span>
	</if>

	<if $$cfg{SHOW_COUNTRIES} && !%admin && !$email && !$adminpost>
	  <var Wakaba::get_post_info2($location)>
	</if>

	<span class="reflink">
        No. <var $postnum>
	</span>

	<if !$parent>
		<if $sticky><span class="sticky"><img src="/img/icons/pin.png" onmouseover="Tip('<var $$locale{S_STICKYTITLE}>')" onmouseout="UnTip()" alt="Pin" /></span></if>
		<if $locked><span class="locked"><img src="/img/icons/locked.png" onmouseover="Tip('<var $$locale{S_LOCKEDTITLE}>')" onmouseout="UnTip()" alt="Lock" /></span></if>
		<if !$autosage><if $email><span class="sage"><var $$locale{S_SAGE}></span></if></if>
		<if !$sticky><if $autosage><span class="sage">Bumplimit</span></if></if>
	</if>

	<if $parent && !$standalone>
		<if $email><span class="sage"><var $$locale{S_SAGE}></span></if>
	</if>

	<if $standalone><span><em>(Orphaned From Parent: <if $parent_alive or !$parent><a href="<var Wakaba::get_reply_link($parent)>"><var $parent></a></else/><var $parent></if> )</em></span></if>
	<if !$parent && !%thread>
		<span class="replylink">[<a href="<var $self>?task=postbackups&amp;section=<var $$cfg{SELFPATH}>&amp;page=t<var $postnum>">View</a>]</span>
	</if>
	<if %admin>
		<if !$adminpost>
		<div class="hidden" id="postinfo_<var $postnum>">
			<var Wakaba::get_post_info($$cfg{SELFPATH},$location)>
		</div>
		<span onmouseover="TagToTip('postinfo_<var $postnum>', TITLE, '<var $$locale{S_POSTINFO}>', DELAY, 0, CLICKSTICKY, true, WIDTH, -450)" onmouseout="UnTip()">[<var Wakaba::dec_to_dot($ip)>]</span>
		</if>
		<!-- buttons here -->
		<span onmouseover="Tip('<var $$locale{S_MPDELETE}>')" onmouseout="UnTip()"><a onclick="return areYouSure(this)" href="<var %self>?task=restorebackups&amp;num=<var $postnum>&amp;handle=delete&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/delete.png"></a></span>
		<if $parent_alive or $standalone or !$parent>
			<span onmouseover="Tip('<var $$locale{S_MPRESTORE}>')" onmouseout="UnTip()"><a onclick="return areYouSure(this)" href="<var %self>?task=restorebackups&amp;num=<var $postnum>&amp;handle=restore&amp;section=<var $$cfg{SELFPATH}>"><img src="/img/icons/expand.png"></a></span>
		</if>
	</if>

<if $parent && !$standalone>
	</div>
</if>

<if !$parent || $standalone>
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
	<div class="filename"><var $$locale{S_PICNAME}><a target="_blank" title="<var Wakaba::clean_string($uploadname)>" href="<var Wakaba::expand_image_filename($image)><if $image !~ /^\/\/$pomf_domain/>/<var Wakaba::get_urlstring(Wakaba::clean_string($uploadname))></if>"><var Wakaba::clean_string($displayname)></a></div>
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
			</if>
			<if !($$cfg{DELETED_THUMBNAIL})>
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
			<div class="hidden" id="posttext_full_<var $postnum>">
				<var $comment_full>
			</div>
		</if>

		<div id="posttext_<var $postnum>">
			<var $comment>
			<if $abbrev>
				<p class="tldr">
					[<a href="<var Wakaba::get_reply_link($postnum,$parent)>" onclick="return expand_post('<var $postnum>')"><var $abbrev></a>]
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
