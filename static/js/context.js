function highlight() {
  // dummy
  // to be here until the board doesn't hardcode it into posts anymore
}

// WARNING!! Shitty code!
(function(){

/* --- DEFAULTS --- */
var origBtn, updBtn = $j('#updater');
var error = false,
	isWindowFocused = true,
	newPosts = 0,
	UpdaterTimer, old_title, origFileInput;

var _selector = '.thread_OP, div[class="thread_reply"]'; //post
var refMap = [], postByNum = [];

var lang = 'ru';
var consts = {
  en: {
	newPostsNotFound: "No new messages found.",
	newPostsFound: "New messages: ",
	pNotFound: "Post not found",
	updthr: "Update thread",
	load: "Loading...",
	replies: "Replies: ",
	reply: "Replying to thread №",
	done: "Success",
	err: "Error updating thread, try again."
  },
  ru: {
	newPostsNotFound: "Нет новых постов.",
	newPostsFound: "Новых постов: ",
	pNotFound: "Пост не найден",
	updthr: "Обновить тред",
	load: "\u0417агрузка...",
	replies: "Ответы: ",
	reply: "Ответ в тред №",
	done: "Готово!",
	err: "Ошибка обновления, попробуйте еще раз."
  }
}
var defCfg = {
	turnOffAll:     {name: 'Отключить все', value: 0, section: 'global'},
	addAjaxPost:    {name: 'Постинг без перезагрузки', value: 1, section: 'form'},
	getNewPosts:    {name: 'Подгрузка постов', value: 1, section: 'form'},
	moveForm:       {name: 'Форма внизу', value: 1, section: 'form'},
	quickReply:     {name: 'Быстрый ответ', value: 1, section: 'form'},
	openSpoiler:    {name: 'Раскрывать спойлеры', value: 0, section: 'css'},
	mamkaInTheRoom: {name: 'Мамка в комнате', value: 0, section: 'css'},
	hideName:       {name: 'Скрывать имена', value: 0, section: 'css'},
	hideBoardInfo:  {name: 'Скрывать правила', value: 0, section: 'css'},
	addRefLinkMap:  {name: 'Карта ответов', value: 1, section: 'post'},
	addPreview:     {name: 'Превью постов', value: 1, section: 'post'}
}

/*--- >>REFLINKS MAP IN POSTS ---*/
function addRefLinkMap(node) {
	var sparde = node || _selector;
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
		showRefMap(postByNum[rNum], rNum, Boolean(node));
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
	var map_b = isUpd ? $id("pidarok_refmap_"+p_num) : null;

	if(!map_b) {
		map_b = $j('<div class="pidarok_refmap" id="pidarok_refmap_'+p_num+'">'+data+'</div>');
		$j('.post_body .text', $j(post).find('.post')).append(map_b);
	}
	else {
		$j(map_b).html(data);
	}
}

/*--- >>REFLINKS PREVIEW ---*/
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
		},
		{/* nothing */}
	);

	var mkPreview = function(cln, html) {
		cln.innerHTML = html;
		addPreview(cln);
	};

	cln.innerHTML = consts[lang].load;

	//если пост найден в дереве.
	if($j('div[id='+pNum+']').length > 0) {
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
	$del($id(cln.id));
	$j(cln).unbind('mouseout').mouseout(delPreview);
	$j('#appendix').append(cln);
}

function delPreview(e) {
	var pView, el = $j(e.relatedTarget).closest('div[id^="pstprev"]');
	if(el.length) pView = el[0];
	if(!pView)
		$j('div[id^="pstprev"]').remove();
	else {
		while(pView.nextSibling) $del(pView.nextSibling)
		$j(pView).closest('a').unbind('mouseout');
	}
}
function addPreview(a) {
	var sparde = a || ".thread .text";
	$j(sparde).find(".backreflink a").each(function(){
		$event(this, { mouseover:showPostPreview, mouseout:delPreview })
	})};

