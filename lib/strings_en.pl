use utf8;
use constant S_HOME   => 'Home';           # Forwards to home page
use constant S_ADMIN  => 'Manage';         # Forwards to Management Panel
use constant S_RETURN => 'Return';    # Returns to image board
use constant S_POSTING =>
  'Reply mode';    # Prints message in red bar atop the reply screen

use constant S_NAME       => 'Name';           # Describes name field
use constant S_EMAIL      => 'E-Mail';         # Describes e-mail field
use constant S_SUBJECT    => 'Subject';        # Describes subject field
use constant S_SUBMIT     => 'Submit';     # Describes submit button
use constant S_COMMENT    => 'Comment';      # Describes comment field
use constant S_UPLOADFILE => 'File';          # Describes file field
use constant S_NOFILE     => 'No File';    # Describes file/no file checkbox
use constant S_CAPTCHA    => 'Captcha';        # Describes captcha field
use constant S_PARENT =>
  'Thread #';    # Describes parent field on admin post page
use constant S_DELPASS => 'Password';    # Describes password field
use constant S_DELEXPL =>
  '(Optional)';    # Prints explanation for password box (to the right)
use constant S_SPAMTRAP => '';
use constant S_ALLOWED => 'Allowed file formats (max. %s or given)';

use constant S_THUMB => '';    # Prints instructions for viewing real source
use constant S_HIDDEN => '';    # Prints instructions for viewing hidden image reply
use constant S_NOTHUMB =>
  'File';    # Printed when there's no thumbnail
use constant S_PICNAME => '';             # Prints text before upload name/link
use constant S_REPLY   => 'Reply';    # Prints text for reply link
use constant S_OLD => 'Marked for deletion (old).'; 
  # Prints text to be displayed before post is marked for deletion, see: retention

use constant S_HIDE => 'Thread %d ausblenden';

use constant S_ABBR1 => '1 Post ';				# Prints text to be shown when replies are hidden
use constant S_ABBR2 => '%d Posts ';
use constant S_ABBRIMG1 => 'and 1 File ';		# Prints text to be shown when replies and files are hidden
use constant S_ABBRIMG2 => 'and %d Files ';
use constant S_ABBR_END => 'hidden.'; 

use constant S_ABBRTEXT1 => 'Expand full post (+1 line)';
use constant S_ABBRTEXT2 => 'Expand full post (+%d lines)';

use constant S_BANNED  => '<p class="ban">(User was banned for this post)</p>';

use constant S_REPDEL => ' ';    # Prints text next to S_DELPICONLY (left)
use constant S_DELPICONLY => '';    # Prints text next to checkbox for file deletion (right)
use constant S_DELKEY => 'Password ';    # Prints text next to password field for deletion (left)
use constant S_DELETE => 'Delete';    # Defines deletion button's name

use constant S_PREV => 'Previous';                  # Defines previous button
use constant S_FIRSTPG => 'Previous';               # Defines previous button
use constant S_NEXT => 'Next';                    # Defines next button
use constant S_LASTPG => 'Next';                  # Defines next button
use constant S_TOP     => 'Top';

use constant S_SEARCHTITLE		=> 'Search';
use constant S_SEARCH			=> 'Search';
use constant S_SEARCHCOMMENT	=> 'Search in comments';
use constant S_SEARCHSUBJECT	=> 'Search in subject';
use constant S_SEARCHFILES		=> 'Search by files';
use constant S_SEARCHOP			=> 'Search only in OP-posts';
use constant S_SEARCHSUBMIT		=> 'Search';
use constant S_SEARCHFOUND		=> 'Found:';
use constant S_OPTIONS			=> 'Options';
use constant S_MINLENGTH		=> '(min. 3 symbols)';

use constant S_WEEKDAYS => ('Sun','Mon','Tue','Wed','Thu','Fri','Sat'); # Defines abbreviated weekday names.

use constant S_STICKYTITLE => 'Sticky thread';    # Defines the title of the tiny sticky image on a thread if it is sticky
use constant S_LOCKEDTITLE => 'Locked thread';    # Defines the title of the tiny locked image on a thread if it is locked

# javascript message strings (do not use HTML entities; mask single quotes with \\\')
use constant S_JS_EXPAND => 'Expand textfield';
use constant S_JS_SHRINK => 'Shrink textfield';
use constant S_JS_REMOVEFILE => 'Remove file';
use constant S_JS_STYLES => 'Styles';
# javascript strings END

use constant S_MANARET => 'Return';    # Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
use constant S_MANAMODE => 'Administration';   # Prints heading on top of Manager page

use constant S_MANALOGIN => 'Login';
 # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_ADMINPASS => 'Password:';    # Prints login prompt

