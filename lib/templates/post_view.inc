<if !$parent>
	<header class="thread_head">
</if>

<if $parent>
	<article class="thread_reply" id="<var $num>">

	<div class="doubledash">
	<if !$thread>				
		<if $isAdmin>
			<a href="<var decode('utf-8', get_reply_link($parent,0,$admin))>#<var $num>">&gt;&gt;</a>
		</if>
		<if !$isAdmin>
			<a href="<var decode('utf-8', get_reply_link($parent,0))>#<var $num>">&gt;&gt;</a>
		</if>
	</if>
		
	<if $thread>			
		<if $isAdmin>
			<a onclick="javascript:highlight('<var $num>');" href="<var decode('utf-8', get_reply_link($parent,0,$admin))>#<var $num>">&gt;&gt;</a>
		</if>
		<if !$isAdmin>
			<a onclick="javascript:highlight('<var $num>');" href="<var decode('utf-8', get_reply_link($parent,0))>#<var $num>">&gt;&gt;</a>
		</if>
	</if>
	</div>

 				<if !$single><!--td class="reply" id="reply<var $num>"--></if>
 				<if $single><!--td class="reply_new" id="reply<var $num>"--></if>

	<section class="post<if $single> post_new</if>">
	<section class="post_head">
</if>

	<if ENABLE_HIDE_THREADS>
		<if !$thread and !$parent>
			<span class="togglethread">
			<img src="/img/hide.png" title="Thread <var $num> ausblenden" alt="Hide" onclick="hideThread('<var $num>');" />
			</span>
		</if>
	</if>

	<label>
		<input type="checkbox" name="delete" value="<var $num>" />
		<span class="subject"><var $subject></span>
        <span class="postername"><var $name><if $trip><span class="tripcode"><var $trip></span></if></span>
		<if $adminpost><span class="teampost">## Team ##</span></if>
		<span class="date"><var encode_entities(get_date($timestamp))></span>
	</label>

	<span class="reflink">
		<if !$thread>
			<if !$parent>
				<if $isAdmin> 
					<a href="<var decode('utf-8', get_reply_link($num,0,$admin))>#i<var $num>">Nr. <var $num></a>
				</if>
				<if !$isAdmin>
					<a href="<var decode('utf-8', get_reply_link($num,0))>#i<var $num>">Nr. <var $num></a>
				</if>
			</if>			
			<if $parent>
				<if $isAdmin>
					<a href="<var decode('utf-8', get_reply_link($parent,0,$admin))>#i<var $num>">Nr. <var $num></a>
				</if>
				<if !$isAdmin>
					<a href="<var decode('utf-8', get_reply_link($parent,0))>#i<var $num>">Nr. <var $num></a>
				</if>
			</if>
		</if>
		<if $thread><a href="javascript:insert('&gt;&gt;<var $num>\n')">Nr. <var $num></a></if>		
	</span>

	<if $ssl>
		<span class="ssl" onmouseover="Tip('<var $ssl>')" onmouseout="UnTip()"><img src="<var SSL_ICON>" alt="SSL" /></span>
	</if>

	<if !$parent>
		<if !$sticky_isnull><span class="sticky"><img src="/img/pin.png" onmouseover="Tip('<var S_STICKYTITLE>')" onmouseout="UnTip()" alt="Pin" /></span></if>
		<if $locked><span class="locked"><img src="/img/lock.png" onmouseover="Tip('<var S_LOCKEDTITLE>')" onmouseout="UnTip()" alt="Lock" /></span></if>
		<if !$autosage><if $email><span class="sage">Kontra</span></if></if>
		<if $sticky_isnull><if $autosage><span class="systemsage">Systemkontra</span></if></if>
	</if>

	<if $parent>
		<if $email><span class="sage">Kontra</span></if>
	</if>

	<if !$parent>	
		<if $isAdmin>
			<if !$thread>
			<span class="replylink">[<a href="<var decode('utf-8', get_reply_link($num,0,$admin))>"><const S_REPLY></a>]</span>
			</if>
		</if>
		<if !$isAdmin>
			<if !$thread>
			<span class="replylink">[<a href="<var decode('utf-8', get_reply_link($num,0))>"><const S_REPLY></a>]</span>
			</if>
		</if>
	</if>

	<if $isAdmin>  
		[<var dec_to_dot($ip)>] 
		<if !$parent>	
			<if $sticky_isnull>
				<span class="sticky" onmouseover="Tip('<const S_MPSTICKY>')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=sticky&amp;threadid=<var $num>"><img src="/img/admin_sticky.png"></a></span>
			</if>
			
			<if !$sticky_isnull>
				<span class="unsticky" onmouseover="Tip('<const S_MPUNSTICKY>')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=sticky&amp;threadid=<var $num>"><img src="/img/admin_unsticky.png"></a></span>
			</if>
			
			<if $locked>
				<span class="unlock" onmouseover="Tip('<const S_MPUNLOCK>')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=lock&amp;threadid=<var $num>"><img src="/img/admin_unlock.png"></a></span>
			</if>
			
			<if !$locked>
				<span class="lock" onmouseover="Tip('<const S_MPLOCK>')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=lock&amp;threadid=<var $num>"><img src="/img/admin_lock.png"></a></span>
			</if>
			
			<if $autosage>
				<span class="autosage" onmouseover="Tip('L&ouml;se Systemkontra')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=kontra&amp;threadid=<var $num>"><img src="/img/admin_autosage_off.png"></a></span>
			</if>
		
			<if !$autosage>
				<span class="lock" onmouseover="Tip('Setze Systemkontra')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=kontra&amp;threadid=<var $num>"><img src="/img/admin_autosage_on.png"></a></span>
			</if>
		</if>
		<span class="delete" onmouseover="Tip('<const S_MPDELETE>')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=delete&amp;delete=<var $num>"><img src="/img/admin_delete.png"></a></span>
		<span class="delete_file" onmouseover="Tip('Datei L&ouml;schen')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=delete&amp;delete=<var $num>&amp;fileonly=on"><img src="/img/admin_delete_file.png"></a></span>
		<span class="ban" onmouseover="Tip('<const S_MPBAN>')" onmouseout="UnTip()"><a onclick="do_ban('<var dec_to_dot($ip)>', <var $num>, '<const BOARD_IDENT>', '<var $admin>')"><img src="/img/admin_ban.png"></a></span>
		<span class="deleteall" onmouseover="Tip('<const S_MPDELETEALL>')" onmouseout="UnTip()"><a href="<var decode('utf-8', $self)>?admin=<var $admin>&amp;task=deleteall&amp;ip=<var $ip>"><img src="/img/admin_delete_all.png"></a></span>
	</if>

