/* requires jquery: jQuery.noConflict() */

/* called when loading a board-page: read list of hidden threads from the localstorage and hide them */
function hideThreads(bid, $j) {
	hidThreads = Settings.get('hidden');
	if (hidThreads != null) hidThreads = JSON.parse(hidThreads);
	if (hidThreads == null) return;
	if (typeof hidThreads[bid] !== 'object') hidThreads[bid] = [];
	for (i = 0; i < hidThreads[bid].length; i++) {
		thread = $j('thread_' + hidThreads[bid][i]);
		if (thread == null)
			continue;
		$j("#thread_" + hidThreads[bid][i]).hide();
		$j("#thread_" + hidThreads[bid][i]).after(getHiddenHTML(hidThreads[bid][i], bid));
	}
}

/* adds the thread id to the cookie */
function addHideThread(tid, bid, $j) {
	hidThreads = Settings.get('hidden');
	if (hidThreads != null) hidThreads = JSON.parse(hidThreads);
	if (hidThreads == null) hidThreads = {};
	if (typeof hidThreads[bid] !== 'object') hidThreads[bid] = [];
	for (i = 0; i < hidThreads[bid].length; i++)
		if (hidThreads[bid][i] == tid)
			return;
	hidThreads[bid][hidThreads[bid].length] = tid;
	Settings.set('hidden', JSON.stringify(hidThreads));
}

/* deletes a thread id from the cookie */
function removeHideThread(tid, bid, $j) {
	hidThreads = Settings.get('hidden');
	if (hidThreads == null)
		return;

	hidThreads = JSON.parse(hidThreads);
	for (i = 0; i < hidThreads[bid].length; i++)
		if (hidThreads[bid][i] == tid) {
			hidThreads[bid].splice(i, 1);
			i--;
		}
	Settings.set('hidden', JSON.stringify(hidThreads));
}

/* hides a single thread from the board page and adds HTML to display it again */
function hideThread(tid, bid, $j) {
	hidThreads = Settings.get('hidden');
	if (hidThreads != null) {
		hidThreads = JSON.parse(hidThreads);
		if (typeof hidThreads[bid] !== 'object')
			hidThreads[bid] = [];
		for (i = 0; i < hidThreads[bid].length; i++)
			if (hidThreads[bid][i] == tid)
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
		+ '<img src="/img/icons/show.png" width="16" height="16" alt="Thread ' + tid + ' hidden" />'
		+ ' <strong>Тред ' + tid + '</strong> скрыт</a></div>';
};
