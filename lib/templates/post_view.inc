<if !$parent>
	<article class="thread_OP" id="<var $num>">
	<header class="thread_head">
</if>

<if $parent>
	<article class="thread_reply" id="<var $num>">
	<div class="doubledash">
	<if !$thread>
		<if $isAdmin>
			<a href="<var get_reply_link($parent,0,$admin)>#<var $num>">&gt;&gt;</a>
		</if>
		<if !$isAdmin>
			<a href="<var get_reply_link($parent,0)>#<var $num>">&gt;&gt;</a>
		</if>
	</if>
		
	<if $thread>
		<if $isAdmin>
			<a onclick="javascript:highlight('<var $num>');" href="<var get_reply_link($parent,0,$admin)>#<var $num>">&gt;&gt;</a>
		</if>
		<if !$isAdmin>
			<a onclick="javascript:highlight('<var $num>');" href="<var get_reply_link($parent,0)>#<var $num>">&gt;&gt;</a>
		</if>
	</if>
	</div>

 				<if !$single><!--td class="reply" id="reply<var $num>"--></if>
 				<if $single><!--td class="reply_new" id="reply<var $num>"--></if>

	<section class="post<if $single> post_new</if>">
	<section class="post_head">
</if>

	<if ENABLE_HIDE_THREADS && !$thread && !$parent>
		<span class="togglethread">
		<img src="/img/icons/hide.png" title="<var sprintf S_HIDE, $num>" alt="Hide" onclick="hideThread('<var $num>', '<const BOARD_IDENT>', $j);" />
		</span>
	</if>

	<label>
		<input type="checkbox" name="delete" value="<var $num>" />
		<span class="subject"><var $subject></span>
        <span class="postername"><var $name><if $trip><span class="tripcode"><var $trip></span></if></span>
		<if $adminpost><span class="teampost">## Team ##</span></if>
		<span class="date"><var encode_entities(get_date($timestamp))></span>
	</label>

	<if $ssl>
		<span class="ssl" onmouseover="Tip('<var $ssl>')" onmouseout="UnTip()"><img src="<var SSL_ICON>" alt="SSL" /></span>
	</if>

	<span class="reflink">
                <if !$parent>
                        <if $isAdmin> 
                                <a href="<var get_reply_link($num,0,$admin)>#i<var $num>">Nr. <var $num></a>
                        </if>
                        <if !$isAdmin>
                                <a href="<var get_reply_link($num,0)>#i<var $num>">Nr. <var $num></a>
                        </if>
                </if>			
                <if $parent>
                        <if $isAdmin>
                                <a href="<var get_reply_link($parent,0,$admin)>#i<var $num>">Nr. <var $num></a>
                        </if>
                        <if !$isAdmin>
                                <a href="<var get_reply_link($parent,0)>#i<var $num>">Nr. <var $num></a>
                        </if>
                </if>
	</span>

	<if !$parent>
		<if !$sticky_isnull><span class="sticky"><img src="/img/icons/pin.png" onmouseover="Tip('<var S_STICKYTITLE>')" onmouseout="UnTip()" alt="Pin" /></span></if>
		<if $locked><span class="locked"><img src="/img/icons/locked.png" onmouseover="Tip('<var S_LOCKEDTITLE>')" onmouseout="UnTip()" alt="Lock" /></span></if>
		<if !$autosage><if $email><span class="sage"><const S_SAGE></span></if></if>
		<if $sticky_isnull><if $autosage><span class="sage">Systemkontra</span></if></if>
	</if>

	<if $parent>
		<if $email><span class="sage"><const S_SAGE></span></if>
	</if>

	<if !$parent>	
		<if $isAdmin>
			<if !$thread>
			<span class="replylink">[<a href="<var get_reply_link($num,0,$admin)>"><const S_REPLY></a>]</span>
			</if>
		</if>
		<if !$isAdmin>
			<if !$thread>
			<span class="replylink">[<a href="<var get_reply_link($num,0)>"><const S_REPLY></a>]</span>
			</if>
		</if>
	</if>

	<if $isAdmin>  
		[<var dec_to_dot($ip)>] 
		<if !$parent>	
			<if $sticky_isnull>
				<span class="sticky" onmouseover="Tip('<const S_MPSTICKY>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=sticky&amp;threadid=<var $num>"><img src="/img/icons/sticky.png"></a></span>
			</if>

			<if !$sticky_isnull>
				<span class="unsticky" onmouseover="Tip('<const S_MPUNSTICKY>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=sticky&amp;threadid=<var $num>"><img src="/img/icons/unsticky.png"></a></span>
			</if>
			
			<if !$locked>
				<span class="lock" onmouseover="Tip('<const S_MPLOCK>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=lock&amp;threadid=<var $num>"><img src="/img/icons/lock.png"></a></span>
			</if>

			<if $locked>
				<span class="unlock" onmouseover="Tip('<const S_MPUNLOCK>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=lock&amp;threadid=<var $num>"><img src="/img/icons/unlock.png"></a></span>
			</if>
		
			<if !$autosage>
				<span class="lock" onmouseover="Tip('<const S_MPSETSAGE>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=kontra&amp;threadid=<var $num>"><img src="/img/icons/sage.png"></a></span>
			</if>

			<if $autosage>
				<span class="autosage" onmouseover="Tip('<const S_MPUNSETSAGE>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=kontra&amp;threadid=<var $num>"><img src="/img/icons/unsage.png"></a></span>
			</if>
			
		</if>
		<span class="ban"         onmouseover="Tip('<const S_MPBAN>')"       onmouseout="UnTip()"><a onclick="do_ban('<var dec_to_dot($ip)>', <var $num>, '<const BOARD_IDENT>', '<var $admin>')"><img src="/img/icons/ban.png"></a></span>
		<span class="deleteall"   onmouseover="Tip('<const S_MPDELETEALL>')" onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=deleteall&amp;ip=<var $ip>"><img src="/img/icons/delete_all.png"></a></span>
		<span class="delete_file" onmouseover="Tip('<const S_MPDELFILE>')"   onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=delete&amp;delete=<var $num>&amp;fileonly=on"><img src="/img/icons/delete_file.png"></a></span>
		<span class="delete_post" onmouseover="Tip('<const S_MPDELETE>')"    onmouseout="UnTip()"><a href="<var $self>?admin=<var $admin>&amp;task=delete&amp;delete=<var $num>"><img src="/img/icons/delete.png"></a></span>
	</if>

