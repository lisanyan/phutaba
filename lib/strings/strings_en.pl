use utf8;
my %translation;
$translation{S_HOME} = 'Home';        # Forwards to home page
$translation{S_ADMIN} = 'Manage';     # Forwards to Management Panel
$translation{S_RETURN} = 'Return';    # Returns to image board
$translation{S_POSTING} =
  'Reply mode';    # Prints message in red bar atop the reply screen

$translation{S_NAME} = 'Name';        # Describes name field
$translation{S_EMAIL} = 'E-Mail';     # Describes e-mail field
$translation{S_SUBJECT} = 'Subject';  # Describes subject field
$translation{S_SUBMIT} = 'Submit';    # Describes submit button
$translation{S_COMMENT} = 'Comment';  # Describes comment field
$translation{S_UPLOADFILE} = 'File';  # Describes file field
$translation{S_NOFILE} = 'No File';   # Describes file/no file checkbox
$translation{S_CAPTCHA} = 'Captcha';  # Describes captcha field
$translation{S_PARENT} = 'Thread #';
  # Describes parent field on admin post page
$translation{S_DELPASS} = 'Password';    # Describes password field
$translation{S_DELEXPL} = '(Optional)';
  # Prints explanation for password box (to the right)
$translation{S_SPAMTRAP} = '';
$translation{S_ALLOWED} = 'Allowed file formats (max. %s or given)';

$translation{S_THUMB} = '';    # Prints instructions for viewing real source
$translation{S_HIDDEN} = '';    # Prints instructions for viewing hidden image reply
$translation{S_NOTHUMB} = 'File'; # Printed when there's no thumbnail
$translation{S_PICNAME} = '';             # Prints text before upload name/link
$translation{S_REPLY} = 'Reply';    # Prints text for reply link
$translation{S_OLD} = 'Marked for deletion (old).'; 
  # Prints text to be displayed before post is marked for deletion, see: retention

$translation{S_HIDE} = 'Thread %d ausblenden';

$translation{S_ABBR1} = '1 Post ';				# Prints text to be shown when replies are hidden
$translation{S_ABBR2} = '%d Posts ';
$translation{S_ABBRIMG1} = 'and 1 File ';		# Prints text to be shown when replies and files are hidden
$translation{S_ABBRIMG2} = 'and %d Files ';
$translation{S_ABBR_END} = 'hidden.'; 

$translation{S_ABBRTEXT1} = 'Expand full post (+1 line)';
$translation{S_ABBRTEXT2} = 'Expand full post (+%d lines)';

$translation{S_BANNED} = '<p class="ban">(User was banned for this post)</p>';

$translation{S_REPDEL} = ' ';    # Prints text next to S_DELPICONLY (left)
$translation{S_DELPICONLY} = '';    # Prints text next to checkbox for file deletion (right)
$translation{S_DELKEY} = 'Password ';    # Prints text next to password field for deletion (left)
$translation{S_DELETE} = 'Delete';    # Defines deletion button's name

$translation{S_PREV} = 'Previous';                  # Defines previous button
$translation{S_FIRSTPG} = 'Previous';               # Defines previous button
$translation{S_NEXT} = 'Next';                    # Defines next button
$translation{S_LASTPG} = 'Next';                  # Defines next button
$translation{S_TOP} = 'Top';
$translation{S_BOTTOM} = 'Bottom';

$translation{S_SEARCHTITLE} = 'Search';
$translation{S_SEARCH} = 'Search';
$translation{S_SEARCHCOMMENT} = 'Search in comments';
$translation{S_SEARCHSUBJECT} = 'Search in subject';
$translation{S_SEARCHFILES} = 'Search by files';
$translation{S_SEARCHOP} = 'Search only in OP-posts';
$translation{S_SEARCHSUBMIT} = 'Search';
$translation{S_SEARCHFOUND} = 'Found:';
$translation{S_OPTIONS} = 'Options';
$translation{S_MINLENGTH} = '(min. 3 symbols)';

