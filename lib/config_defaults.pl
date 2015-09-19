use strict;

BEGIN {
	use constant S_NOADMIN => 'No ADMIN_PASS or NUKE_PASS defined in the configuration';
	    # Returns error when the config is incomplete
	use constant S_NOSECRET => 'No SECRET defined in the configuration';
	    # Returns error when the config is incomplete
	use constant S_NOSQL => 'No SQL settings defined in the configuration';
	    # Returns error when the config is incomplete

	die S_NOADMIN  unless ( defined &ADMIN_PASS );
	die S_NOSECRET unless ( defined &SECRET );
	die S_NOSQL    unless ( defined &SQL_DBI_SOURCE );
	die S_NOSQL    unless ( defined &SQL_USERNAME );
	die S_NOSQL    unless ( defined &SQL_PASSWORD );

	eval "use constant DISABLE_NEW_THREADS => 0" unless (defined &DISABLE_NEW_THREADS);
	eval "use constant SQL_TABLE => 'comments'" unless ( defined &SQL_TABLE );
	eval "use constant SQL_ADMIN_TABLE => 'admin'" unless ( defined &SQL_ADMIN_TABLE );
	eval "use constant SQL_LOG_TABLE => 'modlog'" unless ( defined &SQL_LOG_TABLE );
	eval "use constant SQL_COUNTERS_TABLE => 'counters'" unless ( defined &SQL_LOG_TABLE );

	eval "use constant USE_TEMPFILES => 1" unless ( defined &USE_TEMPFILES );
	eval "use constant ENABLE_LOCATION => 0" unless ( defined &ENABLE_LOCATION );
	eval "use constant ANONYMIZE_IP_ADDRESSES => 0" unless ( defined &ANONYMIZE_IP_ADDRESSES );
	eval "use constant ENABLE_AFMOD => 1" unless ( defined &ENABLE_AFMOD );

	eval "use constant ENABLE_CAPTCHA => 1" unless ( defined &ENABLE_CAPTCHA );
	eval "use constant SQL_CAPTCHA_TABLE => 'captcha'" unless ( defined &SQL_CAPTCHA_TABLE );
	eval "use constant CAPTCHA_LIFETIME => 1440" unless ( defined &CAPTCHA_LIFETIME );
	eval "use constant CAPTCHA_SCRIPT => 'captcha.pl'" unless ( defined &CAPTCHA_SCRIPT );
	eval "use constant CAPTCHA_HEIGHT => 18" unless ( defined &CAPTCHA_HEIGHT );
	eval "use constant CAPTCHA_SCRIBBLE => 0.2" unless ( defined &CAPTCHA_SCRIBBLE );
	eval "use constant CAPTCHA_SCALING => 0.15" unless ( defined &CAPTCHA_SCALING );
	eval "use constant CAPTCHA_ROTATION => 0.3" unless ( defined &CAPTCHA_ROTATION );
	eval "use constant CAPTCHA_SPACING => 2.5" unless ( defined &CAPTCHA_SPACING );

	eval "use constant TRACKING_CODE => ''" unless ( defined &TRACKING_CODE );
	eval "use constant DEFAULT_BOARD => 'b'" unless ( defined &DEFAULT_BOARD );
	eval "use constant ENABLE_BANNERZ => 1" unless ( defined &ENABLE_BANNERZ );

	eval "use constant CHARSET => 'utf-8'" unless ( defined &CHARSET );
	eval "use constant CONVERT_CHARSETS => 1" unless ( defined &CONVERT_CHARSETS );
	# eval "use constant STYLESHEET => ''" unless (defined &STYLESHEET);
	# eval "use constant FORCED_ANON => 0" unless ( defined &FORCED_ANON );
	# eval "use constant USE_XHTML => 0"   unless ( defined &USE_XHTML );

	eval "use constant ERRORLOG => ''"          unless ( defined &ERRORLOG );
	eval "use constant CONVERT_COMMAND => 'convert'" unless ( defined &CONVERT_COMMAND );
	eval "use constant VIDEO_CONVERT_COMMAND => '/opt/ffmpeg_build/bin/ffmpeg'" unless ( defined &VIDEO_CONVERT_COMMAND );

	eval "use constant ENABLE_RSS => 1" unless (defined &ENABLE_RSS);
	eval "use constant RSS_LENGTH => 10" unless defined (&RSS_LENGTH);
	eval "use constant RSS_WEBMASTER => ''" unless defined (&RSS_WEBMASTER);

	eval "use constant REDIR_DIR = 'redir/'" unless ( defined &REDIR_DIR );
	# eval "use constant ENABLE_RANDOM_NAMES => 0" unless ( defined &ENABLE_RANDOM_NAMES );
	eval "use constant FILETYPES => ()" unless ( defined &FILETYPES );

	eval "use constant USE_PARSEDATE => 0" unless ( defined &USE_PARSEDATE );	
	eval "use constant BAN_DATES => [{label=>'Never',time=>0},{label=>'3 days',time=>3600*24*3},{label=>'1 week',time=>3600*24*7},".
	"{label=>'1 month',time=>3600*24*30},{label=>'1 year',time=>3600*24*365}]" unless(defined &BAN_DATES);

	eval "use constant ENABLE_DNSBL_CHECK => 1" unless(defined &ENABLE_DNSBL_CHECK);
	eval "use constant DNSBL_TIMEOUT => '0.1'" unless(defined &DNSBL_TIMEOUT);
	eval q{use constant DNSBL_INFOS => [
            ['tor.dnsbl.sectoor.de', '127.0.0.1', "tor.dnsbls.sectoor.de"],
            ['torexit.dan.me.uk' ,'127.0.0.100', "torexit.dan.me.uk"], ]} unless(defined &DNSBL_INFOS);
}

1;
