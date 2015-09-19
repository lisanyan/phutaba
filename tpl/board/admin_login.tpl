<include %TMPLDIR%head.tpl>
<div align="center"><form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="admin" />
<const S_ADMINPASS>
<input type="password" name="berra" size="8" value="" />
<br />
<label><input type="checkbox" name="savelogin" value="yas" /> <const S_MANASAVE></label>
<br />
<select name="nexttask">
<option value="show"><const S_MANAPANEL></option>
<option value="mpanel"><const S_MANATOOLS></option>
<option value="bans"><const S_MANABANS></option>
<option value="orphans"><const S_MANAORPH></option>
</select>
<input type="submit" value="<const S_MANASUB>" />
</form></div>
<include %TMPLDIR%foot.tpl>