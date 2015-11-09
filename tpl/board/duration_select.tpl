<if @{$$cfg{BAN_DATES}}>
	<select name="expires" id="expires">
		<loop $$cfg{BAN_DATES}>
			<option value="<var $time>"<if $default> selected="selected"</if>><var Wakaba::clean_string($label)></option>
		</loop>
	</select>
</else/>
	<input type="text" name="expires" size="16" />
	<small><var $$locale{S_BANSECONDS}></small>
</if>