$translation{S_DATENAMES} = {
  weekdays => [qw/Sun Mon Tue Wed Thu Fri Sat/], # Defines abbreviated weekday names.
  months => [qw/January February March April May June July August September October November December/] # Defines full month names
};

$translation{S_STICKYTITLE} = 'Sticky thread';    # Defines the title of the tiny sticky image on a thread if it is sticky
$translation{S_LOCKEDTITLE} = 'Locked thread';    # Defines the title of the tiny locked image on a thread if it is locked

# javascript message strings (do not use HTML entities; mask single quotes with \\\')
$translation{S_JS_EXPAND} = 'Expand textfield';
$translation{S_JS_SHRINK} = 'Shrink textfield';
$translation{S_JS_REMOVEFILE} = 'Remove file';
$translation{S_JS_STYLES} = 'Styles';
$translation{S_JS_DONE} = 'Done';
$translation{S_JS_CONTEXT} = 'Toggle Context';
$translation{S_JS_UPDATE} = 'Update thread';
# javascript strings END

$translation{S_MANARET} = 'Return';    # Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
$translation{S_MANAMODE} = 'Administration';   # Prints heading on top of Manager page

$translation{S_MANALOGIN} = 'Login';
  # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
$translation{S_ADMINPASS} = 'Password:';    # Prints login prompt

$translation{S_MANAPANEL} = 'Management Panel';
  # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
$translation{S_MANATOOLS} = 'Tools';
$translation{S_MANAGEOINFO} = 'GeoIP-Information';
$translation{S_MANABANS} = 'Bans';         # Defines Bans Panel button
$translation{S_MANAPROXY} = 'Proxy';
$translation{S_MANAORPH} = 'Orphans';
$translation{S_MANALOGOUT} = 'Logout';
$translation{S_MANASAVE} = 'Remember me';    # Defines Label for the login cookie checbox
$translation{S_MANASUB} = 'Go';          # Defines name for submit button in Manager Mode
$translation{S_MANABACKS} = 'Post Backups';
$translation{S_MANALOG} = 'Log';

$translation{S_NOTAGS} = '<p>HTML tags are also possible. No WakabaMark.</p>';
  # Prints message on Management Board

$translation{S_POSTASADMIN} = 'Post with an admin mark';
$translation{S_NOTAGS2} = 'Comment willn\'t be processed through parser.';
$translation{S_MPSETSAGE} = 'Toggle Sage';
$translation{S_MPUNSETSAGE} = 'Toggle Sage';

$translation{S_BTNEWTHREAD} = 'Creat new thread';
$translation{S_BTREPLY} = 'Reply to';
$translation{S_SAGE} = 'Sage';
$translation{S_SAGEDESC} = 'Don\'t bump this thread'; # 'Thread has reached bump-limit';
$translation{S_IMGEXPAND} = 'Expand text field';
$translation{S_NOKO} = 'Go to';
$translation{S_NOKOOFF} = 'Board';
$translation{S_NOKOON} = 'Thread';

$translation{S_NOPOMF} = 'POMF';
$translation{S_NOPOMFDESC} = 'Don\'t upload files to an external server';

$translation{S_THREADLOCKED} = '<strong>Thread %s</strong> is locked. You may not reply to this thread.';
$translation{S_FILEINFO} = 'Info';
$translation{S_FILEDELETED} = 'File is deleted';

$translation{S_POSTINFO} = 'IP-Informationen';
$translation{S_MPDELETEIP} = 'Delete all';
$translation{S_MPDELETE} = 'Delete';
  # Defines for deletion button in Management Panel
$translation{S_MPEDIT} = 'Edit';
  # Defines for deletion button in Management Panel
$translation{S_MPDELFILE} = 'Remove file';
$translation{S_MPARCHIVE} = 'Archive';
$translation{S_MPSTICKY} = 'Sticky';
$translation{S_MPUNSTICKY} = 'Unsticky';
$translation{S_MPLOCK} = 'Lock thread';
$translation{S_MPUNLOCK} = 'Unlock thread';
$translation{S_MPRESET} = 'Reset';
  # Defines name for field reset button in Management Panel
