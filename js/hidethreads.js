/* requires jquery: jQuery.noConflict() */

/* called when loading a board-page: read list of hidden threads from the cookie and hide them */
function hideThreads(bid, $j) {
	hidThreads = $j.cookie('hidden_' + bid);
	if (hidThreads != null)
		hidThreads = JSON.parse(hidThreads);
	if (hidThreads == null)
		return;
	for (i = 0; i < hidThreads.length; i++) {
		thread = $j('thread_' + hidThreads[i]);
		if (thread == null)
			continue;
		$j("#thread_" + hidThreads[i]).hide();
		$j("#thread_" + hidThreads[i]).after(getHiddenHTML(hidThreads[i], bid));
	}
}

/* adds the thread id to the cookie */
function addHideThread(tid, bid, $j) {
	hidThreads = $j.cookie('hidden_' + bid);
	if (hidThreads != null)
		hidThreads = JSON.parse(hidThreads);
	if (hidThreads == null)
		hidThreads = [];
	for (i = 0; i < hidThreads.length; i++)
		if (hidThreads[i] == tid)
			return;
	hidThreads[hidThreads.length] = tid;
	$j.cookie('hidden_' + bid, JSON.stringify(hidThreads), { expires: 7 });
}

/* deletes a thread id from the cookie */
function removeHideThread(tid, bid, $j) {
	hidThreads = $j.cookie('hidden_' + bid);
	if (hidThreads == null)
		return;

	hidThreads = JSON.parse(hidThreads);
	for (i = 0; i < hidThreads.length; i++)
		if (hidThreads[i] == tid) {
			hidThreads.splice(i, 1);
			i--;
		}
	$j.cookie('hidden_' + bid, JSON.stringify(hidThreads), { expires: 7 });
}

/* hides a single thread from the board page and adds HTML to display it again */
function hideThread(tid, bid, $j) {
	hidThreads = $j.cookie('hidden_' + bid);
	if (hidThreads != null) {
		hidThreads = JSON.parse(hidThreads);
		for (i = 0; i < hidThreads.length; i++)
			if (hidThreads[i] == tid)
				return;
	}
	$j("#thread_" + tid).hide();
	$j("#thread_" + tid).after(getHiddenHTML(tid, bid));
	addHideThread(tid, bid, $j);
};

/* displays the thread again after it was hidden */
function showThread(tid, bid, $j) {
	$j('.show_' + tid).hide();
	$j('.show_' + tid).remove();
	$j("#thread_" + tid).show();
	removeHideThread(tid, bid, $j);
};

/* create HTML for diplaying a hidden thread */
function getHiddenHTML(tid, bid) {
	return '<div class="show_' + tid + ' togglethread">'
		+ '<a class="hide" onclick="showThread(\'' + tid + '\', \'' + bid + '\', $j);">'
		+ '<img src="/img/icons/show.png" width="16" height="16" alt="Thread ' + tid + ' einblenden" />'
		+ ' <strong>Thread ' + tid + '</strong> einblenden</a></div>';
};
