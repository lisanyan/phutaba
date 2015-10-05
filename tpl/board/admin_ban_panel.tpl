<include %TMPLDIR%head.tpl>
<div class="dellist"><var $$locale{S_MANABANS}></div>

<div style="display: none; min-width: 250px;" id="banexpireshelp">
<var $$locale{S_BANEXPIRESDESC}>
</div>

<div class="postarea">
<table><tbody><tr><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="ipban" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANIPLABEL}></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANMASKLABEL}></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANCOMMENTLABEL}></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><var $$locale{S_BANEXPIRESLABEL}></span></td><td>
<include %TMPLDIR%duration_select.tpl>
<input type="submit" value="<var $$locale{S_BANIP}>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="whitelist" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANIPLABEL}></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANMASKLABEL}></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANCOMMENTLABEL}></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><var $$locale{S_BANEXPIRESLABEL}></span></td><td>
<include %TMPLDIR%duration_select.tpl>
<input type="submit" value="<var $$locale{S_BANWHITELIST}>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="wordban" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANWORDLABEL}></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANCOMMENTLABEL}></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><var $$locale{S_BANEXPIRESLABEL}></span></td><td>
<include %TMPLDIR%duration_select.tpl>
<input type="submit" value="<var $$locale{S_BANWORD}>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="trust" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANTRUSTTRIP}></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANCOMMENTLABEL}></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><var $$locale{S_BANEXPIRESLABEL}></span></td><td>
<include %TMPLDIR%duration_select.tpl>
<input type="submit" value="<var $$locale{S_BANTRUST}>" /></td></tr>
</td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom" colspan="3">

<form action="<var %self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="asban" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANASNUMLABEL}></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><var $$locale{S_BANCOMMENTLABEL}></td><td><input type="text" name="comment" size="16" /></td></tr>
<tr><td class="postblock"><span<if $parsedate> class="expireshelp" onmouseover="TagToTip('banexpireshelp')" onmouseout="UnTip()"</if>><var $$locale{S_BANEXPIRESLABEL}></span></td><td>
<include %TMPLDIR%duration_select.tpl>
<input type="submit" value="<var $$locale{S_BANASNUM}>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

</td></tr></tbody></table>
</div><br />

<div style="text-align:center">
<if $filter ne "off">[<a href="<var %self>?task=bans&amp;section=<var $$cfg{SELFPATH}>&amp;filter=off#tbl"><var $$locale{S_BANSHOWALL}></a>]</if>
<if $filter eq "off">[<a href="<var %self>?task=bans&amp;section=<var $$cfg{SELFPATH}>#tbl"><var $$locale{S_BANFILTER}></a>]</if>
</div>
<a id="tbl"></a>
<table align="center"><tbody>
<tr class="managehead"><var $$locale{S_BANTABLE}></tr>

<loop $bans>
	<if $divider><tr class="managehead"><th colspan="7"></th></tr></if>

	<tr class="row<var $rowtype>">

	<if $type eq "ipban">
		<td>IP</td>
		<td><img style="vertical-align:top" src="/img/flags/<var $flag>.PNG"> <var Wakaba::dec_to_dot($ival1)></td><td>/<var Wakaba::get_mask_len($ival2)> (<var Wakaba::dec_to_dot($ival2)>)</td>
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
		<td><img style="vertical-align:top" src="/img/flags/<var $flag>.PNG"> <var Wakaba::dec_to_dot($ival1)></td><td>/<var Wakaba::get_mask_len($ival2)> (<var Wakaba::dec_to_dot($ival2)>)</td>
	</if>
	<if $type eq "asban">
		<td>ASNum</td>
		<td colspan="2"><var $sval1></td>
	</if>

	<td><var $comment></td>
	<td>
		<if $date>
			<var Wakaba::make_date($date, "2ch")>
		</if>
		<if !$date>
			<i>none</i>
		</if>
	</td>	
	<td><if $expires><var Wakaba::make_date($expires, "2ch")><else><em>nevah</em></if></td>
	<td>
	<a href="<var %self>?task=baneditwindow&amp;num=<var $num>&amp;section=<var $$cfg{SELFPATH}>"><var $$locale{S_BANEDIT}></a>
	<a href="<var %self>?task=removeban&amp;num=<var $num>&amp;section=<var $$cfg{SELFPATH}>" onclick="return areYouSure(this)"><var $$locale{S_BANREMOVE}></a>
	</td>
	</tr>
</loop>

</tbody></table><br />
<include %TMPLDIR%foot.tpl>