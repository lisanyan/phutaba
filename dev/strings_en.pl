use constant S_HOME => 'Home';										# Forwards to home page
use constant S_ADMIN => 'Manage';									# Forwards to Management Panel
use constant S_RETURN => 'Zur&uuml;ck';									# Returns to image board
use constant S_POSTING => 'Auf Thema antworten';					# Prints message in red bar atop the reply screen

use constant S_NAME => 'Name';										# Describes name field
use constant S_EMAIL => 'E-Mail';									# Describes e-mail field
use constant S_SUBJECT => 'Betreff';								# Describes subject field
use constant S_SUBMIT => 'Abschicken';									# Describes submit button
use constant S_COMMENT => 'Kommentar<br /><span style="font-size: 8pt;">(<a href="http://wakaba.c3.cx/docs/docs.html#WakabaMark">WakabaMark</a>)</span>';								# Describes comment field
use constant S_UPLOADFILE => 'Datei';								# Describes file field
use constant S_NOFILE => 'Keine Datei';									# Describes file/no file checkbox
use constant S_CAPTCHA => 'Captcha';							# Describes captcha field
use constant S_PARENT => 'Thread Nr.';									# Describes parent field on admin post page
use constant S_DELPASS => 'Passwort';								# Describes password field
use constant S_DELEXPL => '(Optional)';			# Prints explanation for password box (to the right)
use constant S_SPAMTRAP => '';

use constant S_THUMB => '';	# Prints instructions for viewing real source
use constant S_HIDDEN => '';	# Prints instructions for viewing hidden image reply
use constant S_NOTHUMB => 'Kein<br />Thumbnail';								# Printed when there's no thumbnail
use constant S_PICNAME => '';											# Prints text before upload name/link
use constant S_REPLY => 'Antworten';											# Prints text for reply link
use constant S_OLD => 'Dieses Thema ist kurz vor der L&ouml;schung.';							# Prints text to be displayed before post is marked for deletion, see: retention
use constant S_ABBR => '%d Post(s) ausgeblendet.';			# Prints text to be shown when replies are hidden
use constant S_ABBRIMG => '%d Post(s) und %d Datei(en) ausgeblendet.';						# Prints text to be shown when replies and images are hidden
use constant S_ABBRTEXT => '<p style="color: #333333;">[ <a href="%s">ZL;NG</a> ]</p>';

use constant S_REPDEL => ' ';							# Prints text next to S_DELPICONLY (left)
use constant S_DELPICONLY => '';							# Prints text next to checkbox for file deletion (right)
use constant S_DELKEY => 'Passwort ';								# Prints text next to password field for deletion (left)
use constant S_DELETE => 'L&ouml;schen';									# Defines deletion button's name

use constant S_PREV => 'Zur&uuml;ck';									# Defines previous button
use constant S_FIRSTPG => 'Zur&uuml;ck';								# Defines previous button
use constant S_NEXT => 'Vor';										# Defines next button
use constant S_LASTPG => 'Vor';									# Defines next button

use constant S_WEEKDAYS => ('So','Mo','Di','Mi','Do','Fr','Sa');	# Defines abbreviated weekday names.

use constant S_MANARET => 'Zur&uuml;ck';										# Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
use constant S_MANAMODE => 'Admin :3';								# Prints heading on top of Manager page

use constant S_MANALOGIN => 'Login';							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_ADMINPASS => 'Passwort:';							# Prints login prompt

use constant S_MANAPANEL => 'Posts moderieren';							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_MANABANS => 'IPs sperren';							# Defines Bans Panel button
use constant S_MANAPROXY => 'Proxys konfigurieren';
use constant S_MANASPAM => 'Spam';										# Defines Spam Panel button
use constant S_MANASQLDUMP => 'MySQL abfragen';								# Defines SQL dump button
use constant S_MANASQLINT => 'MySQL Interface';							# Defines SQL interface button
use constant S_MANAPOST => 'Adminbeitrag verfassen';								# Defines Manager Post radio button--allows the user to post using HTML code in the comment box
use constant S_MANAREBUILD => 'Cache erneuern';							# 
use constant S_MANANUKE => 'Atombombe';								# 
use constant S_MANALOGOUT => 'Ausloggen';									# 
use constant S_MANASAVE => 'Speichern';				# Defines Label for the login cookie checbox
use constant S_MANASUB => 'Los';											# Defines name for submit button in Manager Mode

