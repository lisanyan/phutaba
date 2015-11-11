# Set up settings hashes
my (%settings, %boards);
use utf8;

# System config
$settings{SQL_TABLE_IMG} = 'board_img';		 # Table (NOT DATABASE) used by image board for secondary images
$settings{SQL_TABLE} = 'board';				 # Table (NOT DATABASE) used by image board
$settings{SQL_ADMIN_TABLE} = 'admin';		 # Table used for admin information
$settings{SQL_BACKUP_TABLE} = 'waka_backup'; # Table used for backups
$settings{SQL_BACKUP_IMG_TABLE} = 'waka_backup_img'; # Table used for image backups
$settings{SQL_LOG_TABLE} = 'modlog';		# Table used for mod log
$settings{BOARD_ENABLED} = 1;
$settings{BOARD_LOCALE} = 'locale_ru';		# Locale used for board, currently available translations: (ru, en, de)
$settings{DISABLE_POSTING} = 0;
$settings{ENABLE_AFMOD} = 1;
$settings{ENABLE_HIDE_THREADS} = 1;
$settings{ENABLE_POST_BACKUP} = 1;
$settings{ENABLE_WEBSOCKET_NOTIFY} = 0;

# Page look
$settings{TITLE} = 'Gay bar';	# Name of this image board
$settings{BOARD_NAME} = 'Dildo dodo';
$settings{BOARD_DESC} = 0;
$settings{ENABLE_BANNERS} = 1;
$settings{SHOWTITLETXT} = 1;				# Show TITLE at top (1: yes  0: no)
$settings{SHOWTITLEIMG} = 0;				# Show image at top (0: no, 1: single, 2: rotating)
$settings{TITLEIMG} = 'title.jpg';			# Title image (point to a script file if rotating)
$settings{FAVICON} = '';					# Favicon.ico file
$settings{HOME} = '/'; 						# Site home directory (up one level by default)
$settings{SSL_ICON} = ''; # '/img/icons/ssl.png';
$settings{SHOW_COUNTRIES} = 0;
$settings{IMAGES_PER_PAGE} = 12;			# Images per page
$settings{REPLIES_PER_THREAD} = 4;			# Replies shown
# Currently doesn't work, i will fix this later...
# $settings{IMAGE_REPLIES_PER_THREAD} = 0;	# Number of image replies per thread to show, set to 0 for no limit.
$settings{REPLIES_PER_STICKY_THREAD} = 2; # Replies shown per sticky thread
$settings{REPLIES_PER_LOCKED_THREAD} = 1; # Replies shown per sticky thread
$settings{ENTRIES_PER_LOGPAGE} = 50;
$settings{S_ANONAME} = 'Аноним';			# Defines what to print if there is no text entered in the name field
$settings{S_ANOTEXT} = '';					# Defines what to print if there is no text entered in the comment field
$settings{S_ANOTITLE} = '';					# Defines what to print if there is no text entered into subject field
$settings{SILLY_ANONYMOUS} = '';			# Make up silly names for anonymous people (0 or '': don't display, any combination of 'day' or 'board': make names change for each day or board, 'static': static names)
$settings{PREVENT_GHOST_BUMPING} = 1;
$settings{ADMIN_EMAIL} = 'admin@host.local';
$settings{ENABLE_RSS} = 1;
$settings{RSS_LENGTH} = 10;

# Limitations
$settings{MAX_FILES} = 4;					# Maximum file uploads per post	
$settings{MAX_KB} = 10240;					# Maximum upload size in KB
$settings{MAX_W} = 200;						# Images exceeding this width will be thumbnailed
$settings{MAX_H} = 200;						# Images exceeding this height will be thumbnailed
$settings{MAX_RES} = 500;					# Maximum topic bumps
$settings{MAX_POSTS} = 0;					# Maximum number of posts (set to 0 to disable)
$settings{MAX_THREADS} = 500;				# Maximum number of threads (set to 0 to disable)
$settings{MAX_SHOWN_THREADS} = 120;
$settings{MAX_SEARCH_RESULTS} = 200;
$settings{MAX_AGE} = 0;						# Maximum age of a thread in hours (set to 0 to disable)
$settings{MAX_MEGABYTES} = 0;				# Maximum size to use for all images in megabytes (set to 0 to disable)
$settings{MAX_FIELD_LENGTH} = 100;			# Maximum number of characters in subject, name, and email
$settings{MAX_COMMENT_LENGTH} = 8192;		# Maximum number of characters in a comment
$settings{MAX_LINES_SHOWN} = 15;			# Max lines shown per post (0 = no limit)
$settings{MAX_IMAGE_WIDTH} = 50000000000;			# Maximum width of image before rejecting
$settings{MAX_IMAGE_HEIGHT} = 50000000000;		# Maximum height of image before rejecting
$settings{MAX_IMAGE_PIXELS} = 50000000000;		# Maximum width*height of image before rejecting

