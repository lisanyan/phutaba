<include %TMPLDIR%head.tpl>
	<div class="postarea">
	<form id="searchform" action="<var %self>" method="post" enctype="multipart/form-data">
	<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
	<input type="hidden" name="task" value="search" />

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
	</div>

	<if $find>
		<hr />
		<var S_SEARCHFOUND> <var $count>
		<if $count><br /><br /></if>
	</if>

	<loop $posts>
		<include %TMPLDIR%post_view.tpl>
	</loop>

	<p style="clear: both;"></p>
	<hr />
<include %TMPLDIR%foot.tpl>
