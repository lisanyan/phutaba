<if $parent>
	<table>
		<tbody>
			<tr>
				<td class="doubledash">&gt;&gt;</td>		
 				<if !$single><td class="reply" id="reply<var $num>"></if>
 				<if $single><td class="reply_new" id="reply<var $num>"></if>

</if>
<div class="thread_head">
	<a name="<var $num>"></a>
	<input type="checkbox" name="delete" value="<var $num>" />
	<if ENABLE_HIDE_THREADS>
		<if !$thread and !$parent>
			<img src="/img/hide.png" alt="Verstecke Thread <var $num>" onclick="hideThread('<var $num>');" />
		</if>
	</if>
	<span class="subject"><var $subject></span>
        <span class="postername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if>
	<if $adminpost><span class="adminpost">## Team ##</span></if>
	<var encode_entities(get_date($timestamp))>
	<span class="reflink">
		<if !$parent>
			<if $isAdmin> 
				<if !$thread><a href="<var decode('utf-8', get_reply_link($num,0,$admin))>#<var $num>">#</a>&nbsp;<a href="<var decode('utf-8', get_reply_link($num,0,$admin))>#i<var $num>">Nr. <var $num></a></if>
				<if $thread><a href="<var decode('utf-8', get_reply_link($num,0,$admin))>#<var $num>">#</a>&nbsp;<a href="javascript:insert('&gt;&gt;<var $num>\n')">Nr. <var $num></a></if>
			</if>
		   		<if !$isAdmin>
				<if $thread><a href="<var decode('utf-8', get_reply_link($num,0))>#<var $num>">#</a>&nbsp;<a href="javascript:insert('&gt;&gt;<var $num>\n')">Nr. <var $num></a></if>
				<if !$thread><a href="<var decode('utf-8', get_reply_link($num,0))>#<var $num>">#</a>&nbsp;<a href="<var decode('utf-8', get_reply_link($num,0))>#i<var $num>">Nr. <var $num></a></if>
			</if>
		</if>
		<if $parent>
			<if $isAdmin>
				<if !$thread><a href="<var decode('utf-8', get_reply_link($parent,0,$admin))>#<var $num>">#</a>&nbsp;<a href="<var decode('utf-8', get_reply_link($parent,0))>#i<var $num>">Nr. <var $num></a></if>
				<if $thread><a onclick="javascrip:highlight('<var $num>');" href="<var decode('utf-8', get_reply_link($parent,0,$admin))>#<var $num>">#</a>&nbsp;<a href="javascript:insert('&gt;&gt;<var $num>\n')">Nr. <var $num></a></if>
			</if>
			<if !$isAdmin>
				<if !$thread><a href="<var decode('utf-8', get_reply_link($parent,0))>#<var $num>">#</a>&nbsp;<a href="<var decode('utf-8', get_reply_link($parent,0))>#i<var $num>">Nr. <var $num></a></if>
				<if $thread><a onclick="javascrip:highlight('<var $num>');" href="<var decode('utf-8', get_reply_link($parent,0))>#<var $num>">#</a>&nbsp;<a href="javascript:insert('&gt;&gt;<var $num>\n')">Nr. <var $num></a></if>
			</if>
		</if>
	</span>
	<if !$parent>
		<if !$sticky_isnull><span class="sticky" onmouseover="Tip('<var S_STICKYTITLE>')" onmouseout="UnTip()">PRO</span></if>
		<if $locked><span class="locked"><img src="/img/locked.png" onmouseover="Tip('<var S_LOCKEDTITLE>')" onmouseout="UnTip()" alt="Lock" /></span></if>
		<if !$autosage><if $email><span class="sage">KONTRA</span></if></if>
		<if $sticky_isnull><if $autosage><span class="systemsage">SYSTEMKONTRA</span></if></if>
	</if>
	<if $ssl><span class="ssl" onmouseover="Tip('<var $ssl>')" onmouseout="UnTip()"><img src="<var SSL_ICON>" alt="SSL" /></span></if>
	<if $parent>
		<if $email><span class="sage">KONTRA</span></if>
	</if>
	<if !$parent>	
		<if $isAdmin>
			<if !$thread>[<a href="<var decode('utf-8', get_reply_link($num,0,$admin))>"><const S_REPLY></a>]</if>
		</if>
		<if !$isAdmin>
			<if !$thread>[<a href="<var decode('utf-8', get_reply_link($num,0))>"><const S_REPLY></a>]</if>
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
</div>
<if $image>
	<div style="display: none; min-width: 250px;" id="imageinfo_<var md5_hex($image)>">
                <strong>Dateiname:</strong> <var $uploadname><br />
                <hr />
		<var get_meta_markup($image)>
	</div>
	<div class="thread_file">
		<span class="filename">&nbsp;<const S_PICNAME><a target="_blank" title="<var $uploadname>" href="<var decode('utf-8', expand_image_filename($image))>/<var $uploadname>"><var get_displayname($uploadname)></a></span><br />
		<span class="filesize">&nbsp;<var get_displaysize($size, DECIMAL_MARK)><if $width && $height>, <var $width>&nbsp;&times;&nbsp;<var $height>&nbsp;</if></span>
		<span class="thumbnailmsg"><const S_THUMB></span><br />
		<if $thumbnail>
			<a target="_blank" href="<var decode('utf-8', expand_image_filename($image))>">
				<img onmouseover="TagToTip('imageinfo_<var md5_hex($image)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail))>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" class="thumb" />
			</a>
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
	</div>
