function do_ban(ip, postid, board, session) {
	buttons = {
		"Ok": function () {
			if (window.disable) {
				$j("#infobox").hide('normal');
				$j("#error").hide('normal');
				$j("#info").hide('normal');
				$j(this).dialog('close');
				return;
			}
			postid = $j("#postid").val() == "none" ? "" : postid;
			reason = $j("#reason").val() ? $j("#reason").val() : "no reason";
			mask = $j("#netmask").val() ? $j("#netmask").val() : "255.255.255.255";
			ip = $j("#ip").val() ? $j("#ip").val() : ip;
			url = "/" + board + "/?admin=" + session + "&amp;task=addip&amp;type=ipban&amp;ip=" + ip + "&amp;postid=" + postid + "&amp;mask=" + mask + "&amp;comment=" + reason;
			$j("#infobox").hide('normal');
			$j.ajax({
				url: url,
				dataType: 'json',
				success: function (data) {
					if (data['error_code'] == 200) {
						$j("span#r_ip").html(data['banned_ip']);
						$j("span#r_mask").html(data['banned_mask']);
						$j("span#r_reason").html(data['reason']);
						$j("span#r_post").html(data['postid'] ? data['postid'] : "<i>none</i>");
						$j("#infobox").show('normal');
						$j("#postid").val("none");
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
		"Close": function () {
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
		title: 'Moderation',
		open: function (event, ui) {
			$j(".ui-dialog-titlebar-close").hide();
			$j.ajax({
				url: "/" + board + "/?admin=" + session + "&amp;task=checkban&amp;ip=" + ip,
				dataType: 'json',
				success: function (data) {
					if (data['results'] == 0) {
						window.disable = 0;
						$j("#ip").attr('disabled', false).val(ip);
						$j("#netmask").attr('disabled', false).val("255.255.255.255");
						$j("#postid").attr('disabled', true).val(postid);
						$j("#reason").attr('disabled', false).val("no reason").focus();
					}
					if (data['results'] >= 1) {
						window.disable = 1;
						$j("#ip").attr('disabled', true).val(ip);
						$j("#netmask").attr('disabled', true).val("unknown");
						$j("#postid").attr('disabled', true).val("none");
						$j("#reason").attr('disabled', true).val("unknown");
						$j("#infodetails").text("User wurde bereits gesperrt");
						$j("#info").show('normal');
					}
				}
			});

		},
		height: 'auto',
		width: 'auto'
	});

	//$j.ajax(<var $self>?admin=<var $admin>&amp;task=addip&amp;type=ipban&amp;ip=<var $ip>&amp;postid=<var $num>)
	//var reason=prompt("Give a reason for this ban:");
	//var mask=prompt("Mask:", "255.255.255.0");
	//if (reason && mask) document.location=el.href+"&comment="+encodeURIComponent(reason)+"&mask="+encodeURIComponent(mask);
	//return false;
}
