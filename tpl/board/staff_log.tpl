<include %TMPLDIR%head.tpl>
[<a onclick="return areYouSure(this)" href="<var %self>?task=clearlog&amp;section=<var $$cfg{SELFPATH}>">Clear Log</a>]
[<a onclick="return areYouSure(this)" href="<var %self>?task=clearlog&amp;clearall=1&amp;section=<var $$cfg{SELFPATH}>">Clear All</a>]

<table align="center" style="white-space: nowrap; width: auto;">
<thead>
	<tr class="managehead">
		<td>User</td>
		<td>Action</td>
		<td>Object</td>
		<td>Board</td>
		<td>Date</td>
	</tr>
</thead>
<tbody>
<loop $log>
	<tr class="row<var $rowtype>">
		<td><var $user>@<var Wakaba::dec_to_dot($ip)></td>
		<td><var $action></td>
		<td>
			<if $action eq "delall">
				<var Wakaba::dec_to_dot($object)>
			</if>
			<if $action=~/ipban$/>
				<var $object>
			</if>
			<if $action =~ /post|file|sticky|lock|autosage/>
				No.<var $object>
			</if>
			<if $action =~ /^removeadminentry|^editadminentry$/>
				No.<var $object>
			</if>
		</td>
		<td>/<var $board>/</td>
		<td><var Wakaba::make_date($time, "2ch")></td>
	</tr>
</loop>
<tr><td><br/></td></tr>
</tbody>
</table>

<nav>
	<ul class="pagelist">
		<li>
			<if $prevpage>[<a href="<var $prevpage>"><var $$locale{S_PREV}></a>]</if>
			<if !$prevpage>[<var $$locale{S_PREV}>]</if>
		</li>
	<loop $pages>
		<li>
			<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
			<if $current>[<strong><var $page></strong>]</if>
		</li>
	</loop>
		<li>
			<if $nextpage>[<a href="<var $nextpage>"><var $$locale{S_NEXT}></a>]</if>
			<if !$nextpage>[<var $$locale{S_NEXT}>]</if>
		</li>
	</ul>
	<ul class="pagelist">
		<li>[<a href="#top"><var $$locale{S_TOP}></a>]</li>
	</ul>
</nav>
<include %TMPLDIR%foot.tpl>