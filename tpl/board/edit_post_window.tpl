<include %TMPLDIR%head.tpl>
<div class="dellist"><var sprintf($$locale{S_EDITHEAD},Wakaba::get_reply_link($num,$parent),$num)></div>

<loop $loop>
<div class="postarea">
<form id="postform" action="<var %self>" method="post" enctype="multipart/form-data">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="doedit" />
<input type="hidden" name="num" value="<var $num>" />
<if $noformat><input type="hidden" name="noformat" value="on" /></if>

<table><tbody>
<tr><td class="postblock"><var $$locale{S_NAME}></td><td><input type="text" name="field1" size="28" value="<var $name>" />
<if $trip><label><input type="checkbox" name="notrip" value="yes" /> Kill trip (<var $trip>)</label></if>
</td></tr>
<tr><td class="postblock"><label for="sage"><var $$locale{S_SAGE}></label></td>
<td><label><input type="checkbox" name="field2" value="sage" id="sage" <if $email>checked="checked"</if> /> <var $$locale{S_SAGEDESC}></label></td></tr>
<tr><td class="postblock"><var $$locale{S_SUBJECT}></td><td><input type="text" name="field3" size="35" value="<var $subject>" />
<input type="submit" value="<var $$locale{S_SUBMIT}>" /></td></tr>
<tr><td class="postblock"><var $$locale{S_COMMENT}></td>
<td><textarea name="field4" cols="48" rows="6"><if $noformat><var $comment></else/><var Wakaba::tag_killa($comment)></if></textarea></td></tr>
<!-- files -->
<tr id="fileUploadField"><td class="postblock"><var $$locale{S_UPLOADFILE}> (max. <var $$cfg{MAX_FILES}>)</td>
<td id="fileInput"><div><input type="file" name="file" onchange="file_input_change(<var $$cfg{MAX_FILES}>)" /></div>
</td></tr>
<if scalar @{$$cfg{POMF_EXTENSIONS}}>
	<tr><td class="postblock"><label for="nopomf"><var $$locale{S_NOPOMF}></label></td>
	<td><label><input type="checkbox" name="no_pomf" value="on" id="nopomf" /> <var $$locale{S_NOPOMFDESC}></label></td>
	</tr>
</if>
<!-- files -->
<tr><td class="postblock"><var $$locale{S_OPTIONS}></td><td>
<label><input type="checkbox" name="capcode" value="on" <if $adminpost>checked="checked"</if> /> ## Cap ## </label>
|<label><input type="checkbox" name="admin_post" value="on" <if $admin_post>checked="checked"</if> /> Admin post </label>
<if !$noformat>| [ <a href="<var %self>?task=edit&amp;num=<var $num>&amp;section=<var $$cfg{SELFPATH}>&amp;noformat=1">No Format</a> ]</if>
</td></tr>
</tbody></table></loop>
</form></div><hr />
<include %TMPLDIR%foot.tpl>