<if !$parent>
	</header>
	<article class="thread_OP" id="<var $num>">
	<section class="post">
</if>

<if $parent>
	</section>
</if>



<if $image>
<section class="file">
	<div style="display: none; min-width: 250px;" id="imageinfo_<var md5_hex($image)>">
		<strong>Dateiname:</strong> <var $uploadname><br />
		<hr />
		<var get_meta_markup($image)>
	</div>
	<div class="filename"><const S_PICNAME><a target="_blank" title="<var $uploadname>" href="<var decode('utf-8', expand_image_filename($image))>/<var get_urlstring($uploadname)>"><var get_displayname($uploadname)></a></div>
	<div class="filesize"><var get_displaysize($size, DECIMAL_MARK)><if $width && $height>, <var $width>&nbsp;&times;&nbsp;<var $height></if></div>
	<if $thumbnail>
		<div class="filelink">
		<a target="_blank" href="<var decode('utf-8', expand_image_filename($image))>">
			<img onmouseover="TagToTip('imageinfo_<var md5_hex($image)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail))>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" />
		</a>
		</div>
	</if>
	<if !$thumbnail>
		<if DELETED_THUMBNAIL>
			<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
				<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width>" height="<var $tn_height>" alt="" class="thumb" />
			</a>
		</if>
		<if !DELETED_THUMBNAIL>
			<div class="nothumb">
				<a target="_blank" href="<var decode('utf-8', expand_image_filename($image))>/<var $uploadname>"><const S_NOTHUMB></a>
			</div>
		</if>
	</if>
