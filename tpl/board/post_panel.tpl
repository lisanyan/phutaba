<include %TMPLDIR%head.tpl>
<div class="dellist"><const S_MANATOOLS></div>

<div class="postarea">

<const S_MANAGEOINFO>
<table><tbody>
<tr><td class="postblock">GeoIP-API</td><td><var $geoip_api></td></tr>
<loop $geoip_results>
	<tr><td class="postblock"><var $file></td><td><var $result></td></tr>
</loop>
</tbody></table>

</div>

<br /><div class="postarea">

<!-- <const S_MANADELETE> -->
<form action="<var %self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" />
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>

</div><br />

<var sprintf(S_IMGSPACEUSAGE, get_displaysize($size, $$cfg{DECIMAL_MARK}), $files, $posts, $threads)>
<include %TMPLDIR%foot.tpl>