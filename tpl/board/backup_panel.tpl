<include %TMPLDIR%/head.tpl>
<perleval %admin=$admin; %thread=$thread />

<if $$cfg{ENABLE_POST_BACKUP}>
<p style="text-align:center"><em>Wakaba is currently set to purge all posts older than <var ($$cfg{POST_BACKUP_EXPIRE} / 24 / 3600)> day(s).</em></p>
</if>

<form id="delform" action="<var %self>" method="post">

<loop $threads>
<perleval %omitmsg=$omitmsg />
	<hr />
	<if !%thread>
		<div id="thread_<var $postnum>" class="thread">
	</else/>
		<div id="thread_<var %thread>" class="thread">
	</if>
		<loop $posts><include %TMPLDIR%/post_view_backup.tpl></loop>

		</div>
</loop>

<if $thread>
<div id="websock_enabled"></div>
</if>

<hr />

<if !$thread>
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
			<li>[<a href="#top" id="bottom"><var $$locale{S_TOP}></a>]</li>
		</ul>
	</nav>
</if>
<if $thread>
	<nav>
		<ul class="pagelist">
			<li>[<a href="#top" id="bottom"><var $$locale{S_TOP}></a>]</li>
			<li id="updater">[<a href="javascript:void(0)" id="updater_href"><var $$locale{S_JS_UPDATE}></a>]</li>
		</ul>
	</nav>
</if>

<div class="delete">
	<input type="hidden" name="task" value="restorebackups" />
	<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
	<input type="hidden" name="board" value="<var $$cfg{SELFPATH}>" />
	<input type="submit" name="handle" value="<var $$locale{S_MPRESTORE}>" />
	<input type="submit" name="handle" value="<var $$locale{S_MPDELETE}>" />
	<input type="reset" value="<var $$locale{S_MPRESET}>" />
</div>

</form>

<if $postform><div class="postarea" id="postform2"></div></if>

<include %TMPLDIR%/foot.tpl>
