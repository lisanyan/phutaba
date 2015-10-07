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

	eval "use constant USE_TEMPFILES => 1" unless ( defined &USE_TEMPFILES );

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

	eval "use constant CHARSET => 'utf-8'" unless ( defined &CHARSET );
	eval "use constant CONVERT_CHARSETS => 1" unless ( defined &CONVERT_CHARSETS );

	eval "use constant ERRORLOG => ''"          unless ( defined &ERRORLOG );

	eval "use constant USE_PARSEDATE => 0" unless ( defined &USE_PARSEDATE );
}

1;
