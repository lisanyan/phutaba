#!/usr/bin/perl

use strict;
use CGI;
# use Template;
use Filesys::Df qw/df/;
use SimpleCtemplate;

use Encode;
use DBI;
use utf8;

BEGIN {
    require "lib/site_config.pl";
    require "lib/config_defaults.pl";
}
my $q = CGI->new;
my $page = decode('utf8', $q->param("p"));
# my $query = decode('utf8', $q->param("q"));

my $cfg = fetch_config(&DEFAULT_BOARD);
my $locale = fetch_locale( $q->cookie("locale") or $$cfg{BOARD_LOCALE} );

# binmode(STDOUT, ":utf8");

# redirects should have a full URL: http://ernstchan.com/b/
# but this can be tricky if running behind some proxy
if ($page eq "") {
       exit print $q->redirect("https://02ch.in/".DEFAULT_BOARD."/");
        # exit print $q->redirect("/main");
}

# print $q->header(-charset => 'utf-8');

my $tt = SimpleCtemplate->new({ tmpl_dir => 'tpl/content/' });
my $ttfile = "content/" . $page . ".tpl";

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
    my $output = $tt->$page({
        tracking_code => TRACKING_CODE,
        uptime => uptime(),
        ismain => ($page eq "main"),
        diskinfo => disk_info(),
        locale => $locale,
        })
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

sub disk_info {
    my $disk_info = df("/home/");
    my @dicks = ($$disk_info{blocks}, $$disk_info{used}, $$disk_info{bfree});
    $_ = nya1k_to_gb($_) for (@dicks);
    return \@dicks;
}

sub nya1k_to_gb {
    my $blocks = shift;
    int ( ($blocks * 1024)/2 ** 30 );
}

sub sec2human {
    my $secs = shift;
    if    ($secs >= 365*24*60*60) { return sprintf '%.1fy', $secs/(365 *24*60*60) }
    elsif ($secs >=     24*60*60) { return sprintf '%.1fd', $secs/(24*60*60) }
    elsif ($secs >=        60*60) { return sprintf '%.1fh', $secs/(60*60) }
    elsif ($secs >=           60) { return sprintf '%.1fm', $secs/(60) }
    else                          { return sprintf '%.1fs', $secs }
}

sub tpl_make_error($) {
    my ($error) = @_;
    print $q->header(-status=>$$error{http}, -charset => 'utf-8');
    my $output = $tt->error({
        tracking_code => TRACKING_CODE,
        error => $error,
        locale => $locale,
    });
    print $output;
}

sub uptime {
    open(FILE, '/proc/uptime') || return 0;
    my $line = <FILE>;
    my($uptime, $idle) = split /\s+/, $line;
    close FILE;
    my @ret = {
        uptime => sec2human($uptime),
        idle => sec2human($idle),
    };
    return \@ret;
}


#
# Config loaders
#

sub fetch_config {
    my ($board) = @_;
    my $settings = get_settings('settings');

    $$settings{$board}{NOTFOUND} = 1 unless($$settings{$board});

    # Global options
    $$settings{$board}{BOARDS} = [ keys %$settings ];
    $$settings{$board}{SELFPATH} = $board;

    return $$settings{$board};
}

sub fetch_locale {
    my ($lc) = @_;
    my $locale;
    if( grep { $lc eq $_ } @{&BOARD_LOCALES} ) {
        $locale = get_settings('locale_' . $lc);
    }
    else {
        $locale = get_settings('locale_' . $$cfg{BOARD_LOCALE}); # Fall back
    }
    $$locale{CURRENT} = $lc;
    return $locale;
}

sub get_settings {
    my ($config) = @_;
    my ($settings, $file);

    if ( $config eq 'mods' ) {
        $file = './lib/config/moders.pl';
    }
    elsif ( $config eq 'trips' ) {
        $file = './lib/config/trips.pl';
    }
    elsif ( $config =~ /locale_(\w+)/ ) {
        $file = "./lib/strings/strings_$1.pl";
    }
    else {
        $file = './lib/config/settings.pl';
    }

    # Grab code from config file and evaluate.
    open (MODCONF, $file) or return 0; # Silently fail if we cannot open file.
    binmode MODCONF, ":utf8"; # Needed for files using non-ASCII characters.

    my $board_options_code = do { local $/; <MODCONF> };
    $settings = eval $board_options_code; # Set up hash.

    # Exception for bad config.
    close MODCONF and return 0 if ($@);
    close MODCONF;

    \%$settings;
}


1;
