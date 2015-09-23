<include %TMPLDIR%/head.tpl>
<perleval %isAdmin=$isAdmin; %thread=$thread />
<if !$locked or $isAdmin>
<if !DISABLE_NEW_THREADS or $thread or $isAdmin>
<if $postform>
	<div class="postarea">
	<form id="postform" action="<var %self>" method="post" enctype="multipart/form-data">

	<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
	<input type="hidden" name="task" value="post" />
	<if $isAdmin>
		<input type="hidden" name="admin_post" value="yes" />
	</if>
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<if !$isAdmin and !$image_inp and !$thread and $$cfg{ALLOW_TEXTONLY}>
		<input type="hidden" name="nofile" value="1" />
	</if>

	<div class="trap">
		<input type="text" name="name" size="31" />
		<input type="text" name="link" size="36" />
	</div>	

	<table>
	<tbody id="postTableBody">
		<if $isAdmin>
			<tr><td class="postblock">## Team ##</td>
			<td><label><input type="checkbox" name="as_staff" value="1" />  <var $$locale{S_POSTASADMIN}></label></td></tr>
		</if>
		<if $isAdmin>
			<tr><td class="postblock">HTML</td>
			<td><label><input type="checkbox" name="no_format" value="1" /> <var $$locale{S_NOTAGS2}></label></td></tr>
		</if>
	<if !($$cfg{FORCED_ANON}) or $isAdmin><tr><td class="postblock"><label for="name"><var $$locale{S_NAME}></label></td><td><input type="text" name="nya1" id="name" /></td></tr></if>

	<tr><td class="postblock"><label for="subject"><var $$locale{S_SUBJECT}></label></td><td><input type="text" name="nya3" id="subject" />
	<input type="submit" id="postform_submit" value="<if $thread><var $$locale{S_BTREPLY}> /<var $$cfg{SELFPATH}>/<var $thread></if><if !$thread><var $$locale{S_BTNEWTHREAD}></if>" /></td>
	</tr>

	<if $thread>
	<tr><td class="postblock"><label for="sage"><var $$locale{S_SAGE}></label></td>
	<td><label><input type="checkbox" name="nya2" value="sage" id="sage" /> <var $$locale{S_SAGEDESC}></label></td>
	</tr>
	</if>

	<tr><td class="postblock"><label for="field4"><var $$locale{S_COMMENT}></label></td>
	<td><textarea id="field4" name="nya4" cols="48" rows="6"></textarea> <img onclick="resizeCommentfield('field4', this)" src="/img/icons/expand.png" alt="<var $$locale{S_IMGEXPAND}>" title="<var $$locale{S_IMGEXPAND}>" />
	</td></tr>

	<if $image_inp or $isAdmin>
		<tr id="fileUploadField"><td class="postblock"><var $$locale{S_UPLOADFILE}> (max. 4)</td>
		<td id="fileInput"><div><input type="file" name="file" onchange="file_input_change(4)" /></div>
		<if $textonly_inp>[<label><input type="checkbox" name="nofile" value="on" /><var $$locale{S_NOFILE}> ]</label></if>
		</td></tr>
	</if>

	<if $isAdmin or scalar @{$$cfg{POMF_EXTENSIONS}} && $image_inp>
	<tr><td class="postblock"><label for="nopomf"><var $$locale{S_NOPOMF}></label></td>
	<td><label><input type="checkbox" name="no_pomf" value="on" id="nopomf" onclick="Settings.set('nopomf', +this.checked);" /> <var $$locale{S_NOPOMFDESC}></label></td>
	</tr>
	</if>

	<tr id="trgetback"><td class="postblock"><var $$locale{S_NOKO}></td>
	<td>
	<label><input name="gb2" value="board" checked="checked" type="radio" /> <var $$locale{S_NOKOOFF}></label>
	<label><input name="gb2" value="thread" type="radio" /> <var $$locale{S_NOKOON}></label>
	</td></tr>

	<if Wakaba::need_captcha($$cfg{CAPTCHA_MODE}, $$cfg{CAPTCHA_SKIP}, $loc)>
		<tr><td class="postblock"><var $$locale{S_CAPTCHA}> (<a href="/faq">?</a>) (<var $loc>)</td><td><input type="text" name="captcha" size="10" /> <img alt="" onclick="update_captcha(this);" id="imgcaptcha" src="/captcha.pl?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>&amp;board=<var $$cfg{SELFPATH}>" /></td></tr>
	</if>

	<tr id="passwordField"><td class="postblock"><label for="password"><var $$locale{S_DELPASS}></label></td><td><input type="password" name="password" id="password" /> <var $$locale{S_DELEXPL}></td></tr>
	<tr><td colspan="2">
	<div class="rules"><include %TMPLDIR%rules.tpl></div>
	</tbody>
	</table>
	</form>
	</div>
	<script type="text/javascript">set_inputs("postform")</script>

</if>
</if>
</if>

<if $locked && !$isAdmin>
<p class="locked"><var sprintf($$locale{S_THREADLOCKED}, $thread)></p>
</if>

<form id="delform" action="<var %self>" method="post">

<loop $threads>
<perleval %omitmsg=$omitmsg />
	<hr />
	<if !%thread>
		<div id="thread_<var $num>" class="thread">
	</else/>
		<div id="thread_<var %thread>" class="thread">
	</if>

		<loop $posts><include %TMPLDIR%/post_view.tpl></loop>

		</div>
	<p style="clear: both;"></p>
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
	<input type="hidden" name="task" value="delete" />
	<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
	<if $isAdmin><input type="hidden" name="admindel" value="yes" /></if>
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<input type="password" name="password" placeholder="<var $$locale{S_DELKEY}>" />
	<input value="<var $$locale{S_DELETE}>" type="submit" />
</div>

</form>

<script type="text/javascript">set_delpass("delform")</script>
<include %TMPLDIR%/foot.tpl>