</section>
</if>
<if $image1>
<section class="file">
	<div style="display: none; min-width: 100px;" id="imageinfo_<var md5_hex($image1)>">
		<strong>Dateiname:</strong> <var $uploadname1><br />
		<hr />
		<var get_meta_markup($image1)>
	</div>
	<div class="filename"><const S_PICNAME><a target="_blank" title="<var $uploadname1>" href="<var decode('utf-8', expand_image_filename($image1))>/<var get_urlstring($uploadname1)>"><var get_displayname($uploadname1)></a></div>
	<div class="filesize"><var get_displaysize($size1, DECIMAL_MARK)><if $width1 && $height1>, <var $width1>&nbsp;&times;&nbsp;<var $height1></if></div>
	<if $thumbnail1>
		<div class="filelink">
		<a target="_blank" href="<var decode('utf-8', expand_image_filename($image1))>">
			<img onmouseover="TagToTip('imageinfo_<var md5_hex($image1)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail1))>" width="<var $tn_width1>" height="<var $tn_height1>" alt="<var $size1>" />
		</a>
		</div>
	</if>
	<if !$thumbnail1>
		<if DELETED_THUMBNAIL>
			<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
				<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width1>" height="<var $tn_height1>" alt="" />
			</a>
		</if>
		<if !DELETED_THUMBNAIL>
			<div class="nothumb">
				<a target="_blank" href="<var decode('utf-8', expand_image_filename($image1))>/<var $uploadname1>"><const S_NOTHUMB></a>
			</div>
		</if>
	</if>
</section>
</if>
<if $image2>
<section class="file">
	<div style="display: none; min-width: 100px;" id="imageinfo_<var md5_hex($image2)>">
		<strong>Dateiname:</strong> <var $uploadname2><br />
		<hr />
		<var get_meta_markup($image2)>
	</div>
	<div class="filename"><const S_PICNAME><a target="_blank" title="<var $uploadname2>" href="<var decode('utf-8', expand_image_filename($image2))>/<var get_urlstring($uploadname2)>"><var get_displayname($uploadname2)></a></div>
	<div class="filesize"><var get_displaysize($size2, DECIMAL_MARK)><if $width2 && $height2>, <var $width2>&nbsp;&times;&nbsp;<var $height2></if></div>
	<if $thumbnail2>
		<div class="filelink">
		<a target="_blank" href="<var decode('utf-8', expand_image_filename($image2))>">
			<img onmouseover="TagToTip('imageinfo_<var md5_hex($image2)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail2))>" width="<var $tn_width2>" height="<var $tn_height2>" alt="<var $size2>" />
		</a>
		</div>
	</if>
	<if !$thumbnail2>
		<if DELETED_THUMBNAIL>
			<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
				<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width2>" height="<var $tn_height2>" alt="" />
			</a>
		</if>
		<if !DELETED_THUMBNAIL>
			<div class="nothumb">
				<a target="_blank" href="<var decode('utf-8', expand_image_filename($image2))>/<var $uploadname2>"><const S_NOTHUMB></a>
			</div>
		</if>
	</if>
</section>
</if>
<if $image3>
<section class="file">
	<div style="display: none; min-width: 100px;" id="imageinfo_<var md5_hex($image3)>">
		<strong>Dateiname:</strong> <var $uploadname3><br />
		<hr />
		<var get_meta_markup($image3)>
	</div>
	<div class="filename"><const S_PICNAME><a target="_blank" title="<var $uploadname3>" href="<var decode('utf-8', expand_image_filename($image3))>/<var get_urlstring($uploadname3)>"><var get_displayname($uploadname3)></a></div>
	<div class="filesize"><var get_displaysize($size3, DECIMAL_MARK)><if $width3 && $height3>, <var $width3>&nbsp;&times;&nbsp;<var $height3></if></div>
	<if $thumbnail3>
		<div class="filelink">
		<a target="_blank" href="<var decode('utf-8', expand_image_filename($image3))>">
			<img onmouseover="TagToTip('imageinfo_<var md5_hex($image3)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail3))>" width="<var $tn_width3>" height="<var $tn_height3>" alt="<var $size3>" />
		</a>
		</div>
	</if>
	<if !$thumbnail3>
		<if DELETED_THUMBNAIL>
			<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
				<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width3>" height="<var $tn_height3>" alt="" />
			</a>
		</if>
		<if !DELETED_THUMBNAIL>
			<div class="nothumb">
				<a target="_blank" href="<var decode('utf-8', expand_image_filename($image3))>/<var $uploadname3>"><const S_NOTHUMB></a>
			</div>
		</if>
	</if>
</section>	
</if>




<section class="text">
	<var $comment>
	<if $abbrev>
		<if $isAdmin>
			<var decode('utf-8', sprintf(S_ABBRTEXT,get_reply_link($num,$parent,$admin)))>
		</if>
		<if !$isAdmin>
			<var decode('utf-8', sprintf(S_ABBRTEXT,get_reply_link($num,$parent)))>
		</if>
	</if>
</section>

</section>
</article>

<if !$parent>
	<if $omit>
		<aside class="omittedposts">
			<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
			<if !$omitimages><var sprintf S_ABBR,$omit></if>
		</aside>
	</if>
</if>
