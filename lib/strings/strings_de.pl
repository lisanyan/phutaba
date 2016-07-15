use utf8;
my %translation;
$translation{S_HOME} = 'Home';           # Forwards to home page
$translation{S_ADMIN} = 'Manage';         # Forwards to Management Panel
$translation{S_RETURN} = 'Zur&uuml;ck';    # Returns to image board
$translation{S_POSTING} =
  'Auf Thema antworten';    # Prints message in red bar atop the reply screen

$translation{S_NAME} = 'Name';           # Describes name field
$translation{S_EMAIL} = 'E-Mail';         # Describes e-mail field
$translation{S_SUBJECT} = 'Betreff';        # Describes subject field
$translation{S_SUBMIT} = 'Abschicken';     # Describes submit button
$translation{S_COMMENT} = 'Kommentar';      # Describes comment field
$translation{S_UPLOADFILE} = 'Datei';          # Describes file field
$translation{S_NOFILE} = 'Keine Datei';    # Describes file/no file checkbox
$translation{S_CAPTCHA} = 'Captcha';        # Describes captcha field
$translation{S_PARENT} =
  'Thread Nr.';    # Describes parent field on admin post page
$translation{S_DELPASS} = 'Passwort';    # Describes password field
$translation{S_DELEXPL} =
  '(Optional)';    # Prints explanation for password box (to the right)
$translation{S_SPAMTRAP} = '';
$translation{S_ALLOWED} = 'Erlaubte Dateiformate (Maximalgrö&szlig;e %s oder angegeben)';

$translation{S_THUMB} = '';    # Prints instructions for viewing real source
$translation{S_HIDDEN} =
  '';    # Prints instructions for viewing hidden image reply
$translation{S_NOTHUMB} =
  'Datei';    # Printed when there's no thumbnail
$translation{S_PICNAME} = '';             # Prints text before upload name/link
$translation{S_REPLY} = 'Antworten';    # Prints text for reply link
$translation{S_VIEW} = 'View';    # Prints text for reply link
$translation{S_OLD} = 'Dieses Thema ist kurz vor der Löschung.'; # Prints text to be displayed before post is marked for deletion, see: retention

$translation{S_HIDE} = 'Thread %d ausblenden';

$translation{S_ABBR1} = '1 Post ';				# Prints text to be shown when replies are hidden
$translation{S_ABBR2} = '%d Posts ';
$translation{S_ABBRIMG1} = 'und 1 Datei ';		# Prints text to be shown when replies and files are hidden
$translation{S_ABBRIMG2} = 'und %d Dateien ';
$translation{S_ABBR_END} = 'ausgeblendet.'; 

$translation{S_ABBRTEXT1} = '1 weitere Zeile anzeigen';
$translation{S_ABBRTEXT2} = '%d weitere Zeilen anzeigen';

$translation{S_BANNED} = '<p class="ban">(User wurde f&uuml;r diesen Post gesperrt)</p>';

$translation{S_REPDEL} = ' ';    # Prints text next to S_DELPICONLY (left)
$translation{S_DELPICONLY} =
  '';    # Prints text next to checkbox for file deletion (right)
$translation{S_DELKEY} =
  'Passwort ';    # Prints text next to password field for deletion (left)
$translation{S_DELETE} = 'Löschen';    # Defines deletion button's name

$translation{S_PREV} = 'Zur&uuml;ck';    # Defines previous button
$translation{S_FIRSTPG} = 'Zur&uuml;ck';    # Defines previous button
$translation{S_NEXT} = 'Vor';            # Defines next button
$translation{S_LASTPG} = 'Vor';            # Defines next button
$translation{S_TOP} = 'Nach oben';
$translation{S_BOTTOM} = 'Nach unten';

$translation{S_SEARCHTITLE} = 'Suche';
$translation{S_SEARCH} = 'Suchen nach';
$translation{S_SEARCHCOMMENT} = 'Kommentar durchsuchen';
$translation{S_SEARCHSUBJECT} = 'Betreff durchsuchen';
$translation{S_SEARCHFILES} = 'Dateinamen durchsuchen';
$translation{S_SEARCHOP} = 'Nur im OP eines Threads suchen';
$translation{S_SEARCHSUBMIT} = 'Suchen';
$translation{S_SEARCHFOUND} = 'Ergebnisse:';
$translation{S_OPTIONS} = 'Optionen';
$translation{S_MINLENGTH} = '(min. 3 Zeichen)';

