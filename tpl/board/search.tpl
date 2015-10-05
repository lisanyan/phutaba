<include %TMPLDIR%head.tpl>
	<div class="postarea">
	<form id="searchform" action="<var %self>" method="post" enctype="multipart/form-data">
	<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
	<input type="hidden" name="task" value="search" />

	<table>
	<tbody>

		<tr><td class="postblock"><label for="search"><var $$locale{S_SEARCH}><br />
		<var $$locale{S_MINLENGTH}></label></td>
		<td><input type="text" name="find" id="search" value="<var $find>" />
		<input value="<var $$locale{S_SEARCHSUBMIT}>" type="submit" />
		</td></tr>

		<tr><td class="postblock"><var $$locale{S_OPTIONS}></td>
		<td>
		<label><input type="checkbox" name="op"      value="1" <if $oponly>checked="checked"</if> /> <var $$locale{S_SEARCHOP}></label><br />
		<label><input type="checkbox" name="subject" value="1" <if $insubject>checked="checked"</if> /> <var $$locale{S_SEARCHSUBJECT}></label><br />
		<!--<label><input type="checkbox" name="files"   value="1" <if $filenames>checked="checked"</if> /> <var $$locale{S_SEARCHFILES}></label><br />-->
		<label><input type="checkbox" name="comment" value="1" <if $comment>checked="checked"</if> /> <var $$locale{S_SEARCHCOMMENT}></label>
		</td></tr>

	</tbody>
	</table>

	</form>
	</div>

	<if $find>
		<hr />
		<var $$locale{S_SEARCHFOUND}> <var $count>
		<if $count><br /><br /></if>
	</if>

	<loop $posts>
		<include %TMPLDIR%post_view.tpl>
		<p style="clear: both;"></p>
	</loop>

	<hr />
<include %TMPLDIR%foot.tpl>
