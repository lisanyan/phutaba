# Config
use utf8;

# System config
my ( %settings, %boards, %moders ); # hash
use constant ADMIN_PASS => 'SAMPLEPSAA';			# Admin password. For fucks's sake, change this.
use constant SECRET => 'SALTSALTSALT';				# Cryptographic secret. CHANGE THIS to something totally random, and long.
use constant SQL_DBI_SOURCE => 'DBI:mysql:database=sampledb;host=127.0.0.1'; # DBI data source string (mysql version, put server and database name in here)
use constant SQL_USERNAME => 'sampleuser';		# MySQL login name
use constant SQL_PASSWORD => 'samplepass';		# MySQL password
use constant DEFAULT_BOARD => 'b';	# default board to redirect to from /
use constant ENABLE_BANNERZ => 1; 		# enable or disable banner images
use constant USE_TEMPFILES => 1;				# Set this to 1 under Unix and 0 under Windows! (Use tempfiles when creating pages)
use constant TRACKING_CODE => q{<!-- some tracking code -->};

# Char
use constant CHARSET => 'utf-8';				# Character set to use, typically 'utf-8' or 'shift_jis'. Disable charset handling by setting to ''. Remember to set Apache to use the same character set for .html files! (AddCharset shift_jis html)
use constant CONVERT_CHARSETS => 1;			# Do character set conversions internally

# use constant ERRORLOG => '';					# Writes out all errors seen by user, mainly useful for debugging
use constant CONVERT_COMMAND => 'convert';		# location of the ImageMagick convert command (usually just 'convert', but sometime a full path is needed)
# use constant CONVERT_COMMAND => '/usr/X11R6/bin/convert';
use constant VIDEO_CONVERT_COMMAND => '/opt/ffmpeg/ffmpeg';

use constant ENABLE_DNSBL_CHECK => 1;
use constant DNSBL_TIMEOUT => '0.1';
use constant DNSBL_INFOS => [
            ['tor.dnsbl.sectoor.de', '127.0.0.1', "tor.dnsbls.sectoor.de"],
            ['torexit.dan.me.uk' ,'127.0.0.100', "torexit.dan.me.uk"], ];

use constant USE_PARSEDATE => 0;
use constant BAN_DATES => [					# Ban expiration options to show in the admin panel.
	{ label=>'Never', time=>0 },
	{ label=>'1 hour', time=>3600 },
	{ label=>'1 day', time=>3600*24 },
	{ label=>'3 days', time=>3600*24*3, default=>1 },
	{ label=>'1 week', time=>3600*24*7 },
	{ label=>'2 weeks', time=>3600*24*14 },
	{ label=>'1 month', time=>3600*24*30 },
	{ label=>'1 year', time=>3600*24*365 }
];

use constant ENABLE_AFMOD => 1;

no utf8;
1;