$translation{S_DATENAMES} = {
  weekdays => [ 'So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa' ], # Defines abbreviated weekday names.
  months => [qw/Januar Februar März April Mai Juni Juli August September Oktober November Dezember/] # Defines full month names
};

$translation{S_STICKYTITLE} = 'Thread ist angepinnt';    # Defines the title of the tiny sticky image on a thread if it is sticky
$translation{S_LOCKEDTITLE} = 'Thread ist geschlossen';    # Defines the title of the tiny locked image on a thread if it is locked

# javascript message strings (do not use HTML entities; mask single quotes with \\\')
$translation{S_JS_OPENFORM} = 'Open Form';
$translation{S_JS_REMOVEFILE} = 'Datei entfernen';
$translation{S_JS_STYLES} = 'Stilvorlagen';
$translation{S_JS_DONE} = 'Ok';
$translation{S_JS_UPDATE} = 'Update faden'; # cant translate lol
$translation{S_JS_SETTINGS} = 'die Settings';
# javascript strings END

$translation{S_MANARET} = 'Zur&uuml;ck';    # Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
$translation{S_MANAMODE} = 'Administration';   # Prints heading on top of Manager page

$translation{S_MANALOGIN} = 'Login'; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
$translation{S_ADMINPASS} = 'Passwort:';    # Prints login prompt

$translation{S_MANAPANEL} = 'Posts moderieren'; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
$translation{S_MANATOOLS} = 'Werkzeuge';
$translation{S_MANAGEOINFO} = 'GeoIP-Informationen';
$translation{S_MANADELETE} = 'Posts löschen';
$translation{S_MANABANS} = 'Sperren verwalten'; # Defines Bans Panel button
$translation{S_MANAORPH} = 'Verwaiste Dateien';
  ; # Defines Manager Post radio button--allows the user to post using HTML code in the comment box
$translation{S_MANALOGOUT} = 'Abmelden';          #
$translation{S_MANASAVE} = 'Speichern';    # Defines Label for the login cookie checbox
$translation{S_MANALOG} = 'Log';
$translation{S_MANABACKS} = 'Sicherungskopien';
$translation{S_MANASUB} = 'Los';          # Defines name for submit button in Manager Mode

$translation{S_NOTAGS} = '<p>Formatierung nur mit HTML-Tags. Keine Parser-Verarbeitung.</p>';               # Prints message on Management Board

$translation{S_POSTASADMIN} = 'Administrationskennung am Post anzeigen';
$translation{S_NOTAGS2} = 'Kommentar nicht durch den Parser verarbeiten';
$translation{S_MPSETSAGE} = 'Setze Systemkontra';
$translation{S_MPUNSETSAGE} = 'Löse Systemkontra';

$translation{S_BTNEWTHREAD} = 'Neuen Thread erstellen';
$translation{S_BTREPLY} = 'Antworten auf';
$translation{S_SAGE} = 'Kontra';
$translation{S_SAGEDESC} = 'Thread nicht sto&szlig;en';
$translation{S_IMGEXPAND} = 'Textfeld vergrö&szlig;ern';
$translation{S_NOKO} = 'Zur&uuml;ck zum';
$translation{S_NOKOOFF} = 'Board';
$translation{S_NOKOON} = 'Thread';

$translation{S_NOPOMF} = 'POMF';
$translation{S_NOPOMFDESC} = 'Don\'t upload files to an external server';

$translation{S_THREADLOCKED} = '<strong>Thread %s</strong> ist geschlossen. Es kann nicht geantwortet werden.';
$translation{S_FILEINFO} = 'Informationen';
$translation{S_FILEDELETED} = 'Datei gelöscht';


