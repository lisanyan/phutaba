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
		srcelement.title = 'Textfeld vergrößern';
		resized = 0;
	} else {
		resized = 1;
		textarea.cols = 90;
		textarea.rows = 10;
		srcelement.src = '/img/icons/collapse.png';
		srcelement.title = 'Textfeld verkleinern';
	}

}

function file_input_change(max)
{
	var total = 0;     // total number of file inputs
	var empty = 0;     // number of empty file inputs
	var filename = ""; // the filename without path that will be shown in the span

	var postfiles = document.getElementById("fileInput"); // table cell id that contains the file inputs and filename spans
	var inputs = postfiles.getElementsByTagName("input"); // the actual file inputs
	var spans = postfiles.getElementsByTagName("span");   // spans with delete-icon and filename

	for (i = 0; i < inputs.length; i++) {
		if (inputs[i].type != 'file') continue;

		// the initial first file input does not have a span for the filename
		if (spans.length == 0) {
			var spacer = document.createTextNode("\n ");
			var span = document.createElement("span");
			inputs[i].parentNode.appendChild(spacer);
			inputs[i].parentNode.appendChild(span);
		}

		total++;
		filename = inputs[i].value;
		if (filename.length == 0) {
			empty++;
			spans[i].innerHTML = "";
		} else {
			var lastIndex = filename.lastIndexOf("\\");
			if (lastIndex >= 0) {
				filename = filename.substring(lastIndex + 1);
			}
			inputs[i].style.display = "none";
			spans[i].innerHTML = ' <a class="hide" href="javascript:void(0)" onclick="del_file_input(this,' + max + ')">'
				+ '<img src="/img/icons/cancel.png" width="16" height="16" title="Datei entfernen" /></a> ' + filename + '\n';
		}

	}

	// if there are less than "max" file inputs AND none of them is empty: add a new file input with empty span for the filename
	if (total < max && empty == 0) {
		var div = document.createElement("div");
		var input = document.createElement("input");
		var spacer = document.createTextNode("\n ");
		var span = document.createElement("span");

		input.type = "file";
		input.name = "file";
		input.onchange = function() {
			file_input_change(max)
		}

		div.appendChild(input);
		div.appendChild(spacer);
		div.appendChild(span);
		postfiles.appendChild(div);
	}
}

function del_file_input(sender, max) {
	// <a>   <span>     <div>      <td>                  <a>    <span>    <div>
	sender.parentNode.parentNode.parentNode.removeChild(sender.parentNode.parentNode);
	file_input_change(max);
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

function expand_post(id) {
	$j("#posttext_" + id).html($j("#posttext_full_" + id).html());
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
