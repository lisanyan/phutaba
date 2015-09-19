<include %TMPLDIR%head.tpl>
<div class="dellist"><const S_MANAORPH> (<var $file_count> Files, <var $thumb_count> Thumbs)</div>

<div class="postarea">

<form action="<var %self>" method="post">

<table><tbody>
	<tr class="managehead"><const S_ORPHTABLE></tr>
	<loop $files>
		<tr class="row<var $rowtype>">
		<td><a target="_blank" href="<var Wakaba::expand_filename($name)>"><const S_MANASHOW></a></td>
		<td><label><input type="checkbox" name="file" value="<var $name>" checked="checked" /><var $name></label></td>
		<td><var make_date($modified, "2ch")></td>
		<td align="right"><var get_displaysize($size, $$cfg{DECIMAL_MARK})></td>
		</tr>
	</loop>
</tbody></table><br />

<loop $thumbs>
	<div class="file">
	<label><input type="checkbox" name="file" value="<var $name>" checked="checked" /><var $name></label><br />
	<var make_date($modified, "2ch")> (<var get_displaysize($size, $$cfg{DECIMAL_MARK})>)<br />
	<img src="<var Wakaba::expand_filename($name)>" />
	</div>
</loop>

<p style="clear: both;"></p>

<input type="hidden" name="task" value="movefiles" />
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input value="<const S_MPARCHIVE>" type="submit" />
</form>

</div>
<include %TMPLDIR%foot.tpl>