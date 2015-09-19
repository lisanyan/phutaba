(function() {

function $X(a,b){return document.evaluate(a,b||document,null,6,null)}
function $x(a,b){return document.evaluate(a,b||document,null,8,null).singleNodeValue}
function $_each(a,b){if(a){var c=a.snapshotLength;if(0<c)for(;c--;)b(a.snapshotItem(c),c)}};
function $del(el){if(el)el.parentNode.removeChild(el);}

function doCheckUpdates() {

		var api_url = "api/posts?";

		var add_btn = function() {
				var dummy = document.createElement('div');
				dummy.innerHTML = '<span class="shortened" id="update_but">? новых постов</span>';
				var span = dummy.firstChild;
				document.body.appendChild(span);
				return span;
		};

		var but = document.getElementById("update_but") || add_btn();
		var bak = but.innerHTML.toString();

		var say = function(str) {
				but.innerHTML = str;
		};

		var unsay = function(timeout) {
				setTimeout(function() {
						but.innerHTML = bak;
				}, timeout || 1000);
		};
		var in_progress = false;
		but.onclick = function() {
				if (!in_progress) {
						in_progress = true;
						check_updates();
				}
				return false;
		};

		var check_updates = function() {
				var json = Settings.get('visited');
				if (json) {
						say('я считаю');
						var visited = JSON.parse(json);
						var pending = 0;
						$_each($X('.//a[@target="main" and starts-with(@href, "/") and substring(@href, 1,2) != "//"]'), function(a) {
								var brd = a.pathname.match(/[^\/]+/);
								if (!visited[brd])
										return;
								pending++; // increment
								say('осталось ' + pending);
								var xhr = new XMLHttpRequest();
								xhr.onreadystatechange = function() {
										if (xhr.readyState != 4)
												return;
										if (xhr.status == 200) {
												var data = JSON.parse(xhr.response);
												if (data.data['new'] > 0) {
														var small = $x('.//small[@id="new_' + brd + '"]', a.parentNode) ||
																		function() {
																				var small = document.createElement('small');
																				small.className = 'filesize';
																				small.id = 'new_' + brd;
																				a.parentNode.insertBefore(small, a.nextSibling);
																				return small;
																		}();
														a.onclick = function() {
																$del(small);
																a.onclick = null;
														};
														small.innerHTML = ' +' + data.data['new'];
												}

												if (pending--, pending > 0)
														say('осталось ' + pending);
										} else {
												say('HTTP ' + xhr.status + ' ' + xhr.statusText);

										}
								};
								xhr.open('GET', a.href + api_url + 'timestamp=' + visited[brd], true);
								xhr.send(false);

						});
				} else {
						say('нет куки');
						unsay();
						return false;
				}

				var timeout = 30 * 1000; // 30 s
				var tick = window.setInterval(function() {
						if (pending === 0) {
								window.clearInterval(tick);
								say('готово');
								unsay();
								in_progress = false;
						}
						if (timeout < 0) {
								window.clearInterval(tick);
								say('ошибка - таймаут');
								unsay();
								in_progress = false;
						}

						timeout -= 100;
				}, 100); // wait threads
		};

		check_updates();
}

var doToggle = function() {
		var toggle = function(node) {
				node.style.display = (node.style.display != 'none' ? 'none' : '');
		};
		var toggleByTag = function(tag) {
				var nodes = document.getElementsByClassName(tag);
				for (var i = 0; i < nodes.length; i += 1) {
						toggle(nodes[i]);
				}
		};

		var hidden = JSON.parse(Settings.get('tags_hidden') || "[]");
		hidden.forEach(toggleByTag);

		var dds = document.getElementsByClassName('header');
		var helper = function(el) {
				el.onclick = function() {
						var tag = el.id;
						var key = hidden.indexOf(tag);
						if (key != -1) { // found
								hidden.splice(key, 1); // del
						} else {
								hidden.push(tag); // add
						}
						toggleByTag(tag);
						Settings.set('tags_hidden', JSON.stringify(hidden));
				};
		};
		for (var i = 0; i < dds.length; i += 1) {
				helper(dds[i]);
		}
};

var doHiddenBoards = function() {
		var pointer;
		var menu = document.getElementById("menu");
		var add_category = function() {
				var dummy = document.createElement('div');
				dummy.innerHTML = '<dt class="header" id="hidden_boards">' + strings['cat_hidden'] + '</dt>';
				var dt = dummy.firstChild;
				var cat_main = menu.getElementsByClassName("header")[1];
				menu.insertBefore(dt, cat_main);

				pointer = document.createElement("div");
				pointer.style.display = "none";
				menu.insertBefore(pointer, cat_main);

		};

		var strings = {
			tst: "Тест",
		};

		var push_hidden = function(key) {
				if (!pointer) add_category();
				var foo = {"test": "tst"};
				var dummy = document.createElement('div');
				dummy.innerHTML = '<dd class="hidden_boards"><a href="/' + key + '/" target="main">' + strings[foo[key]] + '</a></dd>';
				var dd = dummy.firstChild;
				menu.insertBefore(dd, pointer);

		};

		var json = Settings.get('visited');
		if (json) {
				var visited = JSON.parse(json);
				if (visited) {
						for (var k in visited) {
								if (!$x('.//dd/a[@href="/' + k + '/"]')) {
										push_hidden(k);
								}
						}
				}
		}
}

function removeframes() {
	var dildo = function() {
		$_each($X('.//a[@target="main" and starts-with(@href, "/") and substring(@href, 1,2) != "//"]'), function(lnk) { lnk.setAttribute("target", "_top") });
		$id("removeframes").innerHTML = "Готово";
		return false;
	}
	$id('removeframes').addEventListener('click', dildo);
}

document.addEventListener("DOMContentLoaded", function() {
	removeframes();
	doHiddenBoards();
	doToggle();
	// doCheckUpdates();
});

// (c) sky (небо)

})()