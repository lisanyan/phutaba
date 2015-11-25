// ============================================================================================
// Misc functions
function $offset(a,c){for(var b=0;a;)b+=a[c],a=a.offsetParent;return b}
function $attr(b,c){for(var a in c)"text"==a?b.textContent=c[a]:"value"==a?b.value=c[a]:"html"==a?b.innerHTML=c[a]:b.setAttribute(a,c[a]);return b};
function $new(a,c,b){a=document.createElement(a);c&&$attr(a,c);return a};

// ============================================================================================
// Wakaba legacy

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

function set_inputs(id) {
	with (document.getElementById(id)) {
		if (typeof nya1 == "object" && !nya1.value) nya1.value = get_cookie("name");
		/* if (!nya2.value) nya2.value = get_cookie("email"); */
		if (typeof gb2 == "object")	gb2[1].checked = (get_cookie("gb2") == "thread");
		if (typeof no_pomf == "object") no_pomf.checked = (get_cookie("nopomf") == "on");
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

// ============================================================================================
// Inputs and crap

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
		input.className = "externalInput";
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
	if (typeof document.forms.postform == 'undefined') return false;
	var textarea = document.forms.postform.nya4;
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

function update_captcha(el2) {
	var el = el2;
	if (el) {
		var src = e.src;
		src = src.replace(/dummy=\d*/, 'dummy=' + Math.round(Math.random()*1000000));
	}
	return false;
}

function areYouSure(el)
{
	if(confirm('Are you sure?')) document.location = el.href;
	return false;
}

// ============================================================================================
// Post expanding
function expand_post(id) {
	//$j("#posttext_" + id).html($j("#posttext_full_" + id).html());
	var abbr = document.getElementById("posttext_" + id);
	var full = document.getElementById("posttext_full_" + id);
	abbr.innerHTML = full.innerHTML;
	return false;
}

// http://stackoverflow.com/a/7557433/5628
function isElementInViewport(el) {
	var rect = el.getBoundingClientRect();
	return ( rect.top >= 0 && rect.left >= 0 );
}

function expand(el, org_width, org_height, thumb_width, thumb_height, thumb, ext, huj) {
	if (org_height == 0) return;

	var img = ( el.firstElementChild || el.children[0] );
	var org = el.href;
	var parent = el.parentNode;
	var post = img.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode; // lol parentNode hell
	var post2 = img.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;

	if (ext=='WEBM' || ext=='MP4') { // Anal workaround on expanding videos
		var orightml = parent.innerHTML;
		var filetag =  '<a href="' + org + '" class="close-webm">[Close]</a>';
		    filetag += '<div><video controls="" autoplay="" '+ (Settings.get('webmVolume') === 0 ? 'muted ' : '')
					+  'loop="1" name="media"><source src="'+org+'" type="video/'+ext.toLowerCase()+'" class="video"></video></div>';
		if(!huj) {
			parent.innerHTML = filetag;
			var vid = parent.getElementsByTagName('video')[0];
			var clbut = parent.getElementsByClassName('close-webm')[0];
			clbut.addEventListener("click",
				function(e) {
					e.preventDefault ? e.preventDefault() : e.returnValue = false;
					return expand(parent, org_width, org_height, thumb_width, thumb_height, thumb, ext, orightml);
				}
			);
			vid.onvolumechange = function() {
				Settings.set('webmVolume', Math.round(vid.volume * 100));
			}
			if(Settings.get('webmVolume') !== 0) {
				vid.oncanplay = function() {
					vid.volume = Settings.get('webmVolume') / 100;
				};
			}
		} else {
			abortWebmDownload(el);
			el.innerHTML = huj;
			if (!isElementInViewport(post2)) post2.scrollIntoView();
		}
	}
	else {
		if (img.src != org) {
			img.src = org;
			var maxw = (window.innerWidth || document.documentElement.clientWidth) - 100;
			img.width = org_width < maxw ? org_width : maxw;
			img.style.height = "auto";
		} else {
			img.src = thumb;
			img.width = thumb_width;
			img.height = thumb_height;
			if (!isElementInViewport(post)) post.scrollIntoView();
		}
	}
	UnTip();
	return false;
}

function abortWebmDownload(el) {
	el = el.getElementsByTagName('video')[0];
    if(!el) return;

    var video = el;
    video.pause(0);
    video.src = "";
    video.load();
    el.parentNode.removeChild(el);
}

// ============================================================================================
// Stylesheets
function set_stylesheet(styletitle,target)
{
	set_cookie("wakastyle",styletitle,365);

	var links = target ? target.document.getElementsByTagName("link") : document.getElementsByTagName("link");
	var found=false;

	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")>=0&&title)
		{
			links[i].disabled=true; // IE needs this to work. IE needs to die.
			if(styletitle==title) { links[i].disabled=false; found=true; }
			if(styletitle===null) { links[i].disabled=true; found=true}
		}
	}
	if(!found)
	{
		if(target) set_preferred_stylesheet(target);
		else set_preferred_stylesheet();
	}
}

function set_stylesheet_frame(styletitle,framename)
{
	set_stylesheet(styletitle);
	var list = get_frame_by_name(framename);
	if(list) set_stylesheet(styletitle,list);
}

function set_preferred_stylesheet(target)
{
	var links = target ? target.document.getElementsByTagName("link") : document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")>=0&&title) links[i].disabled=(rel.indexOf("alt")>=0);
	}
}

function get_frame_by_name(name)
{
	var frames = window.parent.frames;
	for(i = 0; i < frames.length; i++)
	{
		if(name == frames[i].name) { return(frames[i]); }
	}
}

function get_active_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")>=0&&title&&!links[i].disabled) return title;
	}
	return null;
}

function get_preferred_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")>=0&&rel.indexOf("alt")==-1&&title) return title;
	}
	return null;
}

window.onunload = function() {
	if (style_cookie) {
		var title = get_active_stylesheet();
		set_cookie(style_cookie, title, 365);
	}
};

if(style_cookie)
{
	var cookie=get_cookie(style_cookie);
	var title=cookie?cookie:get_preferred_stylesheet();
	set_stylesheet(title);
}

// ============================================================================================
// TEH END
