var resized;

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
		srcelement.src = '/img/icons/expand.png';
		srcelement.title = msg_expand_field;
		resized = 0;
	} else {
		resized = 1;
		textarea.cols = 90;
		textarea.rows = 10;
		srcelement.src = '/img/icons/collapse.png';
		srcelement.title = msg_shrink_field;
	}

}

function file_input_change(max) {
	var total = 0; // total number of file inputs
	var empty = 0; // number of empty file inputs

	var postfiles = document.getElementById("fileInput"); // table cell id that contains the file inputs and filename spans
	var inputs = postfiles.getElementsByTagName("input"); // the actual file inputs

	for (i = 0; i < inputs.length; i++) {
		if (inputs[i].type != 'file') continue;

		total++;

		// no file selected
		if (inputs[i].value.length == 0) {
			empty++;
		} else {
			if (typeof inputs[i].files == "object" && inputs[i].files.length > 1) total += inputs[i].files.length - 1;
			inputs[i].style.display = "none";
		}
		update_file_label(inputs[i], max);
	}

	// if there are less than "max" file inputs AND none of them is empty: add a new file input
	if (total < max && empty == 0) {
		var div = document.createElement("div");
		var input = document.createElement("input");

		input.type = "file";
		input.name = "file";
		input.onchange = function() {
			file_input_change(max)
		}

		div.appendChild(input);
		postfiles.appendChild(div);
	}
}

function update_file_label(fileinput, max) {
	// find a <span> next to the file input
	var el = fileinput.nextSibling;
	var found = false;
	var span;

	while (el && !found) {
		if (el.nodeName == "SPAN") {
			found = true;
			span = el;
		}
		el = el.nextSibling;
	}

	// add a new <span> to the dom if none was found
	if (!found) {
		var spacer = document.createTextNode("\n ");
		span = document.createElement("span");
		fileinput.parentNode.appendChild(spacer);
		fileinput.parentNode.appendChild(span);
	}

	// put file name(s) into span
	var filename = fileinput.value;

	if (filename.length == 0) {
		span.innerHTML = '';
		return;
	}

	var display_file = format_filename(filename);

	if (typeof fileinput.files == "object" && fileinput.files.length > 1) {
		for (var i = 1, l = fileinput.files.length; i < l; i++) {
			display_file += ' <br />\n&nbsp; ' + format_filename(fileinput.files[i].name);
		}
	}

	span.innerHTML = ' <a class="hide" href="javascript:void(0)" onclick="del_file_input(this,' + max + ')">'
		+ '<img src="/img/icons/cancel.png" width="16" height="16" title="' + msg_remove_file + '" /></a> '
		+ display_file + '\n';
}

function format_filename(filename) {
	var filebase = "";  // file name with dot but without extension
	var extension = ""; // file extension without dot

	// remove path (if any)
	var lastIndex = filename.lastIndexOf("\\");
	if (lastIndex >= 0) {
		filename = filename.substring(lastIndex + 1);
	}

	// get file base name and file extension
	filebase = filename;
	extension = "";
	lastIndex = filename.lastIndexOf(".");
	if (lastIndex >= 0) {
		filebase = filename.substring(0, lastIndex + 1);
		extension = filename.substring(lastIndex + 1);
	}

	var result = filebase;
	if (filetype_allowed(extension)) {
		result += extension;
	} else {
		result += '<span class="sage">' + extension + '</span>';
	}

	return result;
}

function filetype_allowed(ext) {
	var extensions = filetypes.split(", ");
	for (var i = 0, l = extensions.length; i < l; i++) {
		if (extensions[i] == ext.toUpperCase()) return true;
	}
	return false;
}

function del_file_input(sender, max) {
	// <a>   <span>     <div>      <td>                  <a>    <span>    <div>
	sender.parentNode.parentNode.parentNode.removeChild(sender.parentNode.parentNode);
	file_input_change(max);
}

function insert(text) {
	if (typeof document.forms.postform != "object") return;
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

function expand_post(id) {
	var abbr = document.getElementById("posttext_" + id);
	var full = document.getElementById("posttext_full_" + id);
	abbr.innerHTML = full.innerHTML;
	return false;
}

// http://stackoverflow.com/a/7557433/5628
function isElementInViewport(el) {
	var rect = el.getBoundingClientRect();
	return (rect.top >= 0 && rect.left >= 0);
}

function expand_image(element, org_width, org_height, thumb_width, thumb_height, thumb) {
	var img = element;
	var org = img.parentNode.href;
	var post = img.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;

	if (img.src != org) {
		img.src = org;
		//img.style.maxWidth = "98%";
		var maxw = (window.innerWidth || document.documentElement.clientWidth) - 100;
		img.width = org_width < maxw ? org_width : maxw;
		img.style.height = "auto";
		//img.width = org_width;
		//img.height = org_height;
	} else {
		img.src = thumb;
		img.width = thumb_width;
		img.height = thumb_height;
		if (!isElementInViewport(post)) post.scrollIntoView();
	}
	UnTip();
	return false;
}

function set_inputs(id) {
	with (document.getElementById(id)) {
		if ((typeof field1 == "object") && (!field1.value)) field1.value = get_cookie("name");
		/* if (!field2.value) field2.value = get_cookie("email"); */
		if (typeof gb2 == "object")	gb2[1].checked = (get_cookie("gb2") == "thread");
		if (!password.value) password.value = get_password("password");

		// preload images for post form
		if (document.images) {
			new Image().src = "/img/icons/collapse.png";
			new Image().src = "/img/icons/cancel.png";
		}		
	}
}

function set_delpass(id) {
	with (document.getElementById(id)) password.value = get_cookie("password");
}

/*
window.onunload = function (e) {
	if (style_cookie) {
		var title = get_active_stylesheet();
		set_cookie(style_cookie, title, 365);
	}
}
*/