use constant S_MANAPANEL => 'Management Panel'
; # Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_MANATOOLS => 'Tools';
use constant S_MANAGEOINFO => 'GeoIP-Information';
use constant S_MANABANS    => 'Bans';         # Defines Bans Panel button
use constant S_MANAPROXY   => 'Proxy';
use constant S_MANAORPH => 'Orphans';
use constant S_MANALOGOUT  => 'Logout';
use constant S_MANASAVE => 'Remember me';    # Defines Label for the login cookie checbox
use constant S_MANASUB => 'Go';          # Defines name for submit button in Manager Mode
use constant S_MANALOG  => 'Log';

use constant S_NOTAGS => '<p>HTML tags are also possible. No WakabaMark.</p>'
  ;               # Prints message on Management Board

use constant S_POSTASADMIN => 'Post with an admin mark';
use constant S_NOTAGS2 => 'Comment willn\'t be processed through parser.';
use constant S_MPSETSAGE => 'Toggle Sage';
use constant S_MPUNSETSAGE => 'Toggle Sage';

use constant S_BTNEWTHREAD => 'Creat new thread';
use constant S_BTREPLY => 'Reply to';
use constant S_SAGE => 'Sage';
use constant S_SAGEDESC => 'Don\'t bump this thread'; # 'Thread has reached bump-limit';
use constant S_IMGEXPAND => 'Expand text field';
use constant S_NOKO => 'Go to';
use constant S_NOKOOFF => 'Board';
use constant S_NOKOON => 'Thread';

use constant S_NOPOMF => 'POMF';
use constant S_NOPOMFDESC => 'Don\'t upload files to an external server';

use constant S_THREADLOCKED => '<strong>Thread %s</strong> is locked. You may not reply to this thread.';
use constant S_FILEINFO => 'Info';
use constant S_FILEDELETED => 'File is deleted';

use constant S_POSTINFO => 'IP-Informationen';
use constant S_MPDELETEIP => 'Delete all';
use constant S_MPDELETE =>
  'Delete';    # Defines for deletion button in Management Panel
use constant S_MPEDIT => 'Edit';    # Defines for deletion button in Management Panel
use constant S_MPDELFILE  => 'Remove file';
use constant S_MPARCHIVE  => 'Archive';
use constant S_MPSTICKY   => 'Sticky';
use constant S_MPUNSTICKY => 'Unsticky';
use constant S_MPLOCK     => 'Lock thread';
use constant S_MPUNLOCK   => 'Unlock thread';
use constant S_MPRESET =>
  'Reset';        # Defines name for field reset button in Management Panel
use constant S_MPONLYPIC =>
  'File Only';  # Sets whether or not to delete only file, or entire post/thread
use constant S_MPDELETEALL => 'Delete&nbsp;All&nbsp;Posts&nbsp;from&nbsp;this&nbsp;IP';    #
use constant S_MPBAN =>
  'Ban';    # Sets whether or not to delete only file, or entire post/thread
use constant S_MPTABLE => '<th>No.</th><th>Date</th><th>Subject</th>'
  . '<th>Name</th><th>Comment</th><th>IP</th>'
  ;          # Explains names for Management Panel
use constant S_IMGSPACEUSAGE => '[ Space used: %s, %s Files, %s Posts (%s Threads) ]'
  ;          # Prints space used KB by the board under Management Panel
use constant S_DELALLMSG => 'Affected';
use constant S_DELALLCOUNT => '%s Posts (%s Threads)';

use constant S_BANFILTER => 'Hide expired bans';
use constant S_BANSHOWALL => 'Shwo expired bans';
use constant S_BANTABLE =>
  '<th>Type</th><th colspan="2">Value</th><th>Comment</th><th>Date</th><th>Expires</th><th>Action</th>'
  ;          # Explains names for Ban Panel
use constant S_BANIPLABEL      => 'IP';
use constant S_BANMASKLABEL    => 'Mask';
use constant S_BANCOMMENTLABEL => 'Comment';
use constant S_BANWORDLABEL    => 'Word';
use constant S_BANIP           => 'IP ban';
use constant S_BANWORD         => 'Wordfilter';
use constant S_BANWHITELIST    => 'Whitelist';
use constant S_BANREMOVE       => 'Remove';
use constant S_BANCOMMENT      => 'Comment';
use constant S_BANTRUST        => 'Kein Captcha';
use constant S_BANTRUSTTRIP    => 'Tripcode';
use constant S_BANEXPIRESLABEL => 'Истекает';
use constant S_BANEXPIRESDESC  => 'Example: 5 Days, 10 Hours, 30 Minutes<br />Permaban - leave field empty';
use constant S_BANREASONLABEL => 'Причина';
use constant S_BANASNUMLABEL => 'AS number';
use constant S_BANASNUM => 'Ban ASnet';
use constant S_BANSECONDS => 'Seconds';

use constant S_ORPHTABLE     => '<th>Link</th><th>File</th><th>Modify&nbsp;date</th><th>Size</th>';
use constant S_MANASHOW      => 'Show';