/*--- AJAX ---*/
function addAjaxPost() {
	if(!window.thread_id) return;
	//form fix
	var postform = $j('#postform');
	$j('#postform').append('<input type="hidden" name="ajax" id="ajax" value="1">'); //TODO: добавить в форму
	//send
	$j('#trgetback', postform).css('display', 'none');
	$j('#postform_submit').click(function() {
		var options = {
			async: true,
			url: '/wakaba.pl',
			success: function(data) {
				if(!data.error && data.num) {
					showMessage(consts[lang].done, 200);

					var inputs = $j('input[type="text"],input[type="password"],textarea',postform);
					$j('#fileInput').html(origFileInput);
					inputs.clearFields();
					set_inputs('postform');

					if(ExtSettings.get('getNewPosts') > 0) {
						//get new post
						setTimeout(loadNewPosts, 550);
					}
				}
				else {
					//show errors
					showMessage('Ошибка: '+data.error);
				}
				$j('.postarea').unblock();
			},
			error: function() {
				//bad request
				$j('.postarea').unblock();
				showError();
			}
		};
		//run
		postform.ajaxSubmit(options);

		return false;
	});
}

/*-- Post Updater --*/
function getNewPosts() {
	if(window.thread_id !== null) {
		origBtn = updBtn.html();
		$j(updBtn).css('display','inline').find('a').unbind('click').click(loadNewPosts);
		UpdaterTimer = setInterval(loadNewPosts, 45000);
	}
}

function loadNewPosts() {
	//last post id
	var aft = $j(_selector, '#delform').last().attr('id');
	var restoreButton = function () {
		$j(updBtn).html(origBtn).find('a').unbind('click').click(loadNewPosts);
	}
	clearInterval(UpdaterTimer);
	$j(updBtn).html('['+consts[lang].load+']');

	$j.ajax('/wakaba.pl?section='+window.board+'&task=show&thread='+window.thread_id+'&after='+aft,
	  {async:true} )
		.done(function(data) {
			if(!data.error_code) {
				var postdata = $j(data).filter('*');
				newPosts += postdata.length;
				postdata.each(function(){
					addRefLinkMap([this]);
					addPreview([this]);
					addPreview($j('.pidarok_refmap'));
					if(ExtSettings.get('quickReply') > 0)
						quickReply([this]);
					$j('.thread').append(
						$j(this).hide().fadeIn("normal")
					);
				});
				if (newPosts > 0 ) {
					if ( !isWindowFocused )
						$j('title').text('['+newPosts+'] ' + old_title);
					if ( isWindowFocused ) {
						showMessage(consts[lang].newPostsFound+newPosts);
						newPosts = 0;
						defTitle();
					}
				}
			}
			else {
				if(isWindowFocused && data.error_code==400) {
					showMessage(consts[lang].newPostsNotFound);
					defTitle();
				}
			}
			UpdaterTimer = setInterval(loadNewPosts, 45000);
			error = false;
			restoreButton();
		})
		.fail(function(){
			restoreButton();
			showError();
		});

		return false;
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
				if(error) {
					showMessage(consts[lang].err);
				}
				if(newPosts>0 && !error){
					showMessage(consts[lang].newPostsFound+newPosts);
					newPosts = 0;
					defTitle();
				}
				break;
		}
	}
	$j(this).data("prevType", e.type);
  })
}

function showError() {
	if ( isWindowFocused )
		showMessage(consts[lang].err);
	$j('title').text('[Error] '+old_title);
	error = true;
}

function defTitle() {
	$j('title').text(old_title);
	setTimeout(function(){
		$j('.post_new').removeClass('post_new');
	}, 1500);
}

/*--- ANALNY KOSTYLI ---*/
function openForm(thread_id, form) {
	//open form btn
	$j('#open_form').slideDown(400);
	//open form click
	$j('#open_form').click(function(){
		$j('#open_form').slideUp(400).after( form.css('margin-left','').removeClass('thread_reply'));
		if (window.thread_id !== null) {
			$j('input[name="parent"]').val(thread_id);
		}
		else {
			$j('input[name="parent"]').val(0);
		}
	});
}

