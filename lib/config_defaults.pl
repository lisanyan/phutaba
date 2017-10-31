use strict;

BEGIN {
	# use constant S_NOADMIN => 'No ADMIN_PASS or NUKE_PASS defined in the configuration';
	    # Returns error when the config is incomplete
	use constant S_NOSECRET => 'No SECRET defined in the configuration';
	    # Returns error when the config is incomplete
	use constant S_NOSQL => 'No SQL settings defined in the configuration';
	    # Returns error when the config is incomplete

	# die S_NOADMIN  unless ( defined &ADMIN_PASS );
	die S_NOSECRET unless ( defined &SECRET );
	die S_NOSQL    unless ( defined &SQL_DBI_SOURCE );
	die S_NOSQL    unless ( defined &SQL_USERNAME );
	die S_NOSQL    unless ( defined &SQL_PASSWORD );

	eval "use constant USE_TEMPFILES => 1" unless ( defined &USE_TEMPFILES );

	eval "use constant TRACKING_CODE => ''" unless ( defined &TRACKING_CODE );
	eval "use constant DEFAULT_BOARD => 'b'" unless ( defined &DEFAULT_BOARD );
	eval "use constant BOARD_LOCALES => [qw/ru en de/]" unless ( defined &BOARD_LOCALES );

	eval "use constant CHARSET => 'UTF-8'" unless ( defined &CHARSET );
	eval "use constant CONVERT_CHARSETS => 1" unless ( defined &CONVERT_CHARSETS );

	eval "use constant ERRORLOG => ''" unless ( defined &ERRORLOG );

	eval "use constant USE_PARSEDATE => 0" unless ( defined &USE_PARSEDATE );
}

1;