# Captcha
$settings{CAPTCHA_MODE} = 2;
$settings{CAPTCHA_SKIP} = 'DE NO CH AT LI BE LU DK NL FI EE RU UA BY KZ PL EU';
$settings{CAPTCHA_SCRIPT} = 'captcha.pl';
$settings{SQL_CAPTCHA_TABLE} = 'captcha';
$settings{CAPTCHA_LIFETIME} = 1440;
$settings{CAPTCHA_HEIGHT} = 18;
$settings{CAPTCHA_SCRIBBLE} = 0.2;
$settings{CAPTCHA_SCALING} = 0.15;
$settings{CAPTCHA_ROTATION} = 0.3;
$settings{CAPTCHA_SPACING} = 2.5;

# Tweaks
$settings{THUMBNAIL_SMALL} = 1;				# Thumbnail small images (1: yes, 0: no)
$settings{THUMBNAIL_QUALITY} = 85;			# Thumbnail JPEG quality
$settings{DELETED_THUMBNAIL} = '';			# Thumbnail to show for deleted images (leave empty to show text message)
$settings{DELETED_IMAGE} = '';				# Image to link for deleted images (only used together with DELETED_THUMBNAIL)
$settings{ALLOW_TEXTONLY} = 0;				# Allow textonly posts (1: yes, 0: no)
$settings{ALLOW_IMAGES} = 1;				# Allow image posting (1: yes, 0: no)
$settings{ALLOW_TEXT_REPLIES} = 1;			# Allow replies (1: yes, 0: no)
$settings{ALLOW_IMAGE_REPLIES} = 1;			# Allow replies with images (1: yes, 0: no)
$settings{ALLOW_UNKNOWN} = 0;				# Allow unknown filetypes (1: yes, 0: no)
$settings{MUNGE_UNKNOWN} = '.unknown';		# Munge unknown file type extensions with this. If you remove this, make sure your web server is locked down properly.
$settings{FORBIDDEN_EXTENSIONS} = ['php','php3','php4','phtml','shtml','cgi','pl','pm','py','r','exe','dll','scr','pif','asp','cfm','jsp','vbs']; # file extensions which are forbidden
$settings{RENZOKU} = 5;						# Seconds between posts (floodcheck)
$settings{RENZOKU2} = 10;					# Seconds between image posts (floodcheck)
$settings{RENZOKU3} = 900;					# Seconds between identical posts (floodcheck)
$settings{RENZOKU4} = 60;					# Seconds between deletion (floodcheck)
$settings{RENZOKU5} = 600;					# Seconds between identical posts (threads) (floodcheck)
$settings{NOSAGE_WINDOW} = 1200;			# Seconds that you can post to your own thread without increasing the sage count
$settings{USE_SECURE_ADMIN} = 0;			# Use HTTPS for the admin panel.
$settings{TRIM_METHOD} = 0;					# Which threads to trim (0: oldest - like futaba 1: least active - furthest back)
$settings{ARCHIVE_MODE} = 0;				# Old images and posts are moved into an archive dir instead of deleted (0: no 1: yes). It is HIGHLY RECOMMENDED you use TRIM_METHOD => 1 with this, or you may end up with unreferenced pictures in your archive
$settings{DATE_STYLE} = 'futaba';			# Date style ('futaba', '2ch', 'localtime', 'tiny')
# $settings{DISPLAY_ID} = 'day';			 	# How to display user IDs (0 or '': don't display,
												#  'day' and 'board' in any combination: make IDs change for each day or board,
												#  'mask': display masked IP address (similar IPs look similar, but are still encrypted)
												#  'sage': don't display ID when user sages, 'link': don't display ID when the user fills out the link field,
												#  'ip': display user's IP, 'host': display user's host)