use constant S_NOTAGS => '<p>HTML-Tags sind m&ouml;glich. Kein WakabaMark.</p>'; # Prints message on Management Board

use constant S_MPDELETEIP => 'Alle l&ouml;schen';
use constant S_MPDELETE => 'L&ouml;schen';									# Defines for deletion button in Management Panel
use constant S_MPARCHIVE => 'Archiv';
use constant S_MPRESET => 'Resetten';										# Defines name for field reset button in Management Panel
use constant S_MPONLYPIC => 'Nur Datei';								# Sets whether or not to delete only file, or entire post/thread
use constant S_MPDELETEALL => 'Alle&nbsp;l&ouml;schen';							# 
use constant S_MPBAN => 'Bann';											# Sets whether or not to delete only file, or entire post/thread
use constant S_MPTABLE => '<th>Nr.</th><th>Zeit</th><th>Betreff</th>'.
                          '<th>Name</th><th>Kommentar</th><th>IP</th>';	# Explains names for Management Panel
use constant S_IMGSPACEUSAGE => '[ Benutzter Speicherplatz: %d KB ]';				# Prints space used KB by the board under Management Panel

use constant S_BANTABLE => '<th>Typ</th><th>Wert</th><th>Kommentar</th><th>Aktion</th>'; # Explains names for Ban Panel
use constant S_BANIPLABEL => 'IP';
use constant S_BANMASKLABEL => 'Mask';
use constant S_BANCOMMENTLABEL => 'Kommentar';
use constant S_BANWORDLABEL => 'Wort';
use constant S_BANIP => 'IP sperren';
use constant S_BANWORD => 'Wortfilter';
use constant S_BANWHITELIST => 'Whitelist';
use constant S_BANREMOVE => 'Entfernen';
use constant S_BANCOMMENT => 'Kommentar';
use constant S_BANTRUST => 'Kein Captcha';
use constant S_BANTRUSTTRIP => 'Tripcode';

use constant S_PROXYTABLE => '<th>Typ</th><th>IP</th><th>L&auml;uft aus</th><th>Datum</th>'; # Explains names for Proxy Panel
use constant S_PROXYIPLABEL => 'IP';
use constant S_PROXYTIMELABEL => 'Zeit';
use constant S_PROXYREMOVEBLACK => 'Entfernen';
use constant S_PROXYWHITELIST => 'Whitelist';
use constant S_PROXYDISABLED => 'Proxy-Abfrage ist momentan nicht aktiviert.';
use constant S_BADIP => 'Falsche IP-Adresse';
use constant S_BADDELIP => 'Fehler: Falsche IP.';             # Returns error for wrong ip (when user tries to delete file)

use constant S_SPAMEXPL => 'Diese Liste mit Domains werden von Wakaba als Spam angesehen.<br />'.
                           'Die aktuellste Version davon gibt es <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&amp;format=wakaba">hier</a>, '.
                           'die <code>spam.txt</code>-Datei direkt <a href="http://wakaba.c3.cx/antispam/spam.txt">hier</a>.';
use constant S_SPAMSUBMIT => 'Speichern';
use constant S_SPAMCLEAR => 'Leeren';
use constant S_SPAMRESET => 'Wiederherstellen';

use constant S_SQLNUKE => 'Nuke-Passwort:';
use constant S_SQLEXECUTE => 'Execute';

