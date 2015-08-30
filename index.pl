#!/usr/bin/perl

use strict;
use CGI;
use DBI;
use Template;

BEGIN {
        require "lib/site_config.pl";
}

my $q = CGI->new;
$q->header(-charset => 'utf-8'),

my $ts    = $q->param("ts"); # /fefe/ timestamp
my $query = $q->param("q");  # /fefe/ search query
my $page  = $q->param("p");  # page for template system

# clean up inputs
$ts =~ s/[^\w]//;
$page =~ s/[^\w]//;


# handle fefe timestamp
if ($ts) {
        my $result;
        my $db_fefe = DBI->connect("dbi:SQLite:dbname=/var/db/fefe/sqlite.db", "", "");
        my $db_board = DBI->connect(SQL_DBI_SOURCE, SQL_USERNAME, SQL_PASSWORD);
        my $sth = $db_fefe->prepare("SELECT thread FROM posts WHERE ts = ?");
        $sth->execute($ts);
        $result = $sth->fetch;
        if ($result) {
                my $r = $result->[0];
                # check existence of the post
                $sth = $db_board->prepare("SELECT num FROM ernstchan_fefe WHERE num = ?");
                $sth->execute($r);
                $result = $sth->fetch;
                $sth->finish;
                if ($result) {
                        print $q->redirect("/fefe/thread/$r");
                } else {
                        print $q->redirect("https://blog.fefe.de/?ts=$ts");
                }
        } else {
                print $q->redirect("https://blog.fefe.de/?ts=$ts");
        }
        $db_fefe->disconnect;
        $db_board->disconnect;
        exit;
}

# redirect to fefe search
if ($query) {
        print $q->redirect("https://blog.fefe.de/?q=$query");
        exit;
}

# no parameter was given, redirect to default board
# redirects should have a full URL: http://ernstchan.com/b/
if (!$page) {
        print $q->redirect(BASE_URL . "/" . DEFAULT_BOARD . "/");
        exit;
}

# handle template page
my $ttfile = "content/" . $page . ".tt2";

my $tt = Template->new({
        INCLUDE_PATH => 'tpl/',
        #ENCODING     => 'utf8', # NO!
        ERROR        => 'error.tt2',
        PRE_PROCESS  => 'header.tt2',
        POST_PROCESS => 'footer.tt2',
});

if ($page eq 'err403') {
	tpl_make_error({
		'http' => '403 Forbidden',
		'type' => "HTTP-Fehler 403: Zugriff verboten",
		'info' => "Der Zugriff auf diese Ressource ist nicht erlaubt.",
		'image' => "/img/403.png"
	});
}
elsif ($page eq 'err404') {
	tpl_make_error({
		'http' => '404 Not found',
		'type' => "HTTP-Fehler 404: Objekt nicht gefunden",
		'info' => "Die gew&uuml;nschte Datei existiert nicht oder wurde gel&ouml;scht.",
		'image' => "/img/404.png"
	});
}
elsif (-f 'tpl/' . $ttfile) {
	my $output;
	if ($tt->process($ttfile, {'tracking_code' => TRACKING_CODE}, \$output)) {
		print $q->header();
		print $output;
	} else {
		tpl_make_error({
			'http' => '500 Boom',
			'type' => "Fehler bei Skriptausf&uuml;hrung",
			'info' => $tt->error
		});
	}
}
else {
	tpl_make_error({
		'http' => '404 Not found',
		'type' => "HTTP-Fehler 404: Objekt nicht gefunden",
		'info' => "Es existiert weder ein Board noch eine Seite mit diesem Namen.",
		'image' => "/img/404.png"
	});
}

sub tpl_make_error($) {
	my ($params) = @_;
	print $q->header(-status=>$$params{http});
	$tt->process("error.tt2", {
		'tracking_code' => TRACKING_CODE,
		'error' => $params
	});
}