$translation{S_POSTINFO} = 'IP-Informationen';
$translation{S_MPDELETEIP} = 'Alle löschen';
$translation{S_MPDELETE} = 'Post löschen';    # Defines for deletion button in Management Panel
$translation{S_MPDELFILE} = 'Datei(en) löschen';
$translation{S_MPARCHIVE} = 'Archiv';
$translation{S_MPSTICKY} = 'Sticky setzen';
$translation{S_MPUNSTICKY} = 'Sticky entfernen';
$translation{S_MPLOCK} = 'Thread schlie&szlig;en';
$translation{S_MPUNLOCK} = 'Thread öffnen';
$translation{S_MPEDIT} = 'Post-Text bearbeiten';
$translation{S_MPRESET} = 'Resetten';        # Defines name for field reset button in Management Panel
$translation{S_MPRESTORE} = 'Restore';        # Defines name for field reset button in Management Panel
$translation{S_MPONLYPIC} = 'Nur Datei';  # Sets whether or not to delete only file, or entire post/thread
$translation{S_MPDELETEALL} = 'Alle&nbsp;Posts&nbsp;dieser&nbsp;IP&nbsp;löschen';    #
$translation{S_MPBAN} = 'Bann';    # Sets whether or not to delete only file, or entire post/thread
$translation{S_MPTABLE} = '<th>No.</th><th>Date</th><th>Subject</th>'
                        . '<th>Name</th><th>Comment</th><th>IP</th>'; # Explains names for Management Panel
$translation{S_IMGSPACEUSAGE} = '[ Belegter Speicherplatz: %s, %s Dateien, %s Posts (%s Threads) ]';          # Prints space used KB by the board under Management Panel

$translation{S_DELALLMSG} = 'Betroffen';
$translation{S_DELALLCOUNT} = '%s Posts (%s Threads)';

$translation{S_BANFILTER} = 'Abgelaufene Sperren ausblenden';
$translation{S_BANSHOWALL} = 'Abgelaufene Sperren anzeigen';
$translation{S_BANTABLE} =
  '<th>Typ</th><th colspan="2">Wert</th><th>Kommentar</th><th>Erstelldatum</th><th>Ablaufdatum</th><th>Aktion</th>';
  # Explains names for Ban Panel
$translation{S_BANIPLABEL} = 'IP-Adresse';
$translation{S_BANMASKLABEL} = 'Netzmaske';
$translation{S_BANCOMMENTLABEL} = 'Kommentar';
$translation{S_BANDURATION} = 'Dauer';
$translation{S_BANWORDLABEL} = 'Wort';
$translation{S_BANIP} = 'IP sperren';
$translation{S_BANWORD} = 'Wortfilter';
$translation{S_BANWHITELIST} = 'Whitelist';
$translation{S_BANREMOVE} = 'Entfernen';
$translation{S_BANEDIT} = 'Bearbeiten';
$translation{S_BANCOMMENT} = 'Kommentar';
$translation{S_BANTRUST} = 'Kein Captcha';
$translation{S_BANTRUSTTRIP} = 'Tripcode';
$translation{S_BANREASONLABEL} = 'Grund';
$translation{S_BANASNUMLABEL} = 'AS-Nummer';
$translation{S_BANASNUM} = 'Netz sperren';
$translation{S_BANEXPIRESLABEL} = 'Dauer';
$translation{S_BANREASONLABEL} = 'Grund';

$translation{S_LANGUAGE} = 'Sprache';

$translation{S_LOCKED} = 'Thread ist geschlossen';

$translation{S_ORPHTABLE} = '<th>Öffnen</th><th>Datei</th><th>Änderungsdatum</th><th>Grö&szlig;e</th>';
$translation{S_MANASHOW} = 'Öffnen';

$translation{S_PROXYDISABLED} = 'Proxy-Abfrage ist momentan nicht aktiviert.';
$translation{S_BADIP} = 'Falsche IP-Adresse';
$translation{S_BADDELIP} = 'Falsche IP.';    # Returns error for wrong ip (when user tries to delete file)
$translation{S_INVALID_PAGE} = "Keine solche Seite gefunden.";
$translation{S_STOP_FOOLING} = "Lass das sein, Kevin!";

