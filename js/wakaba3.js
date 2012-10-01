var fileUploadCounter = 0,
	MAX_FILES_PER_POST = 4,
	resized;

function get_cookie(name) {
	with (document.cookie) {
		var regexp = new RegExp("(^|;\\s+)" + name + "=(.*?)(;|$)"),
		hit = regexp.exec(document.cookie);
		if (hit && hit.length > 2) return unescape(hit[2]);
		else
		return '';
	}
}

function set_cookie(name, value, days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
		var expires = "; expires=" + date.toGMTString();
	} else expires = "";
	document.cookie = name + "=" + value + expires + "; path=/";
}



function get_password(name) {
	var pass = get_cookie(name);
	if (pass) return pass;

	var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	pass = '';

	for (var i = 0; i < 8; i++) {
		var rnd = Math.floor(Math.random() * chars.length);
		pass += chars.substring(rnd, rnd + 1);
	}

	return (pass);
}

function resizeCommentfield(id, srcelement) {
	var textarea = document.getElementById(id);

	if (resized == 1) {
		textarea.cols = 48;
		textarea.rows = 6;
		srcelement.src = '/img/expand.png';
		srcelement.title = 'Textfeld vergrößern';
		resized = 0;
	} else {
		resized = 1;
		textarea.cols = 90;
		textarea.rows = 10;
		srcelement.src = '/img/collapse.png';
		srcelement.title = 'Textfeld verkleinern';
	}

}

function addFileUploadBox(srcelement) {
	fileUploadCounter++;
	var postTableBody = document.getElementById("postTableBody"),
	passwordField = document.getElementById("passwordField"),
	targetBackField = document.getElementById("trgetback"),
	div = document.createElement("div"),
	input = document.createElement("input");
	if (fileUploadCounter >= MAX_FILES_PER_POST) return;
	input.name = "file" + fileUploadCounter;
	input.id = "";
	input.size = 35;
	input.type = "file";
	input.onchange = function () {
		addFileUploadBox(srcelement);
	};
	input.value = "";
	div.appendChild(input);
	document.getElementById("fileInput").appendChild(div);
}

function insert(text) {
	var textarea = document.forms.postform.field4;
	if (textarea) {
		if (textarea.createTextRange && textarea.caretPos) { // IE
			var caretPos = textarea.caretPos;
			caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == " " ? text + " " : text;
		} else if (textarea.setSelectionRange) { // Firefox
			var start = textarea.selectionStart,
			end = textarea.selectionEnd;
			textarea.value = textarea.value.substr(0, start) + text + textarea.value.substr(end);
			textarea.setSelectionRange(start + text.length, start + text.length);
		} else {
			textarea.value += text + " ";
		}
		textarea.focus();
	}
}

function highlight(post) {
	var cells = document.getElementsByTagName("td");
	for (var i = 0; i < cells.length; i++) if (cells[i].className == "highlight") cells[i].className = "reply";

	var reply = document.getElementById("reply" + post);
	if (reply) {
		reply.className = "highlight";
/*		var match=/^([^#]*)/.exec(document.location.toString());
		document.location=match[1]+"#"+post;*/
		return false;
	}

	return true;
}

function set_inputs(id) {
	with (document.getElementById(id)) {
		if (!name.value) name.value = get_cookie("name");
		if (!field2.value) field2.value = get_cookie("email");
		if (!password.value) password.value = get_password("password");
		gb2[1].checked = (get_cookie("gb2")=="thread");
	}
}

function set_delpass(id) {
	with (document.getElementById(id)) password.value = get_cookie("password");
}

window.onunload = function (e) {
	if (style_cookie) {
		var title = get_active_stylesheet();
		set_cookie(style_cookie, title, 365);
	}
}