$settings{DISPLAY_ID} = 0;					# Display user IDs (0: never, 1: if no email, 2:always)
$settings{EMAIL_ID} = 'Ernst';				# ID string to use when DISPLAY_ID is 1 and the user uses an email.
$settings{TRIPKEY} = '!';					# this character is displayed before tripcodes
$settings{DECIMAL_MARK} = ',';
$settings{ENABLE_WAKABAMARK} = 0;			# Enable WakabaMark formatting. (0: no, 1: yes)
$settings{ENABLE_BBCODE} = 1;				# Enable bbCode formatting. (0: no, 1: yes)
$settings{APPROX_LINE_LENGTH} = 150;		# Approximate line length used by reply abbreviation code to guess at the length of a reply.
$settings{STUPID_THUMBNAILING} = 0;			# Bypass thumbnailing code and just use HTML to resize the image. STUPID, wastes bandwidth. (1: enable, 0: disable)
$settings{COOKIE_PATH} = 'root';			# Path argument for cookies ('root': cookies apply to all boards on the site, 'current': cookies apply only to this board, 'parent': cookies apply to all boards in the parent directory)
$settings{FORCED_ANON} = 0;					# Force anonymous posting (0: no, 1: yes)
$settings{ENABLE_RANDOM_NAMES} = 0;
$settings{RANDOM_NAMES} = [ qw(Adolf Anna Anneliese Alex Alexander Arne Berta Bertha Burkhard Charlotte Clara Klara Edith Elfriede Elisabeth Ella Else Emma Erika Erna Ernst Ernsthard Frieda Frida Felix Gerda Gertrud Gisela Hedwig Helene Helga Herta Hertha Hildegard Ida Ilse Ingeborg Irmgard Johanna Kaete Kaethe Lieselotte Liselotte Louise Luise Margarethe Margarete Margot Maria Marie Marta Martha Ruth Ursula Waltraud Waltraut Alfred Arthur Artur Bruno Carl Christian Claus Curt Erich Ernst Franz Friedrich Fritz Georg Gerhard Guenther Guenter Hans Harry Heinz Helmut Helmuth Herbert Hermann Horst Joachim Karl Carl Karlheinz Kai Karl-Heinz Klaus Claus Kurt Curt Manfred Max Otto Paul Richard Rudolf Walter Werner Wilhelm Willi Willy Wolfgang Andrea Angelika Anja Anke Anna Anne Annett Antje Barbara Birgit Brigitte Christin Christina Christine Cindy Claudia Daniela Diana Doreen Franziska Gabriele Heike Ines Jana Janina Jennifer Jessica Jessika Julia Juliane Karin Karolin Katharina Kathrin Katrin Katja Kerstin Klaudia Claudia Klemens Kristin Christin Laura Lea Lena Lisa Mandy Manuela Maria Marie Marina Martina Melanie Monika Nadine Nicole Petra Sabine Sabrina Sandra Sara Sarah Sascha  Silke Simone Sophia Sophie Stefanie Stephanie Susanne Tanja Ulrike Ursula Uta Ute Vanessa Yvonne Alexander Andreas Benjamin Bernd Christian Daniel David Dennis Dieter Dirk Dominik Eric Erik Felix Florian Frank Jan Jens Jonas Joerg Juergen Kevin Klaus Kristian Christian Leon Lukas Marcel Marco Marko Mario Marion Markus Martin Matthias Max Maximilian Michael Mike Maik Niklas Patrick Paul Peter Philipp Phillipp Ralf Ralph René Robert Sebastian Stefan Stephan Steffen Sven Swen Siegfried Thomas Thorsten Torsten Tim Tobias Tom Ulrich Uwe Vinzent Wolfgang Edeltraud) ];
$settings{STYLESHEETS} = [ qw(Photon Futaba Neutron Kaiserchan) ];
$settings{STYLE_COOKIE} = 'wakastyle';
$settings{ADDITIONAL_CSS} = ''; # code
$settings{ADDITIONAL_RULES} = '';
$settings{ANONYMIZE_IP_ADDRESSES} = 0;
$settings{LOG_EXPIRE} = 3600*24*31;
$settings{POST_BACKUP_EXPIRE} = 3600*24*14;

