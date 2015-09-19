<include %TMPLDIR%normal_head.tpl>
<if $admin>
	<!--[<a href="<var expand_filename(%self)>?section=<var $$cfg{SELFPATH}>"><const S_MANARET></a>]-->
	[<a href="<var %self>?task=show&amp;section=<var $$cfg{SELFPATH}>"><const S_MANAPANEL></a>]
	[<a href="<var %self>?task=mpanel&amp;section=<var $$cfg{SELFPATH}>"><const S_MANATOOLS></a>]
	[<a href="<var %self>?task=bans&amp;section=<var $$cfg{SELFPATH}>"><const S_MANABANS></a>]
	<if $modclass eq "admin">
	[<a href="<var %self>?task=orphans&amp;section=<var $$cfg{SELFPATH}>"><const S_MANAORPH></a>]
	[<a href="<var %self>?task=viewlog&amp;section=<var $$cfg{SELFPATH}>"><const S_MANALOG></a>]
	</if>
	[<a href="<var %self>?task=logout&amp;section=<var $$cfg{SELFPATH}>"><const S_MANALOGOUT></a>]
	<div class="passvalid"><const S_MANAMODE></div>
</if>