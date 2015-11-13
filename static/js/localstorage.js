// Localstorage Settings
var Settings = function() {
    if (!window.localStorage) {
        return {
            set: function(key, value) {
                return set_cookie(key, value, 365 * 24 * 60 * 60 * 1000);
            },
            get: function(key) {
                return get_cookie(key);
            },
            del: function(key) {
                return set_cookie(key, "", 1);
            }
        };
    } else
        return {
            set: function(key, value) {
                return window.localStorage.setItem(key, value);
            },
            get: function(key) {
                // legacy
                var cookie = get_cookie(key);
                var local = window.localStorage.getItem(key);
                if (cookie && !local) {
                    window.localStorage.setItem(key, cookie);
                }
                // end legacy
                return window.localStorage.getItem(key);
            },
            del: function(key) {
                return window.localStorage.removeItem(key);
            }
        };
}();

// External settings to not shit directly
// to localstorage
var ExtSettings = function() {
    key = 'settings';
    ext = Settings.get(key);
    if (ext != null)
        ext = JSON.parse(ext);
    if (ext == null) ext = {};
    return {
        set: function(k, v) {
            ext[k] = v;
            return Settings.set(key, JSON.stringify(ext));
        },
        get: function(k) { return ext[k] },
        del: function(k) {
            delete ext[k];
            return Settings.set(key, JSON.stringify(ext));
        }
    }
}();

// Cookies!
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
