<include %TMPLDIR%head.tpl>
<hr />
<div align="center"><form action="<var %self>" method="post">
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="task" value="admin" />
<var $$locale{S_ADMINPASS}>
<input type="password" name="berra" size="8" value="" />
<br />
<label><input type="checkbox" name="savelogin" value="yas" /> <var $$locale{S_MANASAVE}></label>
<br />
<select name="nexttask">
<option value="show"><var $$locale{S_MANAPANEL}></option>
<option value="mpanel"><var $$locale{S_MANATOOLS}></option>
<option value="bans"><var $$locale{S_MANABANS}></option>
<option value="orphans"><var $$locale{S_MANAORPH}></option>
</select>
<input type="submit" value="<var $$locale{S_MANASUB}>" />
</form></div>
<include %TMPLDIR%foot.tpl>