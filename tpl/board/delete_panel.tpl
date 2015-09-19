<include %TMPLDIR%head.tpl>
<div class="dellist"><const S_MPDELETEIP></div>

<div class="postarea">
<form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="board" value="<var $$cfg{BOARD_NAME}>" />
<input type="hidden" name="ip" value="<var $ip>" />
<input type="hidden" name="mask" value="<var dec_to_dot($mask)>" />
<input type="hidden" name="go" value="1" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><var dec_to_dot($ip)></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><var dec_to_dot($mask)></tr>
<tr><td class="postblock"><const S_DELALLMSG></td><td><var sprintf(S_DELALLCOUNT, $posts, $threads)>
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>
</div>
<include %TMPLDIR%foot.tpl>