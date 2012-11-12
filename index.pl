#!/usr/bin/perl

BEGIN {
	require 'lib/site_config.pl';
}

use CGI;
use DBI;
use Template;
use HTML::Entities;
use Encode;
#use Data::Dumper;
my $sth;
my @news;
my $q = CGI->new;
print $q->header();
my $page = encode_entities(decode('utf8', $q->param("p")));
if ($page eq "") {
    $page = "news";
}
my $tt = Template->new({
	INCLUDE_PATH => 'tpl/',
        ERROR => 'error.tt2',
        PRE_PROCESS  => 'header.tt2',
        POST_PROCESS => 'footer.tt2',
    }) || print Template->error(), "\n";


$dbh = DBI->connect(SQL_DBI_SOURCE, SQL_USERNAME, SQL_PASSWORD,  { AutoCommit => 1 }) or die($tt->process("error.tt2", { 'error' => {'type' => $DBI::err, 'info' => $DBI::errstr}})); 
$sth = $dbh->prepare('SELECT * FROM news ORDER BY news.date DESC LIMIT 0, 10');
$sth->execute or die($tt->process("error.tt2", { 'error' => {'type' => $DBI::err, 'info' => $DBI::errstr}}));
while(my $row = $sth->fetchrow_hashref) {
    push(@news, $row);
}
$tt->process("content/$page.tt2", {'news' => \@news}) or die($tt->process("error.tt2", { 'error' => $tt->error }));