use constant S_TOOBIG => 'Die Datei ist zu gro&szlig;.';
use constant S_TOOBIGORNONE => 'Die Datei ist zu gro&szlig;.';
use constant S_REPORTERR => 'Fehler: Beitrag nicht gefunden.';					# Returns error when a reply (res) cannot be found
use constant S_UPFAIL => 'Fehler: Upload fehlgeschlagen.';							# Returns error for failed upload (reason: unknown?)
use constant S_NOREC => 'Fehler: Eintrag nicht gefunden.';						# Returns error when record cannot be found
use constant S_NOCAPTCHA => 'Fehler: Kein CAPTCHA in der DB für diesen Key.';	# Returns error when there's no captcha in the database for this IP/key
use constant S_BADCAPTCHA => 'Fehler: Falscher Captcha-Code.';		# Returns error when the captcha is wrong
use constant S_BADFORMAT => 'Fehler: Dateityp wird nicht unterst&uuml;tzt.';			# Returns error when the file is not in a supported format.
use constant S_STRREF => 'Fehler: String abgewiesen.';							# Returns error when a string is refused
use constant S_UNJUST => 'Fehler: Flood detektiert.';								# Returns error on an unjust POST - prevents floodbots or ways not using POST method?
use constant S_NOPIC => 'Fehler: Keine Datei ausgew&auml;hlt.';	# Returns error for no file selected and override unchecked
use constant S_NOTEXT => 'Fehler: Keinen Text eingegeben.';						# Returns error for no text entered in to subject/comment
use constant S_TOOLONG => 'Fehler: Zu viele Zeichen im Kommentar.';		# Returns error for too many characters in a given field
use constant S_NOTALLOWED => 'Fehler: 403 Forbidden.';					# Returns error for non-allowed post types
use constant S_UNUSUAL => 'Fehler: WAS GEHT DENN MIT DIR AB?';							# Returns error for abnormal reply? (this is a mystery!)
use constant S_BADHOST => 'Fehler: IP-Adresse ist gesperrt.';							# Returns error for banned host ($badip string)
use constant S_BADHOSTPROXY => 'Fehler: Proxy ist gesperrt.';	# Returns error for banned proxy ($badip string)
use constant S_RENZOKU => 'Fehler: Flood detektiert.';			# Returns error for $sec/post spam filter
use constant S_RENZOKU2 => 'Fehler: Flood detektiert.';		# Returns error for $sec/upload spam filter
use constant S_RENZOKU3 => 'Fehler: Flood detektiert.';						# Returns error for $sec/similar posts spam filter.
use constant S_PROXY => 'Fehler: Ich mag keine Proxys.';						# Returns error for proxy detection.
use constant S_DUPE => 'Fehler: Die Datei wurde bereits <a href="%s">hier</a> hochgeladen.';	# Returns error when an md5 checksum already exists.
use constant S_DUPENAME => 'Fehler: Eine Datei desselbigen Namens existiert bereits.';	# Returns error when an filename already exists.
use constant S_NOTHREADERR => 'Fehler: Thema existiert nicht.';				# Returns error when a non-existant thread is accessed
use constant S_BADDELPASS => 'Fehler: Falsches Passwort.';		# Returns error for wrong password (when user tries to delete file)
use constant S_WRONGPASS => 'Fehler: Falsches Passwort';		# Returns error for wrong password (when trying to access Manager modes)
use constant S_VIRUS => 'Fehler: Die Datei k&ouml;nnte von einem Virus befallen sein.';				# Returns error for malformed files suspected of being virus-infected.
use constant S_NOTWRITE => 'Fehler: Verzeichnis konnte nicht beschrieben werden.';				# Returns error when the script cannot write to the directory, the chmod (777) is wrong
use constant S_SPAM => 'Spam? Raus hier!';					# Returns error when detecting spam

use constant S_SQLCONF => 'MySQL-Datenbankfehler';							# Database connection failure
use constant S_SQLFAIL => 'MySQL-Datenbankfehler';							# SQL Failure

use constant S_REDIR => 'If the redirect didn\'t work, please choose one of the following mirrors:';    # Redir message for html in REDIR_DIR

use constant S_DNSBL => 'Fehler: TOR Nodes sind nicht erlaubt!';    # error string for tor node check


1;