$translation{S_MPRESTORE} = 'Restore';
$translation{S_MPONLYPIC} = 'File Only';
  # Sets whether or not to delete only file, or entire post/thread
$translation{S_MPDELETEALL} = 'Delete&nbsp;All&nbsp;Posts&nbsp;from&nbsp;this&nbsp;IP';    #
$translation{S_MPBAN} = 'Ban';
  # Sets whether or not to delete only file, or entire post/thread
$translation{S_MPTABLE} =
    '<th>No.</th><th>Date</th><th>Subject</th>'
  . '<th>Name</th><th>Comment</th><th>IP</th>';
    # Explains names for Management Panel
$translation{S_IMGSPACEUSAGE} = '[ Space used: %s, %s Files, %s Posts (%s Threads) ]'
  ;          # Prints space used KB by the board under Management Panel
$translation{S_DELALLMSG} = 'Affected';
$translation{S_DELALLCOUNT} = '%s Posts (%s Threads)';

$translation{S_BANFILTER} = 'Hide expired bans';
$translation{S_BANSHOWALL} = 'Shwo expired bans';
$translation{S_BANTABLE} = 
  '<th>Type</th><th colspan="2">Value</th><th>Comment</th><th>Date</th><th>Expires</th><th>Action</th>';
    # Explains names for Ban Panel
$translation{S_BANIPLABEL} = 'IP';
$translation{S_BANMASKLABEL} = 'Mask';
$translation{S_BANCOMMENTLABEL} = 'Comment';
$translation{S_BANWORDLABEL} = 'Word';
$translation{S_BANIP} = 'IP ban';
$translation{S_BANWORD} = 'Wordfilter';
$translation{S_BANWHITELIST} = 'Whitelist';
$translation{S_BANREMOVE} = 'Remove';
$translation{S_BANEDIT} = 'Edit';
$translation{S_BANCOMMENT} = 'Comment';
$translation{S_BANTRUST} = 'Kein Captcha';
$translation{S_BANTRUSTTRIP} = 'Tripcode';
$translation{S_BANEXPIRESLABEL} = 'Истекает';
$translation{S_BANEXPIRESDESC} = '5 Days, 10 Hours, 30 Minutes, etc<br />Permaban - leave field empty';
$translation{S_BANREASONLABEL} = 'Reason';
$translation{S_BANASNUMLABEL} = 'AS number';
$translation{S_BANASNUM} = 'Ban ASnet';
$translation{S_BANSECONDS} = 'Seconds';

$translation{S_ORPHTABLE} = '<th>Link</th><th>File</th><th>Modify&nbsp;date</th><th>Size</th>';
$translation{S_MANASHOW} = 'Show';

$translation{S_LOCKED} = 'Thread is locked';
$translation{S_BADIP} = 'Falsche IP-Adresse';
$translation{S_BADDELIP} = 'Fehler: Falsche IP.'
  ;    # Returns error for wrong ip (when user tries to delete file)
$translation{S_INVALID_PAGE} = "page not found.";
$translation{S_STOP_FOOLING} = "Lass das sein, Kevin!";

$translation{S_SPAMEXPL} = 'This is the list of domain names Wakaba considers to be spam.<br />'.
  'You can find an up-to-date version <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&amp;format=wakaba">here</a>, '.
  'or you can get the <code>spam.txt</code> file directly <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a>.';

