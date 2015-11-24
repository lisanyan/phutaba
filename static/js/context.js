function highlight() {
  // dummy
  // to be here until the board doesn't hardcode it into posts anymore
}

// WARNING!! Shitty code!
(function(){

/* --- DEFAULTS --- */
var lang = window.board_locale;
var refMap = [], postByNum = [];
var error = false, newPosts = 0, isWindowFocused = true,
	origFileInput, UpdaterTimer;
var title = document.title;

/* -- TRANSLATIONS -- */
var consts = {
  en: {
	dollchanNotify: "If you have dollscript installed:<br> To make it work correctly please check \"Отключить все\" in options",
	done: "Success",
	error: "Error: ",
	loading: "Loading...",
	newPostsNotFound: "No new messages found.",
	newPostsFound: "New messages: ",
	pNotFound: "Post not found",
	replies: "Replies: ",
	replyTo: "Reply to ",
	updthr: "Update thread",
	update_error: "Error updating thread, try again.",
	// Options
	_turnOffAll: 'Turn off all',
	_addAjaxPost: 'Post without reloading',
	_getNewPosts: 'Autoload new posts',
	_moveForm: 'Move post form to the bottom',
	_quickReply: 'Quick reply',
	_openSpoiler: 'Expand spoilers',
	_mamkaInTheRoom: 'Mommy in room',
	_hideName: 'Hide names',
	_hideBoardInfo: 'Hide rules',
	_addRefLinkMap: 'Apply refmap to posts',
	_addPreview: 'Post previews',
	// Titles
	tmp_global: 'Global',
	tmp_posts: 'Posts',
	tmp_css: 'CSS',
	tmp_form: 'Form'
  },
  ru: {
	dollchanNotify: "Если у вас установлен куклоскрипт:<br>Для корректной работы зайдите в опции и поставьте чек на \"Отключить все\"",
	done: "Готово!",
	error: "Ошибка: ",
	loading: "\u0417агрузка...",
	newPostsFound: "Новых постов: ",
	newPostsNotFound: "Нет новых постов.",
	pNotFound: "Пост не найден",
	replies: "Ответы: ",
	replyTo: "Ответ на ",
	update_error: "Ошибка обновления, попробуйте еще раз.",
	updthr: "Обновить тред",
	// Options
	_turnOffAll: 'Отключить все',
	_addAjaxPost: 'Постинг без перезагрузки',
	_getNewPosts: 'Подгрузка постов',
	_moveForm: 'Форма внизу',
	_quickReply: 'Быстрый ответ',
	_openSpoiler: 'Раскрывать спойлеры',
	_mamkaInTheRoom: 'Мамка в комнате',
	_hideName: 'Скрывать имена',
	_hideBoardInfo: 'Скрывать правила',
	_addRefLinkMap: 'Карта ответов',
	_addPreview: 'Превью постов',
	// Titles
	tmp_global: 'Глобальные',
	tmp_posts: 'Посты',
	tmp_css: 'CSS',
	tmp_form: 'Форма'
  }
}

if(typeof consts[lang] == 'undefined') { lang = 'en'; }
else { lang = window.board_locale }

/* -- UPDATER BUTTON -- */
var updater_html = '[<img src="/img/reload.png" alt="" /> '
					+ '<a href="#" id="updater_href"><span>'+consts[lang].updthr+'</span></a>]';

/* -- DEFAULT CONFIG -- */
var defCfg = {
	turnOffAll:     {name: consts[lang]._turnOffAll, value: 0, section: 'global'},
	addAjaxPost:    {name: consts[lang]._addAjaxPost, value: 1, section: 'form'},
	getNewPosts:    {name: consts[lang]._getNewPosts, value: 1, section: 'form'},
	moveForm:       {name: consts[lang]._moveForm, value: 1, section: 'form'},
	quickReply:     {name: consts[lang]._quickReply, value: 1, section: 'form'},
	openSpoiler:    {name: consts[lang]._openSpoiler, value: 0, section: 'css'},
	mamkaInTheRoom: {name: consts[lang]._mamkaInTheRoom, value: 0, section: 'css'},
	hideName:       {name: consts[lang]._hideName, value: 0, section: 'css'},
	hideBoardInfo:  {name: consts[lang]._hideBoardInfo, value: 0, section: 'css'},
	addRefLinkMap:  {name: consts[lang]._addRefLinkMap, value: 1, section: 'post'},
	addPreview:     {name: consts[lang]._addPreview, value: 1, section: 'post'}
}

/* -- >>REFLINKS MAP IN POSTS -- */
function addRefLinkMap(post) {
	var sparde = post || '.thread_OP, div[class="thread_reply"]';
	$j(sparde).each(function(){
		//get id
		var p_num = $j(this).attr('id');
		postByNum[p_num] = $j(this);
	});

	$j('.text', sparde).each(function(){
		var $ref = $j(this);
		if($ref.find('.backreflink a').text().indexOf('>>') == 0) {
			$ref.find('.backreflink a').each(function() {
				var r_num = $j(this).text().match(/\d+/);
				if(postByNum[r_num]) {
				  getRefMap($ref.parent().parent().parent().find('.reflink a').text().match(/\d+/), r_num);
				}
			});
		}
	});

	for(var rNum in refMap)
		showRefMap(postByNum[rNum], rNum, Boolean(post));
}

function getRefMap(pNum, rNum)
{
	if(!refMap[rNum]) refMap[rNum] = [];

	if((',' + refMap[rNum].toString() + ',').indexOf(',' + pNum + ',') < 0)
		refMap[rNum].push(pNum);
}

function showRefMap(post, p_num, isUpd) {
	if(typeof refMap[p_num] !== 'object' || !post) return;

	var data = consts[lang].replies + refMap[p_num].toString().replace(/(\d+)/g, ' <span class="backreflink"><a href="#$1">>>$1</a></span>');
	var map_b = isUpd ? document.getElementById('kotek_refmap_' + p_num) : null;

	if(!map_b) {
		map_b = $j('<div class="kotek_refmap" id="kotek_refmap_'+p_num+'">'+data+'</div>');
		$j('.post_body .text', $j(post).find('.post')).append(map_b);
	}
	else {
		$j(map_b).html(data);
	}
}

/* -- >>REFLINKS PREVIEW -- */
function addPreview(a) {
	var sparde = a || ".thread .text";
	$j(sparde).find(".backreflink a").each(function(){
		$j(this).mouseover(showPostPreview).mouseout(delPreview);
	})
};

function delPreview(e) {
	var pView, el = $j(e.relatedTarget).closest('div[id^="pstprev"]');
	if(el.length) pView = el[0];
	if(!pView)
		$j('div[id^="pstprev"]').remove();
	else {
		while(pView.nextSibling) pView.nextSibling.parentNode.removeChild(pView.nextSibling)
		$j(pView).closest('a').unbind('mouseout');
	}
}

function showPostPreview(e)
{
	var ref  = e.target;
	var pNum = $j(this).text().match(/\d+/);
	var brd = $j(this)[0].toString().split('/')[3] || window.board;
	var scrW = document.body.clientWidth, scrH = window.innerHeight;
	x = $offset(ref, 'offsetLeft') + ref.offsetWidth/2;
	y = $offset(ref, 'offsetTop');

	if(e.clientY < scrH*0.75) y += ref.offsetHeight - 10;

	cln = $new('div',
		{
			'id': 'pstprev_' + pNum,
			'class': 'thread_reply post_preview',
			'style':
			( (x < scrW/2 ? 'left:' + x : 'right:' + parseInt(scrW - x + 2)) + 'px; '
			+ (e.clientY < scrH*0.75 ? 'top:' + y : 'bottom:' + parseInt(scrH - y - 10)) + 'px')
		}
	);

	var mkPreview = function(cln, html) {
		cln.innerHTML = html;
		addPreview(cln);
	};

	cln.innerHTML = consts[lang].loading;

	//если пост найден в дереве.
	if($j('div[id='+pNum+']').length > 0 && brd == window.board) {
		var postdata = $j('div[id='+pNum+']').html();
		mkPreview(cln, postdata);
	}
	//ajax api
	else {
	  $j.ajax('/wakaba.pl?task=show&post='+pNum+'&section='+brd, {async:true})
		.success(function(data) {
			var postdata = $j(data).html();
			mkPreview(cln, postdata);

		})//if error
		.error(function() {
			cln.innerHTML = consts[lang].pNotFound;
		});
	}
	$j('#'+cln.id).remove();
	$j(cln).unbind('mouseout').mouseout(delPreview);
	$j('#appendix').append(cln);
}

/* -- AJAX POSTFORM -- */
function addAjaxPost() {
	if(!window.thread_id) return;
	// fix up form
	var postform = $j('#postform');
	$j('#postform').append('<input type="hidden" name="ajax" id="ajax" value="1">'); //TODO: добавить в форму
	$j('#trgetback', postform).css('display', 'none');

	// submit callback
	$j('#postform_submit').click(function() {
		var options = {
			async: true,
			url: '/wakaba.pl',
			success: function(data) {
				if(!data.error && data.num) {
					showMessage(consts[lang].done, 'click', 0);

					// clear inputs
					var inputs = $j('input[type="text"],input[type="password"],textarea',postform);
					$j('#fileInput').html(origFileInput);
					inputs.clearFields();
					set_inputs('postform');

					// update thread
					if(ExtSettings.get('getNewPosts') > 0)
						loadNewPosts();
					// close quick reply form if open
					if($j('#open_form').is(":visible") && ExtSettings.get('quickReply') > 0)
						$j('#open_form').trigger('click');
				}
				else {
					showError(consts[lang].error+data.error); // show error on fail
				}
				// remove "Please wait" message and unlock form
				$j('.postarea').unblock();
			},
			error: function() { // unlock form and show error
				$j('.postarea').unblock();
				showError();
			}
		};
		error = false; // reset error
		postform.ajaxSubmit(options); // send post

		return false;
	});
}

/*-- THREAD UPDATER --*/
function defTitle() {
	$j('title').text(title);
	setTimeout(function(){
		$j('.post_new').removeClass('post_new');
	}, 1500);
}

function getNewPosts() {
	if(window.thread_id !== null) {
		$j('#updater').html(updater_html);
		$j('#updater').css('display','inline').find('a').click(loadNewPosts);
		UpdaterTimer = setInterval(loadNewPosts, 45000);
	}
}

function loadNewPosts() {
	// get last post id
	var aft = $j('.thread_OP, div[class="thread_reply"]', '#delform').last().attr('id');
	var restoreButton = function () {
		$j('#updater').html(updater_html)
		$j('#updater').find('a').unbind('click').click(loadNewPosts);
	}
	$j('#updater').html('[<img src="/img/loading.gif" alt=""> '+consts[lang].loading+']');
	// stop timer
	clearInterval(UpdaterTimer);
	// reset error
	error = false;

	$j.ajax('/wakaba.pl?section='+window.board+'&task=show&thread='+window.thread_id+'&after='+aft,
	  {async:true} )
		.done(function(data) {
			if(!data.error_code) {
				var postdata = $j(data).filter('*');
				newPosts += postdata.length;
				postdata.each(function(){
					// add reflink map to post
					if (ExtSettings.get('addRefLinkMap') > 0)
						addRefLinkMap([this]);
					// add previews to backreflinks
					if (ExtSettings.get('addPreview') > 0) {
						addPreview([this]);
						addPreview('.kotek_refmap');
					}
					// add quick reply trigger
					if(ExtSettings.get('quickReply') > 0)
						quickReply([this]);
					// finally, apply new post to thread
					$j('.thread').append($j(this).hide().fadeIn("normal"));
				});
				if (newPosts > 0 ) {
					// show new posts count and reset title
					if ( !isWindowFocused )
						$j('title').text('['+newPosts+'] ' + title);
					if ( isWindowFocused ) {
						showMessage(consts[lang].newPostsFound+newPosts);
						newPosts = 0;
						defTitle();
					}
				}
			}
			else {
				if(isWindowFocused && data.error_code==400) {
					// show notification if no new posts found
					showMessage(consts[lang].newPostsNotFound);
				}
			}
			// restart timer and revert back button
			restoreButton();
			UpdaterTimer = setInterval(loadNewPosts, 45000);
		})
		.fail(function(){
			restoreButton(); // revert back button
			showError(); // show error on fail
		});

		return false;
}

function showError(message) {
	error = message || consts[lang].update_error;
	showMessage(error, !isWindowFocused);
	$j('title').text('[Error] '+title);
	if(isWindowFocused) {
		defTitle();
		error = false;
	}
}

function titleNewPosts() {
  $j(window).on("blur focus", function(e) {
	var prevType = $j(this).data("prevType");
	if (prevType != e.type) {   //  reduce double fire issues
		switch (e.type) {
			case "blur":
				isWindowFocused = false;
				break;
			case "focus":
				isWindowFocused = true;
				if(newPosts>0 && !error){
					showMessage(consts[lang].newPostsFound+newPosts);
					newPosts = 0;
				}
				if(error) {
 					showMessage(error, 'click');
					error = false; // reset error
				}
				defTitle();
				break;
		}
	}
	$j(this).data("prevType", e.type);
  })
}

/* -- POST FORM -- */
function openForm(thread_id, form, origSubmit) {
	var parent = $j('input[name="parent"]');
	//open form btn
	$j('#open_form').slideDown(400);
	//open form click
	$j('#open_form').click(function(){
		$j('#open_form').slideUp(400).after(form.removeClass('thread_reply'));
		if (window.thread_id !== null) {
			parent.val(thread_id);
		}
		else {
			parent.val(0);
			$j('#postform_submit').val(origSubmit);
		}
	});
}

function quickReply(post) {
	post = post || document;
	$j('.reflink', post).click(function(e) {
		var form = $j('#postform').parent();
		if (!form.length) return;
		var parent = $j('input[name="parent"]');
		var origSubmit = $j('#postform_submit', form).val();

		var ref = $j(this);
		//ugly, use parents
		ref.parent().parent().parent().after(
			form.addClass('thread_reply')
		);

		var _thread_id = ref.closest('.thread').children(":first").attr('id');
		var post_id = ref.children(":first").text().match(/\d+/);
		$j('#postform_submit').val(consts[lang].replyTo+'/'+window.board+'/'+_thread_id);

		insert('>>'+post_id+'\n');

		if(parent.length < 1) {
			$j('#postform').prepend('<input type="hidden" name="parent" id="parent" value="">');
		}
		form.find('input[name="parent"]').val(_thread_id);

		if ($j('#open_form').is(":hidden")) {
			openForm(_thread_id, form, origSubmit);
		}
		return false;
	});
};

/* -- SCRIPT CSS -- */
function scriptCSS() {
	var x = [];

	if(ExtSettings.get('mamkaInTheRoom') > 0) {
		x.push('.filelink img{opacity: 0.02;} .filelink img:hover{opacity: 1;}');
	}
	if(ExtSettings.get('hideName') > 0) {
		x.push('.post label .postername{display:none !important;}');
	}
	if(ExtSettings.get('hideBoardInfo') > 0) {
		x.push('div.rules{display:none !important;}');
	}
	if(ExtSettings.get('openSpoiler') > 0) {
		x.push('.spoiler{color:inherit !important;}');
	}

	if(!$j('#kotek_css').length)
		$j('<style id="kotek_css" type="text/css">'+x.join('\n')+'</style>').appendTo('head');
	else $j('#kotek_css').text(x.join('\n'));
}

/* -- "NOTIFICATIONS" -- */
function showMessage(text, opt, delay) {
	var message = $j('#message');

	if (delay == null) delay = 1200;
	if (message.get() == '') {
		$j('.content').children().last().after('<div id="message" class="post"></div>');
		message = $j('#message');
		var left = ($j(window).width() - message.outerWidth()) / 2;
		message.css({left: (left > 0 ? left : 0)+'px'}).hide();
	}

	message.html("<span class=\"postername\">" + (opt ? '[<a href=\"#\">X</a>] ' : '') + text + "</span>");
	message.fadeIn(150);

	if (opt) { message.find('a').unbind('click').click(function(){message.fadeOut(300); return false}); }
	else { message.delay(delay).fadeOut(300); }
}

/* -- "MOMMY IN ROOM" IMAGE HIDER -- */
function toggleMommy() {
	mommy = ExtSettings.get('mommy');
	ExtSettings.set('mommy', (mommy || 0) == 0 ? 1 : 0);
	scriptCSS();
	return false;
}

/* -- JS SETTINGS -- */
function configItemTmp() {
	var post = '', css = '', form = '', global = '';
	for(var i in defCfg) {
		var item  = defCfg[i];
		var lb = '<label><input name="'+i+'" type="checkbox">  '+item.name+'</label><br />';

		if(item.section == 'post') post += lb;
		if(item.section == 'form') form += lb;
		if(item.section == 'css') css += lb;
		if(item.section == 'global') global += lb;
	}

	return tmp =
		'<div class="overlay-ext-sect"><div class="title">'+consts[lang].tmp_global+'</div><div class="info">'+global+'</div></div>' +
		'<div class="overlay-ext-sect"><div class="title">'+consts[lang].tmp_posts+'</div><div class="info">'+post+'</div></div>' +
		'<div class="overlay-ext-sect"><div class="title">'+consts[lang].tmp_form+'</div><div class="info">'+form+'</div></div>' +
		'<div class="overlay-ext-sect"><div class="title">'+consts[lang].tmp_css+'</div><div class="info">'+css+'</div></div>';
}

function moveForm() {
	var spadre = $j('#postform');
	if (spadre.length && window.thread_id) {
		pa2 = '#postarea2';
		spadre.detach().appendTo(pa2);
		$j('<p>').css({'clear':'both'}).insertBefore(pa2);
		$j('#postform_hr, #open_form').detach().insertBefore(pa2);
	}
}

function setOptions(i) {
	if(ExtSettings.get(i) > 0) {
		//set checkbox
		$j("input[name="+i+"]").attr("checked",true);
	}
	$j("input[name="+i+"]").change(function() {
		if(ExtSettings.get(i) == 1) {
			ExtSettings.set(i, 0);
			$j(this).attr('checked', false);

		} else {
			ExtSettings.set(i, 1);
			$j(this).attr("checked","checked");
		}
		showMessage(consts[lang].done, null, 200);
	});
}

function toggleNavMenu(node) {
	if ($j('#overlay').is(':visible')) {
		$j('#overlay').hide();
	} else {
		$j('#overlay').css('display', 'block');
	}
}

function turnOffAll() {
	for(var i in defCfg) {
		if(i != 'turnOffAll') {
			if(ExtSettings.get(i) > 0)
				ExtSettings.set(i, 0);
			$j("input[name="+i+"]").attr("checked",false);
			$j("input[name="+i+"]").attr("disabled",true);
		}
	}
}

// Main load function.
var slowload = function() {
	var postbackups = $j('input[value="restorebackups"]');
	$j('.content').append($j('<div>', {id:'appendix'}));
	$j('#settingsConfig').append(configItemTmp());
	$j('#navmenu0, #navmenu1').click(toggleNavMenu);

	if(Settings.get('deNotified') < 1) {
		showMessage(consts[lang].dollchanNotify, 'click');
		Settings.set('deNotified', 1);
	}

	//gen menu and run func
	for(var i in defCfg) {
		//set default value
		if(ExtSettings.get(i) == undefined) {
			ExtSettings.set(i, defCfg[i].value);
		}
		//change option
		setOptions(i);
		//run func
		if(ExtSettings.get(i) > 0 && postbackups.length < 1) {
			if(defCfg[i].section != 'css') {
				eval(i)();
			}
		}
	}

	if(ExtSettings.get('turnOffAll') < 1) {
		origFileInput = $j('#fileInput').html();
		titleNewPosts();
		scriptCSS();
	}
}

$j(document).ready(slowload);

// end scope
})();
