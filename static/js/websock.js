var connected, initws, last_update_ts, loadpost, reconnect_failed, reconnect_timer, updated_ids, watchdog, watchdog_timer, webSocket,
  __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

webSocket = null;
last_update_ts = 0;
updated_ids = [];
reconnect_timer = null;
watchdog_timer = null;
connected = false;

initws = function() {
  var ws_uri;
  ws_uri = "ws://ws.02ch.in:8080";
  if (typeof WebSocket !== "undefined" && WebSocket !== null) {
    webSocket = typeof WebSocket === "function" ? new WebSocket(ws_uri) : void 0;
  } else if (typeof MozWebSocket !== "undefined" && MozWebSocket !== null) {
    webSocket = new MozWebSocket(ws_uri);
  } else {
    return;
  }
  webSocket.onmessage = function(e) {
    console.log(e.data);
    if (e.data === "hi") {
      last_update_ts = Math.floor(new Date().getTime() / 1000);
      jQuery("#websock_enabled").html("<div class='notice'><img src='/img/icons/loading.png' alt='' /> <span>Новые посты</span> будут загружены автоматически.</div>");
      webSocket.send("+/" + board + "/" + thread_id);
      watchdog_timer = setTimeout("watchdog()", 10000);
      connected = true;
      clearTimeout(reconnect_timer);
      return;
    }
    if (e.data === "ping") {
      last_update_ts = Math.floor(new Date().getTime() / 1000);
      webSocket.send("pong");
      return;
    }
    if (e.data[0] === "@") {
      return loadpost(thread_id, e.data.slice(1, e.data.length + 1 || 9e9));
    }
  };
  return webSocket.onclose = function() {
    if (connected === false) return;
    last_update_ts = 0;
    connected = false;
    clearTimeout(watchdog_timer);
    return watchdog();
  };
};

watchdog = function() {
  clearTimeout(watchdog_timer);
  if (Math.floor(new Date().getTime() / 1000) - last_update_ts > 20) {
    jQuery("#websock_enabled").html("<div class='notice'>Lost connection, trying to re-establish ...</div>");
    reconnect_timer = setTimeout("reconnect_failed()", 6000);
    webSocket.close();
    webSocket = null;
    return initws();
  } else {
    return watchdog_timer = setTimeout("watchdog()", 10000);
  }
};

reconnect_failed = function() {
  return jQuery("#websock_enabled").html("<div class='notice'Lost connection. <a href=\"\">Обновить страницу</a></div>");
};

loadpost = function(thread, post) {
  if (__indexOf.call(updated_ids, post) < 0) {
    updated_ids.push(post);
    return jQuery(document).load("/" + board + "/?task=show&post=" + post, "", function(response, status, xmlobj) {
      return jQuery(response.trim()).hide().appendTo("#thread_" + thread).show('normal');
    });
  }
};

window.onload = function() {
  return initws();
};

