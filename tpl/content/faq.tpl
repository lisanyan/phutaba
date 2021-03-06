<perleval %title="FAQ"; />
<include %TMPLDIR%/head.tpl>
	<header class="title">Как я могу отформатировать текст?</header>
	<section class="info">
		<p>Доступны <a href="http://ru.wikipedia.org/wiki/BBCode">BBCode</a>-Теги:</p>
		<table>
			<tr>
				<th>Было</th>
				<th>Стало</th>
			</tr>
			<tr>
				<td>[i]курсив[/i]</td>
				<td><em>курсив</em></td>
			</tr>
			<tr>
				<td>[b]жирный[/b]</td>
			 	<td><strong>жирный</strong></td>
			</tr>
			<tr>
				<td>[u]подчеркнутый[/u]</td>
				<td><span class="underline">подчеркнутый</span></td>
			</tr>
			<tr>
				<td>[s]зачеркнутый[/s]</td>
				<td><span class="strike">зачеркнутый</span></td>
			</tr>
			<tr>
				<td>[spoiler]Спойлер[/spoiler]</td>
				<td><span class="spoiler">Сполйер</span></td>
			</tr>
			<tr>
				<td>[code]Code[/code]</td>
				<td><pre>Code</pre></td>
			</tr>
		</table>

		<br /><p>Также доступна разметка WakabaMark:</p>
		<table>
			<tr>
				<th>Было</th>
				<th>Стало</th>
			</tr>
			<tr>
				<td>*курсив*</td>
				<td><em>курсив</em></td>
			</tr>
			<tr>
				<td>**жирный**</td>
			 	<td><strong>жирный</strong></td>
			</tr>
			<tr>
				<td>__подчеркнутый__</td>
				<td><span class="underline">подчеркнутый</span></td>
			</tr>
			<tr>
				<td>^^зачеркнутый^^</td>
				<td><span class="strike">зачеркнутый</span></td>
			</tr>
			<tr>
				<td>%%Спойлер%%
				<br />~~Спойлер~~</td>
				<td><span class="spoiler">Спойлер</span></td>
			</tr>
			<tr>
				<td>`Код`</td>
				<td><pre>Код</pre></td>
			</tr>
		</table>

		<br /><p>Ссылки:</p>
		<table>
			<tr>
				<th>Было</th>
				<th>Стало</th>
			</tr>
			<tr>
				<td>&gt;&gt;NUM</td>
				<td>Ссылка на пост NUM на текущей доске</td>
			</tr>
			<tr>
				<td>&gt;&gt;&gt;/BOARD/NUM</td>
				<td>Ссылка на пост NUM на доске BOARD</td>
			</tr>
		</table>
	</section>

	<header class="title">JSON API</header>
	<section class="info">
	<!-- <p>Some text&hellip;</p> -->
		<table>
			<tr>
				<th>&nbsp;</th>
				<th>&nbsp;</th>
			</tr>
			<tr>
				<td>/board/api/threads</td>
				<td>Возвращает треды с первой страницы доски</td>
			</tr>
			<tr>
				<td>/board/api/threads?page=n</td>
				<td>Возвращает треды с n страницы доски</td>
			</tr>
			<tr>
				<td>/board/api/thread?id=n</td>
				<td>Возвращает треды с номером n</td>
			</tr>
			<tr>
				<td>/board/api/newposts?id=n&amp;after=p</td>
				<td>Возвращает новые посты в треде n после поста p</td>
			</tr>
			<tr>
				<td>/board/api/post?id=n</td>
				<td>Вернет пост n</td>
			</tr>
		</table>

	</section>

	<header class="title">Где я могу взять лого?</header>
	<div class="info">
		<p style="float:left; margin-right:1em">Нажмите здесь:</p>
		<p><a href="/img/logo_gross.png"><img src="/img/logo_klein.png" alt="Phutaba-Logo" /></a></p>
	</div>

	<header class="title">Почему я должен вводить капчу?</header>
	<section class="info">
		Вы должны вводить капчу перед каждым постом, если ваш IP не из: FI EE DE NO CH AT LI BE LU DK NL RU UA BY KZ PL.
	</section>

	<header class="title">Обратная связь</header>
	<section class="info">
		<p>E-mail: <a href="mailto:admin@02ch.in">admin@02ch.in</a></p>
		<p>Skype: <a href="skype:nyan.anon?chat">nyan.anon</a></p>
	</section>


	<header class="title">System info</header>
	<section class="info">
	<p><loop $uptime>Uptime: <var $uptime><br />CPU Idle: <var $idle></loop></p>
	<p><br />Disk space [GB]:</p>
		<table>
			<tr>
				<th>Total</th>
				<th>Used</th>
				<th>Free</th>
			</tr>
			<tr>
				<aloop $diskinfo>
				<td><var $_></td>
				</loop>
			</tr>
		</table>
	</section>

<!-- [Disk space] Total(GB): [% diskinfo.0 %] | Used: [% diskinfo.1 %] | Free: [% diskinfo.2 %] -->
<include %TMPLDIR%/foot.tpl>