# Internal paths and files - might as well leave this alone.
$settings{IMG_DIR} = 'src/';				# Image directory (needs to be writeable by the script)
$settings{THUMB_DIR} = 'thumb/';			# Thumbnail directory (needs to be writeable by the script)
$settings{RES_DIR} = 'res/';				# Reply cache directory (needs to be writeable by the script)
$settings{BACKUP_DIR} = 'backup/';
$settings{ORPH_DIR} = 'orphans/';
$settings{REDIR_DIR} = 'redir/';			# Redir directory, used for redirecting clients when load balancing
$settings{HTML_SELF} = 'wakaba.pl';
$settings{JS_FILE} = 'wakaba.js';			# Location of the js file

# More system settings
$settings{CONVERT_COMMAND} = '/usr/bin/convert';
$settings{VIDEO_CONVERT_COMMAND} = '/opt/ffmpeg/ffmpeg-10bit';
$settings{BAN_DATES} = # Ban expiration options to be shown in the admin panel.
[
	{ label=>'Never', time=>0 },
	{ label=>'1 hour', time=>3600 },
	{ label=>'1 day', time=>3600*24 },
	{ label=>'3 days', time=>3600*24*3, default=>1 },
	{ label=>'1 week', time=>3600*24*7 },
	{ label=>'2 weeks', time=>3600*24*14 },
	{ label=>'1 month', time=>3600*24*30 },
	{ label=>'1 year', time=>3600*24*365 }
];
$settings{ENABLE_DNSBL_CHECK} = 1;
$settings{DNSBL_TIMEOUT} = '0.1';
$settings{DNSBL_INFOS} =
[
	[ 'tor.dnsbl.sectoor.de', ['127.0.0.1'] ],
	[ 'torexit.dan.me.uk', ['127.0.0.100'] ],
	# [ 'b.barracudacentral.org', ['127.0.0.2'] ],
	[ 'dnsbl.dronebl.org', ['127.0.0.1', '127.0.0.8', '127.0.0.9', '127.0.0.14'] ],
	[ 'http.dnsbl.sorbs.net', ['127.0.0.2'] ],
	[ 'socks.dnsbl.sorbs.net', ['127.0.0.3'] ],
	# [ 'zen.spamhaus.org', ['127.0.0.2', '127.0.0.3', '127.0.0.4'] ],
];

# Icons for filetypes - file extensions specified here will not be renamed, and will get icons
# (except for the built-in image formats). These example icons can be found in the extras/ directory.
$settings{FILESIZES} = { };
$settings{FILETYPES} = {
	swf => 'other', # Other
	torrent => 'other',
	psd => 'doc', # Doc
	epub => 'doc',
	mobi => 'doc',
	zip => 'archive', # Arch
	rar => 'archive',
	'7z' => 'archive',
	xz => 'archive',
	bz2 => 'archive',
	flac => 'audio', # Aud
	mp3 => 'audio',
	ogg => 'audio',
	wma => 'audio',
	wav => 'audio',
};
$settings{FILEGROUPS} = {
	image => 'Image', #'Bilder'
	video => 'Video',
	archive => 'Archive',
	audio => 'Audio',
	doc => 'Document', #'Dokumente'
	other => 'Other', #'Sonstige'
};
$settings{GROUPORDER} = 'image video archive audio doc other'; # other has to be last
$settings{POMF_EXTENSIONS} = [qw(mp4 webm xz zip flac mp3 wav)];

# board-specific config
$boards{b} = { # sample
	%settings,
	BOARD_NAME => 'Random',
	BOARD_DESC => 'Gay bar',
	SQL_TABLE => 'b_comments',
	SQL_TABLE_IMG => 'b_img',
	MAX_THREADS => 250,
	FORCED_ANON => 1, # k
	DISPLAY_ID => 'board sage',
	SHOW_COUNTRIES => 1,
	ADDITIONAL_RULES => q{<li><strong>Don't be a baka.</strong></li>}
};
$boards{d} = {
	%settings,
	BOARD_NAME => 'Discussions',
	SQL_TABLE => 'd_comments',
	SQL_TABLE_IMG => 'd_img',
	ALLOW_TEXT_REPLIES => 1,
	ALLOW_TEXTONLY => 1,
	ALLOW_IMAGE_REPLIES => 0,
	ALLOW_IMAGES => 0
};

\%boards;
