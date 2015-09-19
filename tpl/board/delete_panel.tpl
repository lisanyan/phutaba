<include %TMPLDIR%head.tpl>
<div class="dellist"><var $$locale{S_MPDELETEIP}></div>

<div class="postarea">
<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="board" value="<var $$cfg{BOARD_NAME}>" />
<input type="hidden" name="ip" value="<var $ip>" />
<input type="hidden" name="mask" value="<var Wakaba::dec_to_dot($mask)>" />
<input type="hidden" name="go" value="1" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANIPLABEL}></td><td><var Wakaba::dec_to_dot($ip)></td></tr>
<tr><td class="postblock"><var $$locale{S_BANMASKLABEL}></td><td><var Wakaba::dec_to_dot($mask)></tr>
<tr><td class="postblock"><var $$locale{S_DELALLMSG}></td><td><var sprintf($$locale{S_DELALLCOUNT}, $posts, $threads)>
<input type="submit" value="<var $$locale{S_MPDELETEIP}>" /></td></tr>
</tbody></table></form>
</div>
<include %TMPLDIR%foot.tpl>