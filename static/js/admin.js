function do_ban(ip, postid, board) {

	function show_info(msg) {
		$j("#infodetails").text(msg);
		$j("#info").show('normal');
	}

	function show_error(msg) {
		$j("#errordetails").text(msg);
		$j("#infobox").hide('normal');
		$j("#info").hide('normal');
		$j("#error").show('normal');
	}

	function hide_all() {
		$j("#infobox").hide('normal');
		$j("#info").hide('normal');
		$j("#error").hide('normal');
	}

	function disable_controls() {
		$j("#ip").attr('disabled', true);
		$j("#netmask").attr('disabled', true);
		$j("#duration").attr('disabled', true);
		$j("#reason").attr('disabled', true);
		$j("#ban_flag").attr('disabled', true);
	}

	buttons = {
		"OK": function () {
			if ($j("#ip").is(':disabled')) {
				hide_all();
				$j(this).dialog('close');
				return;
			}

			ip = $j("#ip").val() ? $j("#ip").val() : ip;
			mask = $j("#netmask").val() ? $j("#netmask").val() : "255.255.255.255";
			duration = $j("#duration").val() ? $j("#duration").val() : "";
			reason = $j("#reason").val() ? $j("#reason").val() : "no reason";
			flag = $j("#ban_flag").prop('checked') ? 1 : 0;
			url = "/wakaba.pl?task=addip&ajax=1&type=ipban&board=" + encodeURIComponent(board) + "&post=" + postid + "&ip=" + ip + "&mask=" + mask + "&comment=" + encodeURIComponent(reason) + "&string=" + duration + "&flag=" + flag;

			$j("#infobox").hide('normal');
			$j("#error").hide('normal');
			show_info("Ausführen ...");

			$j.ajax({
				url: url,
				dataType: 'json',
				success: function (data) {
					if (data['error_code'] == 200) {
						disable_controls();
						$j("#error").hide('normal');
						$j("span#r_ip").html(data['banned_ip']);
						$j("span#r_mask").html(data['banned_mask']);
						$j("span#r_expires").html(data['expires'] ? data['expires'] : "<i>never</i>");
						$j("span#r_reason").html(data['reason']);
						$j("span#r_post").html(data['postid'] ? data['postid'] : "<i>none</i>");
						$j("#infobox").show('normal');

						show_info("User wurde gesperrt");
					} else if (data['error_msg']) {
						show_error(data['error_msg']);
					}
				},
				error: function (data, status, error) {
					show_error(status);
				}
			});
		},
		"Schließen": function () {
			hide_all();
			$j(this).dialog('close');
		}
	}
	$j("#modpanel").dialog({
		buttons: buttons,
		draggable: true,
		closeOnEscape: false,
		resizable: true,
		title: 'Moderation Post /' + board + '/' + postid,
		open: function (event, ui) {
			$j(".ui-dialog-titlebar-close").hide();
		},
		height: 'auto',
		width: 'auto'
	});

	$j("#ip").val(ip);
	$j("#reason").val("");
	if (ip.indexOf(":") != -1) {
		$j("#netmask").val("ffff:ffff:ffff:ffff:0000:0000:0000:0000");
	} else {
		$j("#netmask").val("255.255.0.0");
	}

	disable_controls();
	$j("#infobox").hide('normal');
	$j("#error").hide('normal');
	show_info("Daten abrufen ...");

	$j.ajax({
		url: "/wakaba.pl?task=checkban&board=" + encodeURIComponent(board) + "&ip=" + ip,
		dataType: 'json',
		success: function (data) {
			if (data['results'] == 0) {
				$j("#ip").attr('disabled', false);
				$j("#netmask").attr('disabled', false);
				$j("#duration").attr('disabled', false);
				$j("#ban_flag").attr('disabled', false);
				$j("#reason").attr('disabled', false).focus();
				$j("#info").hide('normal');
			} else if (data['results'] >= 1) {
				show_info("User wurde bereits gesperrt");
			} else if (data['error_msg']) {
				show_error(data['error_msg']);
			}
		},
		error: function (data, status, error) {
			show_error(status);
		}
	});


	//$j.ajax(<var $self>?admin=<var $admin>&amp;task=addip&amp;type=ipban&amp;ip=<var $ip>&amp;postid=<var $num>)
	//var reason=prompt("Give a reason for this ban:");
	//var mask=prompt("Mask:", "255.255.255.0");
	//if (reason && mask) document.location=el.href+"&comment="+encodeURIComponent(reason)+"&mask="+encodeURIComponent(mask);
	//return false;
}