use constant S_LOCKED => 'Thread is locked';
use constant S_BADIP         => 'Falsche IP-Adresse';
use constant S_BADDELIP      => 'Fehler: Falsche IP.'
  ;    # Returns error for wrong ip (when user tries to delete file)
use constant S_INVALID_PAGE => "Error: page not found.";
use constant S_STOP_FOOLING => "Lass das sein, Kevin!";

use constant S_SPAMEXPL => 'This is the list of domain names Wakaba considers to be spam.<br />'.
  'You can find an up-to-date version <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&amp;format=wakaba">here</a>, '.
  'or you can get the <code>spam.txt</code> file directly <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a>.';

use constant S_TOOBIG => 'This image is too large!  Upload something smaller!';
use constant S_TOOBIGORNONE => 'Either this image is too big or there is no image at all.  Yeah.';
use constant S_REPORTERR => 'Error: Cannot find reply.';          # Returns error when a reply (res) cannot be found
use constant S_UPFAIL => 'Error: Upload failed.';             # Returns error for failed upload (reason: unknown?)
use constant S_NOREC => 'Error: Cannot find record.';           # Returns error when record cannot be found
use constant S_NOCAPTCHA => 'Error: No verification code on record - it probably timed out.'; # Returns error when there's no captcha in the database for this IP/key
use constant S_BADCAPTCHA => 'Error: Wrong verification code entered.';   # Returns error when the captcha is wrong
use constant S_BADFORMAT => 'Error: File format not supported.';      # Returns error when the file is not in a supported format.
use constant S_STRREF => 'Error: String refused.';              # Returns error when a string is refused
use constant S_UNJUST => 'Error: Unjust POST.';               # Returns error on an unjust POST - prevents floodbots or ways not using POST method?
use constant S_NOPIC => 'Error: No file selected. Did you forget to click "Reply"?';  # Returns error for no file selected and override unchecked
use constant S_NOTEXT => 'Error: No comment entered.';            # Returns error for no text entered in to subject/comment
use constant S_TOOLONG => 'Error: Too many characters in text field.';    # Returns error for too many characters in a given field
use constant S_NOTALLOWED => 'Error: Posting not allowed.';         # Returns error for non-allowed post types
use constant S_NONEWTHREADS => 'Error: New threads can not be created.';
use constant S_UNUSUAL => 'Error: Abnormal reply.';             # Returns error for abnormal reply? (this is a mystery!)
use constant S_BADHOST => 'Error: Host is banned.';             # Returns error for banned host ($badip string)
use constant S_BADHOSTPROXY => 'Error: Proxy is banned for being open.';  # Returns error for banned proxy ($badip string)
use constant S_RENZOKU => 'Error: Flood detected, post discarded.';     # Returns error for $sec/post spam filter
use constant S_RENZOKU2 => 'Error: Flood detected, file discarded.';    # Returns error for $sec/upload spam filter
use constant S_RENZOKU3 => 'Error: Flood detected.';            # Returns error for $sec/similar posts spam filter.
use constant S_RENZOKU4 => 'Error: Post removal period hasn\'t yet expired.';
use constant S_RENZOKU5 => 'Error: Flood detected. Please wait.';
use constant S_PROXY => 'Error: Open proxy detected.';            # Returns error for proxy detection.
use constant S_DUPE => 'Error: This file has already been posted <a href="%s">here</a>.'; # Returns error when an md5 checksum already exists.
use constant S_DUPENAME => 'Error: A file with the same name already exists.';  # Returns error when an filename already exists.
use constant S_NOTHREADERR => 'Error: Thread does not exist.';        # Returns error when a non-existant thread is accessed
use constant S_BADDELPASS => 'Error: Incorrect password for deletion.';   # Returns error for wrong password (when user tries to delete file)
use constant S_WRONGPASS => 'Error: Management password incorrect.';    # Returns error for wrong password (when trying to access Manager modes)
use constant S_VIRUS => 'Error: Possible virus-infected file.';       # Returns error for malformed files suspected of being virus-infected.
use constant S_NOTWRITE => 'Error: Could not write to directory.';        # Returns error when the script cannot write to the directory, the chmod (777) is wrong
use constant S_SPAM => 'Spammers are not welcome here.';          # Returns error when detecting spam
use constant S_NOBOARDACC => 'You don\'t have access to this board, accessible: %s<br /><a href="%s?task=logout">Logout</a>';

use constant S_SQLCONF => 'MySQL-Database error'; # Database connection failure
use constant S_SQLFAIL => 'MySQL-Database error'; # SQL Failure

use constant S_EDITPOST => 'Edit post';
use constant S_EDITHEAD => 'Editing No.<a href="%s">%d</a>';
use constant S_UPDATE => 'Update';

use constant S_REDIR =>
  'If the redirect didn\'t work, please choose one of the following mirrors:'
  ;    # Redir message for html in REDIR_DIR

use constant S_DNSBL =>
  'Error: TOR nodes are not allowed!';    # error string for tor node check

1;

