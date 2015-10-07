<footer>
	<p>Powered by <img src="/img/phutaba_icon.png" alt="" /> <strong>Phutaba</strong>.<br /><span id="fcgi_counter">FCGI Loops: <var Wakaba::get_fcgicounter()></span></p>
	<p>Зеркало <a href="https://02ch.info">02ch.info</a></p>
	<p><em>Report illegal material to <a href="mailto:<var $$cfg{ADMIN_EMAIL}>"><var $$cfg{ADMIN_EMAIL}></a>.</em></p>
</footer>
<nav>
	<ul class="menu_bottom">
<include tpl/nav_boards.html>
	</ul>
</nav>
</div>
<const TRACKING_CODE>

<script type="text/javascript">var style_cookie="<var $$cfg{STYLE_COOKIE}>";</script>
<script type="text/javascript" src="/static/js/wakaba3.js"></script>
<script type="text/javascript" src="/static/vendor/wz_tooltip.js"></script>
<script type="text/javascript" src="/static/vendor/jquery-1.11.3.min.js"></script>
<script type="text/javascript" src="/static/vendor/jquery.blockUI.js"></script>
<!-- <script type="text/javascript" src="/static/vendor/jquery.form.min.js"></script> -->

<if %isAdmin>
<link rel="stylesheet" type="text/css" href="/static/vendor/jquery-ui.min.css" />
<script type="text/javascript" src="/static/vendor/jquery-ui.min.js"></script>
<script type="text/javascript" src="/static/js/admin.js"></script>
</if>

<if $$cfg{ENABLE_HIDE_THREADS} && !$thread>
<script type="text/javascript" src="/static/js/hidethreads.js"></script>
<script type="text/javascript" src="/static/vendor/jquery.cookie.js"></script>
</if>

<if $postform>
<script type="text/javascript">set_inputs("postform")</script></if>
<script type="text/javascript">set_delpass("delform")</script>

<script type="text/javascript">
	var board = "<var $$cfg{SELFPATH}>", thread_id = <if $thread><var $thread></if><if !$thread>null</if>;
	var filetypes = "<var Wakaba::get_filetypes()>";
	var msg_expand_field = "<var $$locale{S_JS_EXPAND}>";
	var msg_shrink_field = "<var $$locale{S_JS_SHRINK}>";
	var msg_remove_file = "<var $$locale{S_JS_REMOVEFILE}>";
	window.onunload = function() {
		if (style_cookie) {
			var title = get_active_stylesheet();
			title = title ? title : get_cookie(style_cookie);
			set_cookie(style_cookie, title, 365);
		}
	};
</script>

<script type="text/javascript">
/* <![CDATA[ */
  $j = jQuery.noConflict();
  $j(document).ready(function() {
   <if $postform>
	var match;
	if ((match = /#i([0-9]+)/.exec(document.location.toString())) && !document.forms.postform.nya4.value) insert(">>" + match[1] + "\n");
	if ((match = /#([0-9]+)/.exec(document.location.toString()))) highlight(match[1]);
	$j("#postform_submit").click(function() {
		$j(".postarea").block({
			message: "Please wait&hellip;",
			css: { fontSize: "2em", color: "#000000", background: "#D7CFC0", border: "1px solid #BFB5A1" },
		});
		setTimeout($j.unblockUI, 5000);
    });
	<if $thread>
		$j("#delform").delegate("span.reflink a", "click", function (ev) {
			var a = ev.target,
			sel = window.getSelection().toString();
			ev.preventDefault();
			insert(">>" + a.href.match(/#i(\d+)$/)[1] + "\n" + (sel ? ">" + sel.replace(/\n/g, "\n>") + "\n" : ""));
		});
	</if>
   </if>
	<if $$cfg{ENABLE_HIDE_THREADS} && !$thread>hideThreads("<var $$cfg{SELFPATH}>", $j);</if>
  });
/* ]]> */
</script>

<script type="text/javascript" src="/static/js/context.js"></script>

</body>
</html>