$translation{S_TOOBIG} = 'Die Datei ist zu gro&szlig;.';
$translation{S_TOOBIGORNONE} = 'Die Datei ist zu gro&szlig; oder leer.';
$translation{S_REPORTERR} = 'Beitrag nicht gefunden.';    # Returns error when a reply (res) cannot be found
$translation{S_UPFAIL} = 'Upload fehlgeschlagen.';    # Returns error for failed upload (reason: unknown?)
$translation{S_NOREC} = 'Eintrag nicht gefunden.'; # Returns error when record cannot be found
$translation{S_NOCAPTCHA} = 'Kein CAPTCHA in der DB für diesen Key.';    # Returns error when there's no captcha in the database for this IP/key
$translation{S_BADCAPTCHA} = 'Falscher Captcha-Code.';    # Returns error when the captcha is wrong
$translation{S_BADFORMAT} = 'Dateityp wird nicht unterst&uuml;tzt.';    # Returns error when the file is not in a supported format.
$translation{S_STRREF} = 'String abgewiesen.';    # Returns error when a string is refused
$translation{S_UNJUST} = 'Flood detektiert.'; # Returns error on an unjust POST - prevents floodbots or ways not using POST method?
$translation{S_NOPIC} = 'Keine Datei ausgewählt.';    # Returns error for no file selected and override unchecked
$translation{S_NOTEXT} = 'Keinen Text eingegeben.';    # Returns error for no text entered in to subject/comment
$translation{S_TOOLONG} = 'Zu viele Zeichen im Kommentar.';    # Returns error for too many characters in a given field
$translation{S_NOTALLOWED} = 'Das Post-Formular wurde falsch ausgef&uuml;llt.';    # Returns error for non-allowed post types
$translation{S_NOPOSTING} = 'Neue Posts d&uuml;rfen nicht eröffnet werden.';
$translation{S_UNUSUAL} = 'WAS GEHT DENN MIT DIR AB?';    # Returns error for abnormal reply? (this is a mystery!)
$translation{S_BADHOST} = 'IP-Adresse ist gesperrt.';    # Returns error for banned host ($badip string)
$translation{S_BADHOSTPROXY} = 'Proxy ist gesperrt.';    # Returns error for banned proxy ($badip string)
$translation{S_RENZOKU} = 'Zu viele Posts abgesetzt.';    # Returns error for $sec/post spam filter
$translation{S_RENZOKU2} = 'Zu viele Posts abgesetzt.';    # Returns error for $sec/upload spam filter
$translation{S_RENZOKU3} = 'Zu viele Posts abgesetzt.';    # Returns error for $sec/similar posts spam filter.
$translation{S_RENZOKU4} = 'Löschwartezeit noch nicht abgelaufen.';    # Returns error for too early post deletion.
$translation{S_RENZOKU5} = 'Zu viele Posts abgesetzt. Bitte warten.';
$translation{S_PROXY} = 'Ich mag keine Proxys.';    # Returns error for proxy detection.
$translation{S_DUPE} = 'Die Datei wurde bereits <a href="%s">hier</a> hochgeladen.';    # Returns error when an md5 checksum already exists.
$translation{S_DUPENAME} = 'Eine Datei desselbigen Namens existiert bereits.';    # Returns error when an filename already exists.
$translation{S_NOTHREADERR} = 'Thema existiert nicht.';    # Returns error when a non-existant thread is accessed
$translation{S_BADDELPASS} = 'Falsches Löschpasswort.';    # Returns error for wrong password (when user tries to delete file)
$translation{S_WRONGPASS} = 'Falsches Passwort / Bitte erneut anmelden.';    # Returns error for wrong password (when trying to access Manager modes)
$translation{S_VIRUS} = 'Die Datei könnte von einem Virus befallen sein.';    # Returns error for malformed files suspected of being virus-infected.
$translation{S_NOTWRITE} = 'Verzeichnis konnte nicht beschrieben werden.'; # Returns error when the script cannot write to the directory, the chmod (777) is wrong
$translation{S_SPAM} = 'Spam? Raus hier!';   # Returns error when detecting spam
$translation{S_NOBOARDACC} = 'You don\'t have access to this board, accessible: %s<br /><a href="%s?task=logout">Logout</a>';

$translation{S_SQLCONF} = 'MySQL-Datenbankfehler'; # Database connection failure
$translation{S_SQLFAIL} = 'MySQL-Datenbankfehler'; # SQL Failure

$translation{S_EDITPOST} = 'Edit post';
$translation{S_EDITHEAD} = 'Editing No.<a href="%s">%d</a>';
$translation{S_UPDATE} = 'Update';

$translation{S_PREWRAP} = "<span class=\"prewrap\">%s</span>";

$translation{S_REDIR} =
  'If the redirect didn\'t work, please choose one of the following mirrors:';    # Redir message for html in REDIR_DIR

$translation{S_DNSBL} =
  'Deine IP wurde in der Blacklist <em>%s</em> gelistet!';    # error string for tor node check

\%translation;