$translation{S_TOOBIG} = 'This image is too large!  Upload something smaller!';
$translation{S_TOOBIGORNONE} = 'Either this image is too big or there is no image at all.  Yeah.';
$translation{S_REPORTERR} = 'Cannot find reply.';          # Returns error when a reply (res) cannot be found
$translation{S_UPFAIL} = 'Upload failed.';             # Returns error for failed upload (reason: unknown?)
$translation{S_NOREC} = 'Cannot find record.';           # Returns error when record cannot be found
$translation{S_NOCAPTCHA} = 'No verification code on record - it probably timed out.'; # Returns error when there's no captcha in the database for this IP/key
$translation{S_BADCAPTCHA} = 'Wrong verification code entered.';   # Returns error when the captcha is wrong
$translation{S_BADFORMAT} = 'File format not supported.';      # Returns error when the file is not in a supported format.
$translation{S_STRREF} = 'String refused.';              # Returns error when a string is refused
$translation{S_UNJUST} = 'Unjust POST.';               # Returns error on an unjust POST - prevents floodbots or ways not using POST method?
$translation{S_NOPIC} = 'No file selected. Did you forget to click "Reply"?';  # Returns error for no file selected and override unchecked
$translation{S_NOTEXT} = 'No comment entered.';            # Returns error for no text entered in to subject/comment
$translation{S_TOOLONG} = 'Too many characters in text field.';    # Returns error for too many characters in a given field
$translation{S_NOTALLOWED} = 'Posting not allowed.';         # Returns error for non-allowed post types
$translation{S_NOPOSTING} = 'Posting is temporarily disable.';
$translation{S_UNUSUAL} = 'Abnormal reply.';             # Returns error for abnormal reply? (this is a mystery!)
$translation{S_BADHOST} = 'Host is banned.';             # Returns error for banned host ($badip string)
$translation{S_BADHOSTPROXY} = 'Proxy is banned for being open.';  # Returns error for banned proxy ($badip string)
$translation{S_RENZOKU} = 'Flood detected, post discarded.';     # Returns error for $sec/post spam filter
$translation{S_RENZOKU2} = 'Flood detected, file discarded.';    # Returns error for $sec/upload spam filter
$translation{S_RENZOKU3} = 'Flood detected.';            # Returns error for $sec/similar posts spam filter.
$translation{S_RENZOKU4} = 'Post removal period hasn\'t yet expired.';
$translation{S_RENZOKU5} = 'Flood detected. Please wait.';
$translation{S_PROXY} = 'Open proxy detected.';            # Returns error for proxy detection.
$translation{S_DUPE} = 'This file has already been posted <a href="%s">here</a>.'; # Returns error when an md5 checksum already exists.
$translation{S_DUPENAME} = 'A file with the same name already exists.';  # Returns error when an filename already exists.
$translation{S_NOTHREADERR} = 'Thread does not exist.';        # Returns error when a non-existant thread is accessed
$translation{S_BADDELPASS} = 'Incorrect password for deletion.';   # Returns error for wrong password (when user tries to delete file)
$translation{S_WRONGPASS} = 'Management password incorrect.';    # Returns error for wrong password (when trying to access Manager modes)
$translation{S_VIRUS} = 'Possible virus-infected file.';       # Returns error for malformed files suspected of being virus-infected.
$translation{S_NOTWRITE} = 'Could not write to directory.';        # Returns error when the script cannot write to the directory, the chmod (777) is wrong
$translation{S_SPAM} = 'Spammers are not welcome here.';          # Returns error when detecting spam
$translation{S_NOBOARDACC} = 'You don\'t have access to this board, accessible: %s<br /><a href="%s?task=logout">Logout</a>';

$translation{S_SQLCONF} = 'MySQL-Database error'; # Database connection failure
$translation{S_SQLFAIL} = 'MySQL-Database error'; # SQL Failure

$translation{S_EDITPOST} = 'Edit post';
$translation{S_EDITHEAD} = 'Editing No.<a href="%s">%d</a>';
$translation{S_UPDATE} = 'Update';

$translation{S_REDIR} =
  'If the redirect didn\'t work, please choose one of the following mirrors:'
  ;    # Redir message for html in REDIR_DIR

$translation{S_DNSBL} =
  'This IP was listed in <em>%s</em> blacklist!';    # error string for tor node check

\%translation;