<if $parent>
	</section>
</if>

<if !$parent>
	</header>
	<section class="post">
</if>

<section class="post_body">

<loop $files>

<section class="file">
	<div style="display: none; min-width: 250px;" id="imageinfo_<var md5_hex($image)>">
		<strong>Dateiname:</strong> <var $uploadname><br />
		<hr />
		<var get_meta_markup($image)>
	</div>
	<div class="filename"><const S_PICNAME><a target="_blank" title="<var $uploadname>" href="<var expand_image_filename($image)>/<var get_urlstring($uploadname)>"><var get_displayname($uploadname)></a></div>
	<div class="filesize"><var get_displaysize($size, DECIMAL_MARK)><if $width && $height>, <var $width>&nbsp;&times;&nbsp;<var $height></if></div>
	<if $thumbnail>
		<div class="filelink">
		<a target="_blank" href="<var expand_image_filename($image)>">
			<img onmouseover="TagToTip('imageinfo_<var md5_hex($image)>', TITLE, '<const S_FILEINFO>', WIDTH, 300)" onmouseout="UnTip()" src="<var expand_filename($thumbnail)>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" />
		</a>
		</div>
	</if>
	<if !$thumbnail>
		<if !$size>
			<div class="filedeleted"><const S_FILEDELETED></div>
		</if>
		<if $size>
			<if DELETED_THUMBNAIL>
				<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
					<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width>" height="<var $tn_height>" alt="" />
				</a>
			</if>
			<if !DELETED_THUMBNAIL>
				<div class="filetype">
					<a onmouseover="TagToTip('imageinfo_<var md5_hex($image)>', TITLE, '<const S_FILEINFO>', WIDTH, 300)" onmouseout="UnTip()" target="_blank" href="<var expand_image_filename($image)>">
						<var get_extension($uploadname)>
					</a>
				</div>
			</if>
		</if>		
	</if>
</section>

</loop>

	<section class="text">
		<var $comment>
		<if $abbrev>
			<if $isAdmin>
				<var sprintf(S_ABBRTEXT,get_reply_link($num,$parent,$admin))>
			</if>
			<if !$isAdmin>
				<var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))>
			</if>
		</if>
	</section>

</section>
</section>
</article>

<if !$parent>
	<if $omitmsg>
		<aside class="omittedposts">
			<var $omitmsg>
		</aside>
	</if>
</if>
