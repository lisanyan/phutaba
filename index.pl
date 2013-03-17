#!/usr/bin/perl

use strict;
use CGI;
use Template;
use HTML::Entities;
use Encode;

my $q = CGI->new;
my $page = encode_entities(decode('utf8', $q->param("p")));

# redirects should have a full URL: http://ernstchan.com/b/
# but this can be tricky if running behind some proxy
if ($page eq "") {
	exit print $q->redirect('/b/');
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
	$tt->process($ttfile, {}) or die($tt->process("error.tt2", {'error' => $tt->error}));
} else {
	die($tt->process("error.tt2", {'error' => {'type' => "HTTP 404", 'info' => "Die angeforderte Datei wurde nicht gefunden."}}));
}
