use strict;

BEGIN {
    use constant S_NOADMIN =>
      'No ADMIN_PASS or NUKE_PASS defined in the configuration'
      ;    # Returns error when the config is incomplete
    use constant S_NOSECRET => 'No SECRET defined in the configuration'
      ;    # Returns error when the config is incomplete
    use constant S_NOSQL => 'No SQL settings defined in the configuration'
      ;    # Returns error when the config is incomplete

    die S_NOADMIN  unless ( defined &ADMIN_PASS );
    die S_NOSECRET unless ( defined &SECRET );
    die S_NOSQL    unless ( defined &SQL_DBI_SOURCE );
    die S_NOSQL    unless ( defined &SQL_USERNAME );
    die S_NOSQL    unless ( defined &SQL_PASSWORD );
    eval "use constant ABUSE_EMAIL => ''" unless (defined &ABUSE_EMAIL);
    eval "use constant TRACKING_CODE => ''" unless (defined &TRACKING_CODE);
    eval "use constant DISABLE_NEW_THREADS => 0" unless (defined &DISABLE_NEW_THREADS);
    eval "use constant SQL_TABLE => 'comments'" unless ( defined &SQL_TABLE );
    eval "use constant SQL_ADMIN_TABLE => 'admin'"
      unless ( defined &SQL_ADMIN_TABLE );
    eval "use constant SSL_ICON => '/img/icons/ssl.png'" unless (defined &SSL_ICON);
    eval "use constant USE_TEMPFILES => 1" unless ( defined &USE_TEMPFILES );
    eval "use constant ENABLE_LOCATION => 0"
      unless ( defined &ENABLE_LOCATION );
    eval "use constant TITLE => 'Wakaba image board'" unless ( defined &TITLE );
    eval "use constant SHOWTITLETXT => 1" unless ( defined &SHOWTITLETXT );
    eval "use constant SHOWTITLEIMG => 0" unless ( defined &SHOWTITLEIMG );
    eval "use constant TITLEIMG => 'title.jpg'" unless ( defined &TITLEIMG );
    eval "use constant BOARD_DESC => 0" unless ( defined &BOARD_DESC );
    eval "use constant FAVICON => 'wakaba.ico'" unless ( defined &FAVICON );
    eval "use constant HOME => '../'"           unless ( defined &HOME );
    eval "use constant IMAGES_PER_PAGE => 10"
      unless ( defined &IMAGES_PER_PAGE );
    eval "use constant ANONYMIZE_IP_ADDRESSES => 0"
      unless ( defined &ANONYMIZE_IP_ADDRESSES );
    eval "use constant REPLIES_PER_THREAD => 4"
      unless ( defined &REPLIES_PER_THREAD );
    eval "use constant IMAGE_REPLIES_PER_THREAD => 0"
      unless ( defined &IMAGE_REPLIES_PER_THREAD );
    eval "use constant REPLIES_PER_STICKY_THREAD => 1"
      unless ( defined &REPLIES_PER_STICKY_THREAD );
    eval "use constant IMAGE_REPLIES_PER_STICKY_THREAD => 0"
      unless ( defined &IMAGE_REPLIES_PER_STICKY_THREAD );
    eval "use constant REPLIES_PER_LOCKED_THREAD => 1"
      unless ( defined &REPLIES_PER_LOCKED_THREAD );
    eval "use constant IMAGE_REPLIES_PER_LOCKED_THREAD => 0"
      unless ( defined &IMAGE_REPLIES_PER_LOCKED_THREAD );
    eval "use constant S_ANONAME => 'Anonymous'" unless ( defined &S_ANONAME );
    eval "use constant S_ANOTEXT => ''"          unless ( defined &S_ANOTEXT );
    eval "use constant S_ANOTITLE => ''"         unless ( defined &S_ANOTITLE );
    eval "use constant SILLY_ANONYMOUS => ''"
      unless ( defined &SILLY_ANONYMOUS );
    eval "use constant PREVENT_GHOST_BUMPING => 1"
      unless ( defined &PREVENT_GHOST_BUMPING );
    eval "use constant ENABLE_HIDE_THREADS => 1"
      unless ( defined &ENABLE_HIDE_THREADS );
    eval "use constant ENABLE_AFMOD => 0"
      unless ( defined &ENABLE_AFMOD );
    eval "use constant ENABLE_IRC_NOTIFY => 1"
      unless ( defined &ENABLE_IRC_NOTIFY );
    eval "use constant ENABLE_WEBSOCKET_NOTIFY => 1"
      unless ( defined &ENABLE_WEBSOCKET_NOTIFY );
    eval "use constant IRC_NOTIFY_ON_NEW_THREAD => 1"
      unless ( defined &IRC_NOTIFY_ON_NEW_THREAD );
    eval "use constant IRC_NOTIFY_ON_NEW_POST => 1"
      unless ( defined &IRC_NOTIFY_ON_NEW_POST );
    eval "use constant IRC_NOTIFY_HOST => 'localhost'"
      unless ( defined &IRC_NOTIFY_HOST );
    eval "use constant IRC_NOTIFY_PORT => 8675"
      unless ( defined &IRC_NOTIFY_PORT );
eval "use constant SQL_PREFIX => 'ernstchan_';" unless ( defined &SQL_PREFIX );
    use constant S_IRC_NEW_THREAD_PREPEND => "Neuer Thread auf ";
    use constant S_IRC_BASE_BOARDURL      => "https://ernstchan.com/";
    use constant S_IRC_BASE_THREADURL     => "/thread/";
    use constant S_IRC_NEW_POST_PREPEND   => "Neuer Post in ";
    eval "use constant MAX_KB => 1000"     unless ( defined &MAX_KB );
    eval "use constant MAX_W => 200"       unless ( defined &MAX_W );
    eval "use constant MAX_H => 200"       unless ( defined &MAX_H );
    eval "use constant MAX_RES => 20"      unless ( defined &MAX_RES );
    eval "use constant MAX_POSTS => 500"   unless ( defined &MAX_POSTS );
    eval "use constant MAX_THREADS => 0"   unless ( defined &MAX_THREADS );
    eval "use constant MAX_SHOWN_THREADS => 100" unless (defined &MAX_SHOWN_THREADS);
    eval "use constant MAX_AGE => 0"       unless ( defined &MAX_AGE );
    eval "use constant MAX_MEGABYTES => 0" unless ( defined &MAX_MEGABYTES );
    eval "use constant MAX_FIELD_LENGTH => 100"
      unless ( defined &MAX_FIELD_LENGTH );
    eval "use constant MAX_COMMENT_LENGTH => 8192"
      unless ( defined &MAX_COMMENT_LENGTH );
    eval "use constant MAX_LINES_SHOWN => 15"
      unless ( defined &MAX_LINES_SHOWN );
    eval "use constant MAX_IMAGE_WIDTH => 16384"
      unless ( defined &MAX_IMAGE_WIDTH );
    eval "use constant MAX_IMAGE_HEIGHT => 16384"
      unless ( defined &MAX_IMAGE_HEIGHT );
    eval "use constant MAX_IMAGE_PIXELS => 50000000"
      unless ( defined &MAX_IMAGE_PIXELS );
	eval "use constant MAX_SEARCH_RESULTS => 200" unless (defined &MAX_SEARCH_RESULTS);

    eval "use constant ENABLE_CAPTCHA => 1" unless ( defined &ENABLE_CAPTCHA );
    eval "use constant SQL_CAPTCHA_TABLE => 'captcha'"
      unless ( defined &SQL_CAPTCHA_TABLE );
    eval "use constant CAPTCHA_LIFETIME => 1440"
      unless ( defined &CAPTCHA_LIFETIME );
    eval "use constant CAPTCHA_SCRIPT => 'captcha.pl'"
      unless ( defined &CAPTCHA_SCRIPT );
    eval "use constant CAPTCHA_HEIGHT => 18" unless ( defined &CAPTCHA_HEIGHT );
    eval "use constant CAPTCHA_SCRIBBLE => 0.2"
      unless ( defined &CAPTCHA_SCRIBBLE );
    eval "use constant CAPTCHA_SCALING => 0.15"
      unless ( defined &CAPTCHA_SCALING );
    eval "use constant CAPTCHA_ROTATION => 0.3"
      unless ( defined &CAPTCHA_ROTATION );
    eval "use constant CAPTCHA_SPACING => 2.5"
      unless ( defined &CAPTCHA_SPACING );

    eval "use constant THUMBNAIL_SMALL => 1"
      unless ( defined &THUMBNAIL_SMALL );
    eval "use constant THUMBNAIL_QUALITY => 70"
      unless ( defined &THUMBNAIL_QUALITY );
    eval "use constant DELETED_THUMBNAIL => ''"
      unless ( defined &DELETED_THUMBNAIL );
    eval "use constant DELETED_IMAGE => ''" unless ( defined &DELETED_IMAGE );
    eval "use constant ALLOW_TEXTONLY => 1" unless ( defined &ALLOW_TEXTONLY );
    eval "use constant ALLOW_IMAGES => 1"   unless ( defined &ALLOW_IMAGES );
    eval "use constant ALLOW_TEXT_REPLIES => 1"
      unless ( defined &ALLOW_TEXT_REPLIES );
    eval "use constant ALLOW_IMAGE_REPLIES => 1"
      unless ( defined &ALLOW_IMAGE_REPLIES );
    eval "use constant ALLOW_UNKNOWN => 0" unless ( defined &ALLOW_UNKNOWN );
    eval "use constant MUNGE_UNKNOWN => '.unknown'"
      unless ( defined &MUNGE_UNKNOWN );
    eval
"use constant FORBIDDEN_EXTENSIONS => ('php','php3','php4','phtml','shtml','cgi','pl','pm','py','r','exe','dll','scr','pif','asp','cfm','jsp','rb')"
      unless ( defined &FORBIDDEN_EXTENSIONS );
    eval "use constant RENZOKU => 5"          unless ( defined &RENZOKU );
    eval "use constant RENZOKU2 => 10"        unless ( defined &RENZOKU2 );
    eval "use constant RENZOKU3 => 900"       unless ( defined &RENZOKU3 );
    eval "use constant RENZOKU4 => 60"        unless ( defined &RENZOKU4 );
    eval "use constant NOSAGE_WINDOW => 1200" unless ( defined &NOSAGE_WINDOW );
    eval "use constant USE_SECURE_ADMIN => 0"
      unless ( defined &USE_SECURE_ADMIN );
    eval "use constant CHARSET => 'utf-8'" unless ( defined &CHARSET );
    eval "use constant CONVERT_CHARSETS => 1"
      unless ( defined &CONVERT_CHARSETS );
    eval "use constant TRIM_METHOD => 0"       unless ( defined &TRIM_METHOD );
    eval "use constant DATE_STYLE => 'futaba'" unless ( defined &DATE_STYLE );
    eval "use constant DISPLAY_ID => 0"        unless ( defined &DISPLAY_ID );
    eval "use constant EMAIL_ID => 'Heaven'"   unless ( defined &EMAIL_ID );
    eval "use constant TRIPKEY => '!'"         unless ( defined &TRIPKEY );
    eval "use constant DECIMAL_MARK => ','"    unless ( defined &DECIMAL_MARK );
    eval "use constant ENABLE_WAKABAMARK => 0"
      unless ( defined &ENABLE_WAKABAMARK );
    eval "use constant ENABLE_BBCODE => 1" unless ( defined &ENABLE_BBCODE );
    eval "use constant APPROX_LINE_LENGTH => 150"
      unless ( defined &APPROX_LINE_LENGTH );
    eval "use constant STUPID_THUMBNAILING => 0"
      unless ( defined &STUPID_THUMBNAILING );
    eval "use constant COOKIE_PATH => 'root'" unless ( defined &COOKIE_PATH );
    eval "use constant STYLE_COOKIE => 'wakabastyle'"
      unless ( defined &STYLE_COOKIE );
	eval "use constant STYLESHEET => ''" unless (defined &STYLESHEET);
    eval "use constant FORCED_ANON => 0" unless ( defined &FORCED_ANON );
    eval "use constant USE_XHTML => 1"   unless ( defined &USE_XHTML );

    eval "use constant IMG_DIR => 'src/'"      unless ( defined &IMG_DIR );
    eval "use constant THUMB_DIR => 'thumb/'"  unless ( defined &THUMB_DIR );
    eval "use constant RES_DIR => 'res/'"      unless ( defined &RES_DIR );
    eval "use constant ORPH_DIR => 'orphans/'" unless ( defined &ORPH_DIR );
    eval "use constant REDIR_DIR => 'redir/'"  unless ( defined &REDIR_DIR );
    eval "use constant HTML_SELF => 'wakaba.html'"
      unless ( defined &HTML_SELF );
    eval "use constant JS_FILE => 'wakaba3.js'" unless ( defined &JS_FILE );
    eval "use constant CSS_DIR => 'css/'"       unless ( defined &CSS_DIR );
    eval "use constant ERRORLOG => ''"          unless ( defined &ERRORLOG );
    eval "use constant CONVERT_COMMAND => 'convert'"
      unless ( defined &CONVERT_COMMAND );
    eval "use constant VIDEO_CONVERT_COMMAND => 'avconv'"
      unless ( defined &VIDEO_CONVERT_COMMAND );

    eval "use constant RANDOM_NAMES => qw(Adolf Anna Anneliese Alex Alexander Arne Berta Bertha Burkhard Charlotte Clara Klara Edith Elfriede Elisabeth Ella Else Emma Erika Erna Ernst Ernsthard Frieda Frida Felix Gerda Gertrud Gisela Hedwig Helene Helga Herta Hertha Hildegard Ida Ilse Ingeborg Irmgard Johanna Kaete Kaethe Lieselotte Liselotte Louise Luise Margarethe Margarete Margot Maria Marie Marta Martha Ruth Ursula Waltraud Waltraut Alfred Arthur Artur Bruno Carl Christian Claus Curt Erich Ernst Franz Friedrich Fritz Georg Gerhard Guenther Guenter Hans Harry Heinz Helmut Helmuth Herbert Hermann Horst Joachim Karl Carl Karlheinz Kai Karl-Heinz Klaus Claus Kurt Curt Manfred Max Otto Paul Richard Rudolf Walter Werner Wilhelm Willi Willy Wolfgang Andrea Angelika Anja Anke Anna Anne Annett Antje Barbara Birgit Brigitte Christin Christina Christine Cindy Claudia Daniela Diana Doreen Franziska Gabriele Heike Ines Jana Janina Jennifer Jessica Jessika Julia Juliane Karin Karolin Katharina Kathrin Katrin Katja Kerstin Klaudia Claudia Klemens Kristin Christin Laura Lea Lena Lisa Mandy Manuela Maria Marie Marina Martina Melanie Monika Nadine Nicole Petra Sabine Sabrina Sandra Sara Sarah Sascha  Silke Simone Sophia Sophie Stefanie Stephanie Susanne Tanja Ulrike Ursula Uta Ute Vanessa Yvonne Alexander Andreas Benjamin Bernd Christian Daniel David Dennis Dieter Dirk Dominik Eric Erik Felix Florian Frank Jan Jens Jonas Joerg Juergen Kevin Klaus Kristian Christian Leon Lukas Marcel Marco Marko Mario Marion Markus Martin Matthias Max Maximilian Michael Mike Maik Niklas Patrick Paul Peter Philipp Phillipp Ralf Ralph René Robert Sebastian Stefan Stephan Steffen Sven Swen Siegfried Thomas Thorsten Torsten Tim Tobias Tom Ulrich Uwe Vinzent Wolfgang Edeltraud)" unless ( defined &RANDOM_NAMES );
    eval "use constant ENABLE_RANDOM_NAMES => 0" unless ( defined &ENABLE_RANDOM_NAMES );
    eval "use constant FILETYPES => ()" unless ( defined &FILETYPES );
}

1;
