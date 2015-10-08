#!/usr/bin/perl

use strict;
use CGI;
use Template;
use Filesys::Df;

use Encode;
use DBI;
use utf8;

BEGIN {
	require "lib/site_config.pl";
}
my $q = CGI->new;
my $page = decode('utf8', $q->param("p"));
my $query = decode('utf8', $q->param("q"));
my $disk_info = df("/home/");

my $is_main;
if($page eq "main") {
    $is_main = 1;
}

binmode(STDOUT, ":utf8");

# redirects should have a full URL: http://ernstchan.com/b/
# but this can be tricky if running behind some proxy
if ($page eq "") {
#        exit print $q->redirect("https://02ch.in/".DEFAULT_BOARD."/");
        exit print $q->redirect("/".DEFAULT_BOARD."/");
}

#print $q->header(-charset => 'utf-8');

my $tt = Template->new({
        INCLUDE_PATH => 'tpl/',
        ERROR => 'error.tt2',
        PRE_PROCESS  => 'header.tt2',
        POST_PROCESS => 'footer.tt2',
        #DEFAULT_ENCODING => 'utf8',
        ENCODING => 'utf8',
        VARIABLES => {
            ismain => $is_main,
            total_gb => nya1k_to_gb($$disk_info{blocks}),
            free_gb => nya1k_to_gb($$disk_info{bfree}), 
            used_gb => nya1k_to_gb($$disk_info{used}), 
        },
});

my $ttfile = "content/" . $page . ".tt2";

if ($page eq 'err403') {
	tpl_make_error({
		'http' => '403 Forbidden',
		'type' => "HTTP-Error 403: Access Denied",
		'info' => "Access to this resource is not allowed.",
		'image' => "/img/403.png"
	});
}
elsif ($page eq 'err404') {
	tpl_make_error({
		'http' => '404 Not found',
		'type' => "HTTP-Error 404: Not Found",
		'info' => "The requested file doesn't exist or has been deleted.",
		'image' => "/img/404.png"
	});
}
elsif (-e 'tpl/' . $ttfile) {
	my $output;
	$tt->process($ttfile, {'tracking_code' => TRACKING_CODE}, \$output)
	  or tpl_make_error({
	  	'http' => '500 Boom',
	  	'type' => "Fehler bei Scriptausf&uuml;hrung",
	  	'info' => $tt->error
	  });
	print $q->header(-charset => 'utf-8');
	print $output;

}
else {
	tpl_make_error({
		'http' => '404 Not found',
		'type' => "HTTP-Error 404: Not Found",
		'info' => "The requested file doesn't exist or has been deleted.",
		'image' => "/img/404.png"
	});
}

#
# Subroutines
#

sub nya1k_to_gb {
    my $blocks = shift;
    int ( ($blocks * 1024)/2 ** 30 );
}

sub tpl_make_error($) {
	my ($error) = @_;
	print $q->header(-status=>$$error{http});
        $tt->process("error.tt2", {
			'tracking_code' => TRACKING_CODE,
			'error' => $error
		});
}

1;