var quickReply = function(post) {
	post = post || document;
    $j('.reflink', post).click(function(e) {
        var form = $j('#postform').parent();
        if (!form.length) return;

        var ref = $j(this);
        //ugly, use parents
        ref.parent().parent().parent().after(
            form.css({'display':'block', 'margin-left': '2em'}).addClass('thread_reply')
        );

        var thread_id = ref.closest('.thread').children(":first").attr('id');
        var post_id = ref.children(":first").text().match(/\d+/);

        insert('>>'+post_id+'\n');

        if($j('input[name="parent"]').length < 1) {
			$j('#postform').prepend('<input type="hidden" name="parent" id="parent" value="">');
        }
        form.find('input[name="parent"]').val(thread_id);

        if ($j('#open_form').is(":hidden")) {
            openForm(thread_id, form);
        }
        return false;
    });
};

/*-- "MOMMY IN ROOM" IMAGE HIDER --*/
function toggleMommy() {
	mommy = ExtSettings.get('mommy');
	ExtSettings.set('mommy', (mommy || 0) == 0 ? 1 : 0);
	scriptCSS();
	return false;
}

/* -- SCRIPT CSS -- */
function scriptCSS() {
	var x = [];

    if(ExtSettings.get('mamkaInTheRoom') > 0) {
        x.push('\n.filelink img{opacity: 0.02;} .filelink img:hover{opacity: 1;}');
    }
    if(ExtSettings.get('hideName') > 0) {
        x.push('\n\t.post label .postername{display:none !important;}');
    }
    if(ExtSettings.get('hideBoardInfo') > 0) {
        x.push('\n\tdiv.rules{display:none !important;}');
    }
    if(ExtSettings.get('openSpoiler') > 0) {
        x.push('\n\t.spoiler{color:inherit !important;}');
    }

	if(!$id('pidarok_css'))
		$t('head')[0].appendChild($new('style', {
			'id': 'pidarok_css',
			'type': 'text/css',
			'text': x.join(' ')
		}));
	else $id('pidarok_css').textContent = x.join(' ');
}

/* -- "Notifications" -- */
function showMessage(text, delay) {
	var message = $j('#message');
	if (delay == null) delay = 1800;
	if (message.get() == '') {
		$j('body').children().last().after('<div id="message" class="post"></div>');
		message = $j('#message');
		// var top = ($j(window).height() - message.outerHeight()) / 2;
		var left = ($j(window).width() - message.outerWidth()) / 2;
		message.css({left: (left > 0 ? left : 0)+'px'});
		message.hide();
	}
	message.html("<span class=\"postername\">" + text + "</span>");
	message.fadeIn(150).delay(delay).fadeOut(300);
}

/* -- js settings -- */
function moveForm() {
	var spadre = $j('#postform');
	if (spadre.length && window.thread_id) {
		pa2 = '#postarea2';
		spadre.detach().appendTo(pa2);
		$j('<p>').css({padding:'1px',clear:'both'}).insertBefore(pa2);
		$j('#open_form').detach().insertBefore(pa2);
		$j('.postarea').prev('hr').detach().insertBefore(pa2);
	}
}

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
		'<div class="overlay-ext-sect"><div class="title">Глобальные</div><div class="info">'+global+'</div></div>' +
		'<div class="overlay-ext-sect"><div class="title">Посты</div><div class="info">'+post+'</div></div>' +
		'<div class="overlay-ext-sect"><div class="title">Форма</div><div class="info">'+form+'</div></div>' +
		'<div class="overlay-ext-sect"><div class="title">CSS</div><div class="info">'+css+'</div></div>';
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
		showMessage(consts[lang].done, 300);
	});
}

function toggleNavMenu(node) {
	if ($id("overlay").style.display == 'block') {
		$id("overlay").style.display = "none";
	} else {
		$id("overlay").style.display = "block";
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
	var postbackups = $j('input[name="restorebackups]');
	$j('.content').append($j('<div>', {id:'appendix'}));
	$j('#settingsConfig').append(configItemTmp());
	$j('#navmenu0, #navmenu1').click(toggleNavMenu);

	if(postbackups.length > 0) 
		return;

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
		old_title = document.title;
		origFileInput = $j('#fileInput').html();
		titleNewPosts();
		scriptCSS();
	}
}

$j(document).ready(slowload);

// end scope
})();
