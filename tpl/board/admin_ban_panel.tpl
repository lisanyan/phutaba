<include %TMPLDIR%/head.tpl>
<div class="dellist"><const S_MANABANS></div>

<div style="display: none; min-width: 250px;" id="banexpireshelp">
<const S_BANEXPIRESDESC>
</div>

<div class="postarea">
<table><tbody><tr><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="ipban" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><const S_BANEXPIRESLABEL></span></td><td>
<if !$parsedate and scalar (BAN_DATES)>
	<select name="expires">
		<loop (BAN_DATES)>
			<option value="<var $time>"<if $default> selected="selected"</if>><var clean_string($label)></option>
		</loop>
	</select>
<else>
	<input type="text" name="expires" size="16" />
	<if !$parsedate><small><const S_BANSECONDS></small></if>
</if>
<input type="submit" value="<const S_BANIP>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="whitelist" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><const S_BANEXPIRESLABEL></span></td><td>
<if !$parsedate and scalar (BAN_DATES)>
	<select name="expires">
		<loop (BAN_DATES)>
			<option value="<var $time>"<if $default> selected="selected"</if>><var clean_string($label)></option>
		</loop>
	</select>
<else>
	<input type="text" name="expires" size="16" />
	<if !$parsedate><small><const S_BANSECONDS></small></if>
</if>
<input type="submit" value="<const S_BANWHITELIST>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="wordban" />
<table><tbody>
<tr><td class="postblock"><const S_BANWORDLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><const S_BANEXPIRESLABEL></span></td><td>
<if !$parsedate and scalar (BAN_DATES)>
	<select name="expires">
		<loop (BAN_DATES)>
			<option value="<var $time>"<if $default> selected="selected"</if>><var clean_string($label)></option>
		</loop>
	</select>
<else>
	<input type="text" name="expires" size="16" />
	<if !$parsedate><small><const S_BANSECONDS></small></if>
</if>
<input type="submit" value="<const S_BANWORD>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="trust" />
<table><tbody>
<tr><td class="postblock"><const S_BANTRUSTTRIP></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><const S_BANEXPIRESLABEL></span></td><td>
<if !$parsedate and scalar (BAN_DATES)>
	<select name="expires">
		<loop (BAN_DATES)>
			<option value="<var $time>"<if $default> selected="selected"</if>><var clean_string($label)></option>
		</loop>
	</select>
<else>
	<input type="text" name="expires" size="16" />
	<if !$parsedate><small><const S_BANSECONDS></small></if>
</if>
<input type="submit" value="<const S_BANTRUST>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom" colspan="3">

<form action="<var %self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="asban" />
<table><tbody>
<tr><td class="postblock"><const S_BANASNUMLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><const S_BANEXPIRESLABEL></span></td><td>
<if !$parsedate and scalar (BAN_DATES)>
	<select name="expires">
		<loop (BAN_DATES)>
			<option value="<var $time>"<if $default> selected="selected"</if>><var clean_string($label)></option>
		</loop>
	</select>
<else>
	<input type="text" name="expires" size="16" />
	<if !$parsedate><small><const S_BANSECONDS></small></if>
</if>
<input type="submit" value="<const S_BANASNUM>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

</td></tr></tbody></table>
</div><br />

<div style="text-align:center">
<if $filter ne "off">[<a href="<var %self>?task=bans&amp;section=<var $$cfg{SELFPATH}>&amp;filter=off#tbl"><const S_BANSHOWALL></a>]</if>
<if $filter eq "off">[<a href="<var %self>?task=bans&amp;section=<var $$cfg{SELFPATH}>#tbl"><const S_BANFILTER></a>]</if>
</div>
<a id="tbl"></a>
<table align="center"><tbody>
<tr class="managehead"><const S_BANTABLE></tr>

<loop $bans>
	<if $divider><tr class="managehead"><th colspan="7"></th></tr></if>

	<tr class="row<var $rowtype>">

	<if $type eq "ipban">
		<td>IP</td>
		<td><img src="/img/flags/<var $flag>.PNG"> <var dec_to_dot($ival1)></td><td>/<var get_mask_len($ival2)> (<var dec_to_dot($ival2)>)</td>
	</if>
	<if $type eq "wordban">
		<td>Word</td>
		<td colspan="2"><var $sval1></td>
	</if>
	<if $type eq "trust">
		<td>NoCap</td>
		<td colspan="2"><var $sval1></td>
	</if>
	<if $type eq "whitelist">
		<td>Whitelist</td>
		<td><img src="/img/flags/<var $flag>.PNG"> <var dec_to_dot($ival1)></td><td>/<var get_mask_len($ival2)> (<var dec_to_dot($ival2)>)</td>
	</if>
	<if $type eq "asban">
		<td>ASNum</td>
		<td colspan="2"><var $sval1></td>
	</if>

	<td><var $comment></td>
	<td>
		<if $date>
			<var make_date($date, "2ch")>
		</if>
		<if !$date>
			<i>none</i>
		</if>
	</td>	
	<td><if $expires><var make_date($expires, "2ch")><else><em>nevah</em></if></td>
	<td>
	<a href="<var %self>?task=baneditwindow&amp;num=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><const S_BANEDIT></a>
	<a href="<var %self>?task=removeban&amp;num=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><const S_BANREMOVE></a>
	</td>
	</tr>
</loop>

</tbody></table><br />
<include %TMPLDIR%/foot.tpl>