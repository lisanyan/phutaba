function highlight() {
  // dummy
  // to be here until the board doesn't hardcode it into posts anymore
}

// WARNING!! Shitty code!
(function(){
var error = false, isWindowFocused = true, newPosts = 0, UpdaterTimer, old_t;
var origBtn, updBtn = $j('#updater');
var perdelki = Settings.get('context');

var _selector = '.thread_OP, .thread_reply'; //post
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
	done: "Изгнание ебсов успешно завершено.",
	err: "Ошибка обновления, попробуйте еще раз."
  }
}

/*------------------------------------------------------------------- >>REFLINKS MAP IN POSTS -------------------------------------------------------------*/

//reflink map
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

/*------------------------------------------------------------------- >>REFLINKS PREVIEW -------------------------------------------------------------*/

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

/*------------------------------------------------------------------- AJAX -------------------------------------------------------------*/

//load new posts
function getNewPosts() {
	if(window.thread_id !== null) {
		origBtn = updBtn.html();
		$j(updBtn).css('display','inline').find('a').click(loadNewPosts);
		UpdaterTimer = setInterval(loadNewPosts, 45000);
	}
}

function loadNewPosts() {
	//last post id
	var aft = $j(_selector, '#delform').last().attr('id');
	var restoreButton = function () {
		$j(updBtn).html(origBtn).find('a').unbind('click').click(loadNewPosts);
	}
	$j(updBtn).html('['+consts[lang].load+']');
	clearInterval(UpdaterTimer);

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
					$j('.thread').append($j(this).hide().fadeIn("normal"));
				});
				if (newPosts > 0 ) {
					if ( !isWindowFocused )
						$j('title').text('['+newPosts+'] ' + old_t);
					if ( isWindowFocused ) {
						showMessage(consts[lang].newPostsFound+newPosts, 1800);
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
			restoreButton();
			error = false;
		})
		.fail(function() {
			if ( isWindowFocused ) {
				showMessage(consts[lang].err, 2500);
			}
			$j('title').text('[Error] '+old_t);
			// console.log('Error.');
			restoreButton();
			error = true;
		});
}

function titleNewPosts() {
  $j(window).on("blur focus", function(e) {
	var prevType = $j(this).data("prevType");
	if (prevType != e.type) {   //  reduce double fire issues
		switch (e.type) {
			case "blur":
				// do work
				isWindowFocused = false;
				break;
			case "focus":
				// do work
				isWindowFocused = true;
				if(error) {
					showMessage(consts[lang].err, 2500);
					// error = false;
				}
				if(newPosts>0){
					showMessage(consts[lang].newPostsFound+newPosts, 1800);
					newPosts = 0;
					defTitle();
				}
				break;
		}
	}
	$j(this).data("prevType", e.type);
  })
}

function defTitle() {
	$j('title').text(old_t);
	setTimeout(function(){
		$j('.post_new').removeClass('post_new');
	}, 1500);
}

/*------------------------------------------------------------------- ANALNY KOSTYLI -------------------------------------------------------------*/
// "MOMMY IN ROOM" IMAGE HIDER
function toggleMommy() {
	Settings.set('mommy', (Settings.get('mommy') || 0) == 0 ? 1 : 0);
	scriptCSS();
	return false;
}

function hotkeyMommy(e) {
	if(!e) e = window.event;
	if(e.altKey && e.keyCode == 78) toggleMommy();
}

// SCRIPT CSS
function scriptCSS() {
	var x = [];
	if(Settings.get('mommy') == 1)
		x.push('img[src*="thumb"] {opacity:0.04 !important} img[src*="thumb"]:hover {opacity:1 !important}');
	if(!$id('pidarok_css'))
		$t('head')[0].appendChild($new('style', {
			'id': 'pidarok_css',
			'type': 'text/css',
			'text': x.join(' ')
		}));
	else $id('pidarok_css').textContent = x.join(' ');
}

// "Notifications"
function showMessage(text, delay) {
	var message = $j('#message');
	if (delay == null) delay = 1000;
	if (message.get() == '') {
		$j('body').children().last().after('<div id="message" class="post"></div>');
		message = $j('#message'); // ugly hack
		message.hide();
	}
	// var top = ($j(window).height() - message.outerHeight()) / 2;
	var left = ($j(window).width() - message.outerWidth()) / 2;
	message.css({left: (left > 0 ? left : 0)+'px'});
	message.html("<span class=\"postername\">" + text + "</span>");
	message.fadeIn(150).delay(delay).fadeOut(300);
}

// Js settings
function toggleNavMenu(node) {
	if ($id("overlay").style.display == 'block') {
		$id("overlay").style.display = "none";
	} else {
		$id("overlay").style.display = "block";
	}
}

function moveForm(spadre) {
	if (spadre.length && window.thread_id) {
		spadre.detach().appendTo('#postform2');
		$j('.postarea').prev('hr').detach().prependTo(spadre.parent());
		$j('<p>').css('padding', '1px').prependTo(spadre.parent());
	}
}

function eventLoader() {
	$j('#navmenu0, #navmenu1').click(toggleNavMenu);
	$j('#tglmommy').click(toggleMommy);

	$j('#tglcontext').click(function(){
		Settings.set('context', +this.checked);
		showMessage(consts[lang].done);
	});

	$j('#tglform').click(function(){
		Settings.set('bottomform', +this.checked);
		showMessage(consts[lang].done);
	});

	$id('tglcontext').checked = Settings.get('context') == 1 ? "checked" : "";
	$id('tglform').checked = Settings.get('bottomform') == 1 ? "checked" : "";
}

// Main load function.
var slowload = function() {
	eventLoader();
	if (Settings.get('context')==1)
	{
		old_t = document.title;
		$j('.content').append($j('<div>', {id:'appendix'}));
		$j(document).keydown(hotkeyMommy);
		scriptCSS();
		if (!$j('input[value="restorebackups"]').length)
		{
			addRefLinkMap();
			addPreview();
			titleNewPosts();
			getNewPosts();
		}
		else
		{
			addPreview();
		}
	}
	if (Settings.get('bottomform') == 1)
		moveForm($j('#postform'));
}

$j(document).ready(slowload);

// end scope
})();
