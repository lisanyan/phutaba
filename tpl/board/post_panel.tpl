<include %TMPLDIR%/head.tpl>
<div class="dellist"><var $$locale{S_MANATOOLS}></div>

<div class="postarea">

<var $$locale{S_MANAGEOINFO}>
<table><tbody>
<tr><td class="postblock">GeoIP-API</td><td><var $geoip_api></td></tr>
<loop $geoip_results>
	<tr><td class="postblock"><var $file></td><td><var $result></td></tr>
</loop>
</tbody></table>

</div>

<br /><div class="postarea">

<!-- <var $$locale{S_MANADELETE}> -->
<form action="<var %self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANIPLABEL}></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANMASKLABEL}></td><td><input type="text" name="mask" size="24" />
<input type="submit" value="<var $$locale{S_MPDELETEIP}>" /></td></tr>
</tbody></table></form>

</div><br />

<var sprintf($$locale{S_IMGSPACEUSAGE}, Wakaba::get_displaysize($size, $$cfg{DECIMAL_MARK}), $files, $posts, $threads)>
<include %TMPLDIR%/foot.tpl>