</if>
<if $image1>
	<div style="display: none; min-width: 100px;" id="imageinfo_<var md5_hex($image1)>">
                <strong>Dateiname:</strong> <var $uploadname1><br />
                <hr />
		<var get_meta_markup($image1)>
	</div>
	<div class="thread_file">
		<span class="filename">&nbsp;<const S_PICNAME><a target="_blank" title="<var $uploadname1>" href="<var decode('utf-8', expand_image_filename($image1))>/<var $uploadname1>"><var get_displayname($uploadname1)></a></span><br />
		<span class="filesize">&nbsp;<var get_displaysize($size1, DECIMAL_MARK)><if $width1 && $height1>, <var $width1>&nbsp;&times;&nbsp;<var $height1>&nbsp;</if></span>
		<span class="thumbnailmsg"><const S_THUMB></span><br />
		<if $thumbnail1>
			<a target="_blank" href="<var decode('utf-8', expand_image_filename($image1))>">
				<img onmouseover="TagToTip('imageinfo_<var md5_hex($image1)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail1))>" width="<var $tn_width1>" height="<var $tn_height1>" alt="<var $size1>" class="thumb" />
			</a>
		</if>
		<if !$thumbnail1>
			<if DELETED_THUMBNAIL>
				<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
					<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width1>" height="<var $tn_height1>" alt="" class="thumb" />
				</a>
			</if>
			<if !DELETED_THUMBNAIL>
				<div class="nothumb">
					<a target="_blank" href="<var decode('utf-8', expand_image_filename($image1))>/<var $uploadname1>"><const S_NOTHUMB></a>
				</div>
			</if>
		</if>
	</div>
</if>
<if $image2>
	<div style="display: none; min-width: 100px;" id="imageinfo_<var md5_hex($image2)>">
                <strong>Dateiname:</strong> <var $uploadname2><br />
                <hr />
		<var get_meta_markup($image2)>
	</div>
	<div class="thread_file">
		<span class="filename">&nbsp;<const S_PICNAME><a target="_blank" title="<var $uploadname2>" href="<var decode('utf-8', expand_image_filename($image2))>/<var $uploadname2>"><var get_displayname($uploadname2)></a></span><br />
		<span class="filesize">&nbsp;<var get_displaysize($size2, DECIMAL_MARK)><if $width2 && $height2>, <var $width2>&nbsp;&times;&nbsp;<var $height2>&nbsp;</if></span>
		<span class="thumbnailmsg"><const S_THUMB></span><br />
		<if $thumbnail2>
			<a target="_blank" href="<var decode('utf-8', expand_image_filename($image2))>">
				<img onmouseover="TagToTip('imageinfo_<var md5_hex($image2)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail2))>" width="<var $tn_width2>" height="<var $tn_height2>" alt="<var $size2>" class="thumb" />
			</a>
		</if>
		<if !$thumbnail2>
			<if DELETED_THUMBNAIL>
				<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
					<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width2>" height="<var $tn_height2>" alt="" class="thumb" />
				</a>
			</if>
			<if !DELETED_THUMBNAIL>
				<div class="nothumb">
					<a target="_blank" href="<var decode('utf-8', expand_image_filename($image2))>/<var $uploadname2>"><const S_NOTHUMB></a>
				</div>
			</if>
		</if>
	</div>
</if>
<if $image3>
	<div style="display: none; min-width: 100px;" id="imageinfo_<var md5_hex($image3)>">
                <strong>Dateiname:</strong> <var $uploadname3><br />
                <hr />
		<var get_meta_markup($image3)>
	</div>
	<div class="thread_file">
		<span class="filename">&nbsp;<const S_PICNAME><a target="_blank" title="<var $uploadname3>" href="<var decode('utf-8', expand_image_filename($image3))>/<var $uploadname3>"><var get_displayname($uploadname3)></a></span><br />
		<span class="filesize">&nbsp;<var get_displaysize($size3, DECIMAL_MARK)><if $width3 && $height3>, <var $width3>&nbsp;&times;&nbsp;<var $height3>&nbsp;</if></span>
		<span class="thumbnailmsg"><const S_THUMB></span><br />
		<if $thumbnail3>
			<a target="_blank" href="<var decode('utf-8', expand_image_filename($image3))>">
				<img onmouseover="TagToTip('imageinfo_<var md5_hex($image3)>', TITLE, 'Dateiinformationen', WIDTH, 300)" onmouseout="UnTip()" src="<var decode('utf-8', expand_filename($thumbnail3))>" width="<var $tn_width3>" height="<var $tn_height3>" alt="<var $size3>" class="thumb" />
			</a>
		</if>
		<if !$thumbnail3>
			<if DELETED_THUMBNAIL>
				<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
					<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width3>" height="<var $tn_height3>" alt="" class="thumb" />
				</a>
			</if>
			<if !DELETED_THUMBNAIL>
				<div class="nothumb">
					<a target="_blank" href="<var decode('utf-8', expand_image_filename($image3))>/<var $uploadname3>"><const S_NOTHUMB></a>
				</div>
			</if>
		</if>
	</div>
</if>
<div class="thread_body">
	<if $threeimages>
		<div style="clear: both;"></div>
	</if>
	<blockquote>
		<var $comment>
		<if $isAdmin>
			<if $abbrev>
				<div class="abbrev">
					<var decode('utf-8', sprintf(S_ABBRTEXT,get_reply_link($num,$parent,$admin)))>
				</div>
			</if>
		</if>
		<if !$isAdmin>
			<if $abbrev>
				<div class="abbrev">
					<var decode('utf-8', sprintf(S_ABBRTEXT,get_reply_link($num,$parent)))>
				</div>
			</if>
		</if>
	</blockquote>
	<if !$parent>
		<if $omit>
			<p class="omittedposts">
				<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR,$omit></if>
			</p>
		</if>
	</if>
</div>
<if $twoimages>
	<div style="clear: both;"></div>
</if>
<if $parent>

				</td>
			</tr>
		</tbody>
	</table>
</if>
