#!/usr/bin/perl

use strict;
use CGI;
use Template;
use HTML::Entities;
use Encode;
use DBI;

BEGIN {
        require "lib/site_config.pl";
}
my $q = CGI->new;
my $page = encode_entities(decode('utf8', $q->param("p")));


# /fefe/ handling
my $ts = encode_entities(decode('utf8', $q->param("ts")));
my $query = encode_entities(decode('utf8', $q->param("q")));
if ($ts ne "") {
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
if ($query ne "") {
        print $q->redirect("http://blog.fefe.de/?q=$query");
        exit;
}


# redirects should have a full URL: http://ernstchan.com/b/
# but this can be tricky if running behind some proxy
if ($page eq "") {
        exit print $q->redirect(DEFAULT_BOARD);
}

#print $q->header(-charset => 'utf-8');
print $q->header();

my $tt = Template->new({
        INCLUDE_PATH => 'tpl/',
        ERROR => 'error.tt2',
        PRE_PROCESS  => 'header.tt2',
        POST_PROCESS => 'footer.tt2',
    }) || print Template->error(), "\n";

my $ttfile = "content/" . $page . ".tt2";

if (-e 'tpl/' . $ttfile) {
        $tt->process($ttfile, {'tracking_code' => TRACKING_CODE}) or die($tt->process("error.tt2", {'error' => $tt->error}));
} else {
        $tt->process("error.tt2", {
			'tracking_code' => TRACKING_CODE,
			'error' => {'type' => "HTTP 404", 'info' => "Die angeforderte Datei wurde nicht gefunden."}
		});
}

1;
