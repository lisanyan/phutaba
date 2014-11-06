function do_ban(ip, postid, board) {
	buttons = {
		"OK": function () {
			if (window.disable) {
				$j("#infobox").hide('normal');
				$j("#error").hide('normal');
				$j("#info").hide('normal');
				$j(this).dialog('close');
				return;
			}
			reason = $j("#reason").val() ? $j("#reason").val() : "no reason";
			duration = $j("#duration").val() ? $j("#duration").val() : "";
			mask = $j("#netmask").val() ? $j("#netmask").val() : "255.255.255.255";
			ip = $j("#ip").val() ? $j("#ip").val() : ip;
			url = "/" + board + "/?task=addip&type=ipban&ip=" + ip + "&postid=" + postid + "&mask=" + mask + "&comment=" + reason + "&string=" + duration;
			$j("#infobox").hide('normal');
			$j.ajax({
				url: url,
				dataType: 'json',
				success: function (data) {
					if (data['error_code'] == 200) {
						window.disable = 1;
						$j("#error").hide('normal');
						$j("span#r_ip").html(data['banned_ip']);
						$j("span#r_mask").html(data['banned_mask']);
						$j("span#r_expires").html(data['expires'] ? data['expires'] : "<i>never</i>");
						$j("span#r_reason").html(data['reason']);
						$j("span#r_post").html(data['postid'] ? data['postid'] : "<i>none</i>");
						$j("#infobox").show('normal');

						$j("#infodetails").text("User wurde gesperrt");
						$j("#info").show('normal');
					}
				},
				error: function (data) {
					$j("#infobox").hide('normal');
					$j("#info").hide('normal');
					$j("#errordetails").text(data);
					$j("#error").show('normal');
				}
			});
		},
		"Schließen": function () {
			$j("#infobox").hide('normal');
			$j("#error").hide('normal');
			$j("#info").hide('normal');
			$j(this).dialog('close');
		}
	}
	$j("#modpanel").dialog({
		buttons: buttons,
		draggable: true,
		closeOnEscape: false,
		resizable: true,
		title: 'Moderation Post-Nr. ' + postid,
		open: function (event, ui) {
			$j(".ui-dialog-titlebar-close").hide();
		},
		height: 'auto',
		width: 'auto'
	});

	$j("#ip").attr('disabled', true).val(ip);
	$j("#netmask").attr('disabled', true);
	$j("#duration").attr('disabled', true);
	$j("#reason").attr('disabled', true).val("");

	$j("#infodetails").text("Daten abrufen ...");
	$j("#info").show('normal');
	$j("#infobox").hide('normal');
	$j("#error").hide('normal');

	$j.ajax({
		url: "/" + board + "/?task=checkban&ip=" + ip,
		dataType: 'json',
		success: function (data) {
			if (data['results'] == 0) {
				window.disable = 0;
				$j("#info").hide('normal');
				$j("#ip").attr('disabled', false);
				if (ip.indexOf(":") != -1) {
					$j("#netmask").attr('disabled', true).val("255.255.255.255");
				} else {
					$j("#netmask").attr('disabled', false);
				}
				$j("#duration").attr('disabled', false);
				$j("#reason").attr('disabled', false).val("").focus();
			}
			if (data['results'] >= 1) {
				window.disable = 1;
				$j("#ip").attr('disabled', true);
				$j("#netmask").attr('disabled', true);
				$j("#duration").attr('disabled', true);
				$j("#reason").attr('disabled', true).val("unknown");

				$j("#infodetails").text("User wurde bereits gesperrt");
				$j("#info").show('normal');
			}
		}
	});


	//$j.ajax(<var $self>?admin=<var $admin>&amp;task=addip&amp;type=ipban&amp;ip=<var $ip>&amp;postid=<var $num>)
	//var reason=prompt("Give a reason for this ban:");
	//var mask=prompt("Mask:", "255.255.255.0");
	//if (reason && mask) document.location=el.href+"&comment="+encodeURIComponent(reason)+"&mask="+encodeURIComponent(mask);
	//return false;
}
