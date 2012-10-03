#!/usr/bin/perl -X

use CGI::Carp qw(fatalsToBrowser set_message);

umask 0022;    # Fix some problems

use strict;
use CGI;
use DBI;
use File::stat;
use Net::DNS;
use HTML::Entities;
use Net::IP qw(:PROC);
use Math::BigInt;
use JSON::XS;
use JSON;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Image::ExifTool qw(:Public);
use IO::Socket;
use File::MimeInfo::Magic;
use IO::Scalar;
use Data::Dumper;
use HTML::Strip;
use Geo::IP;

my $sth;
my $JSON = JSON->new->utf8;
$JSON = $JSON->pretty(1);
use constant HANDLER_ERROR_PAGE_HEAD => q{
	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head> 
<title>Ernstchan</title> 
<link rel="stylesheet" type="text/css" href="/css/prototype.css" /> 
</head> 
<body> 
<div class="content"> 
<div class="header"> 
<h1>Ernstchan</h1> 
</div> 
<div class="container" style="background-color: rgba(170, 0, 0, 0.2);margin-top: 50px;"> 
<p>

};

use constant HANDLER_ERROR_PAGE_FOOTER => q{
</p>
</div> 
<p style="text-align: center;margin-top: 50px;"><span style="font-size: small; font-style: italic;">This is a <strong>fatal error</strong> in the <em>request/response handler</em>. Please contact the administrator of this site at the <a href="irc://irc.euirc.net/#ernstchan">IRC</a> or via <a href="mailto:admin@ernstchan.net">email</a> and ask him to fix this error</span></p>
</div> 
</body> 
</html> 
};

# Error Handling
BEGIN {

    sub handler_errors {
        my $msg = shift;
        print HANDLER_ERROR_PAGE_HEAD;
        print $msg;
        print HANDLER_ERROR_PAGE_FOOTER;
    }
    set_message( \&handler_errors );
}

#
# Import settings
#

use lib '.';
BEGIN {
    require "config.pl";
}
BEGIN {
    require "../lib/config_defaults.pl";
}
BEGIN {
    require "../lib/strings_en.pl";
}
BEGIN {
    require "../lib/wakautils.pl";
}
BEGIN {
    require "../lib/futaba_style.pl";
}
BEGIN {
    require "captcha.pl";
}

#
# Optional modules
#

my ($has_encode);

if (CONVERT_CHARSETS) {
    eval 'use Encode qw(decode encode)';
    $has_encode = 1 unless ($@);
}

#
# Global init
#

my $protocol_re = qr/(?:http|https|ftp|mailto|nntp)/;

my $dbh =
  DBI->connect( SQL_DBI_SOURCE, SQL_USERNAME, SQL_PASSWORD,
    { AutoCommit => 1 } )
  or make_error(S_SQLCONF);
my $ih =
  DBI->connect( 'DBI:mysql:database=information_schema;host=localhost', SQL_USERNAME, SQL_PASSWORD,
    { AutoCommit => 1 } );
$sth = $dbh->prepare("SET NAMES 'latin1';");
$sth->execute() or make_error(S_SQLFAIL);

return 1 if (caller);    # stop here if we're being called externally

my $query = CGI->new;
my $loc;
my $ip;
$ip = $ENV{HTTP_X_REAL_IP};
$ip = $ENV{REMOTE_ADDR} if ($ip eq undef); # for crazy people who expose their server to the internet
my $gi = Geo::IP->new(GEOIP_MEMORY_CACHE);
if (($loc = $gi->country_code_by_addr($ip)) eq "") {
     $loc = "unk";
}
if ($ip =~ /:/) {
     $loc = "v6";
}
# testing in a local network never requires a captcha
if ($ip =~ /192\.168\..+\..+/) {
     $loc = "DE";
}
my $task  = ( $query->param("task") or $query->param("action")) unless $query->param("POSTDATA");
$task = ( $query->url_param("task") ) unless $task;
my $json  = ( $query->param("json") or "" );

# check for admin table
init_admin_database() if ( !table_exists(SQL_ADMIN_TABLE) );

# check for proxy table
init_proxy_database() if ( !table_exists(SQL_PROXY_TABLE) );

if ( $json eq "post" ) {
    my $id = $query->param("id");
    if ( $id ne undef ) {
        output_json_post($id);
    }
}
elsif ($json eq "threads") {
    output_json_threads();
}
elsif ($json eq "thread") {
    my $id = $query->param("id");
    if ($id ne undef) {
        output_json_thread($id);
    }
}
elsif ( $json eq "stats" ) {
	my $date_format = $query->param("date_format");
	if ( $date_format ne undef ) {
		output_json_stats($date_format);
	}
}
elsif ($json eq "ban") {
	my $id = $query->param("id");
	if ($id ne undef) {
		output_json_ban($id);
	}
}
elsif ($json eq "meta") {
	my $id = $query->param("post");
    if ($id ne undef) {
		output_json_meta($id);
	}
}

if ( !table_exists(SQL_TABLE) )    # check for comments table
{
    init_database();

    # if nothing exists show the first page.
    show_page(0);
}
elsif ( !$task and !$json ) {

    # when there is no task, show the first page.
    show_page(0);
}
elsif ( $task eq "show" ) {

    my $admin    = $query->param("admin");

    # show the requested page
    my $page = $query->param("page");
    if ( $page ne undef ) {
        if ( $page =~ /^[+-]?\d+$/ ) {
            show_page($page, $admin);
        }
        else {
            make_error(S_STOP_FOOLING);
        }
    }

    my $post = $query->param("post");
    if ( $post ne undef ) {
        if ( $post =~ /^[+-]?\d+$/ ) {
            show_post($post, $admin);
        }
        else {
            make_error(S_STOP_FOOLING);
        }
    }

    # show the requested thread
    my $thread = $query->param("thread");
    if ( $thread ne undef ) {
        if ( $thread =~ /^[+-]?\d+$/ ) {
	    if($thread ne 0) {
	        show_thread($thread, $admin);
	    } else {
		make_error(S_STOP_FOOLING);
	    }
        }
        else {
            make_error(S_STOP_FOOLING);
        }
    }
}
elsif ( $task eq "post" ) {
    my $parent     = $query->param("parent");
    my $gb2        = $query->param("gb2");
    my $name       = $query->param("field1");
    my $email      = $query->param("field2");
    my $subject    = $query->param("field3");
    my $comment    = $query->param("field4");
    my $file       = $query->param("file");
    my $password   = $query->param("password");
    my $nofile     = $query->param("nofile");
    my $captcha    = $query->param("captcha");
    my $admin      = $query->param("admin");
    my $no_captcha = $query->param("no_captcha");
    my $no_format  = $query->param("no_format");
    my $postfix    = $query->param("postfix");
    my $sage       = $query->param("sage");
	my $postAsAdmin = $query->param("as_admin");

    my $file1 = $query->param("file1");
    my $file2 = $query->param("file2");
    my $file3 = $query->param("file3");

    post_stuff(
        $parent,  $name,  $email,      $gb2,       $subject,
        $comment, $file,  $file,       $password,  $nofile,
        $captcha, $admin, $no_captcha, $no_format, $postfix,
        $sage,    $file1, $file2,      $file3,     $postAsAdmin
    );
}
elsif ( $task eq "delete" ) {
    my $password = $query->param("password");
    my $fileonly = $query->param("fileonly");
    my $archive  = $query->param("archive");
    my $admin    = $query->param("admin");
    my @posts    = $query->param("delete");

    delete_stuff( $password, $fileonly, $archive, $admin, @posts );
}
elsif ( $task eq "sticky" ) {
    my $admin    = $query->param("admin");
    my $threadid = $query->param("threadid");
    make_sticky( $admin, $threadid );
}
elsif ( $task eq "kontra" ) {
    my $admin    = $query->param("admin");
    my $threadid = $query->param("threadid");
    make_kontra( $admin, $threadid );

}
elsif ( $task eq "lock" ) {
    my $admin    = $query->param("admin");
    my $threadid = $query->param("threadid");
    make_locked( $admin, $threadid );
}
elsif ( $task eq "admin" ) {
    my $password    = $query->param("berra");        # lol obfuscation
    my $nexttask    = $query->param("nexttask");
    my $savelogin   = $query->param("savelogin");
    my $admincookie = $query->cookie("wakaadmin");

    do_login( $password, $nexttask, $savelogin, $admincookie );
}
elsif ( $task eq "logout" ) {
    do_logout();
}
elsif ( $task eq "mpanel" ) {
    my $admin = $query->param("admin");
    my $page  = $query->param("page");
    if ( !defined($page) ) { $page = 0; }
	#make_admin_post_panel( $admin, $page );
	show_page($page, $admin);
}
elsif ( $task eq "deleteall" ) {
    my $admin = $query->param("admin");
    my $ip    = $query->param("ip");
    my $mask  = $query->param("mask");
    delete_all( $admin, parse_range( $ip, $mask ) );
}
elsif ( $task eq "bans" ) {
    my $admin = $query->param("admin");
    make_admin_ban_panel($admin);
}
elsif ( $task eq "addip" ) {
    my $admin   = $query->param("admin");
    my $type    = $query->param("type");
    my $comment = $query->param("comment");
    my $ip      = $query->param("ip");
    my $mask    = $query->param("mask");
    my $postid  = $query->param("postid");
    add_admin_entry( $admin, $type, $comment, parse_range( $ip, $mask ),
        '', $postid );
}
elsif ( $task eq "addstring" ) {
    my $admin   = $query->param("admin");
    my $type    = $query->param("type");
    my $string  = $query->param("string");
    my $comment = $query->param("comment");
    add_admin_entry( $admin, $type, $comment, 0, 0, $string, 0 );
}
elsif ( $task eq "checkban" ) {
    my $ival1	= $query->param("ip");
    my $admin   = $query->param("admin");
    check_admin_entry($admin, $ival1);
}
elsif ( $task eq "removeban" ) {
    my $admin = $query->param("admin");
    my $num   = $query->param("num");
    remove_admin_entry( $admin, $num );
}
elsif ( $task eq "proxy" ) {
    my $admin = $query->param("admin");
    make_admin_proxy_panel($admin);
}
elsif ( $task eq "addproxy" ) {
    my $admin     = $query->param("admin");
    my $type      = $query->param("type");
    my $ip        = $query->param("ip");
    my $timestamp = $query->param("timestamp");
    my $date      = make_date( time(), DATE_STYLE );
    add_proxy_entry( $admin, $type, $ip, $timestamp, $date );
}
elsif ( $task eq "removeproxy" ) {
    my $admin = $query->param("admin");
    my $num   = $query->param("num");
    remove_proxy_entry( $admin, $num );
}
elsif ( $task eq "spam" ) {
    my ($admin);
    $admin = $query->param("admin");
    make_admin_spam_panel($admin);
}
elsif ( $task eq "updatespam" ) {
    my $admin = $query->param("admin");
    my $spam  = $query->param("spam");
    update_spam_file( $admin, $spam );
}
elsif ( $task eq "sqldump" ) {
    my $admin = $query->param("admin");
    make_sql_dump($admin);
}
elsif ( $task eq "sql" ) {
    my $admin = $query->param("admin");
    my $nuke  = $query->param("nuke");
    my $sql   = $query->param("sql");
    make_sql_interface( $admin, $nuke, $sql );
}
elsif ( $task eq "mpost" ) {
    my $admin = $query->param("admin");
    make_admin_post($admin);
}
elsif ( $task eq "rebuild" ) {
    make_error("DEPRECATED");
}
elsif ( $task eq "nuke" ) {
    my $admin = $query->param("admin");
    do_nuke_database($admin);
}
elsif ( $task eq "paint" ) {
    my $do = $query->param("do");
    $do = $query->url_param("do") unless $do;
    
    if ($do eq "new") {
	my $applet = $query->param("applet");
   	my $width = $query->param("width");
    	my $height = $query->param("height");
	$width = 640 unless $width;
	$height = 480 unless $height;    
	do_paint($do, $applet, $width, $height);
    }
    elsif ($do eq "save") {
	my $file = $query->param("POSTDATA");
	my $tmpid = $query->url_param("id");
	my $uploadname = "paint$tmpid.png";
        my $time = time();
	make_error("Keine Daten empfangen.") unless $file;
	
	my ( $filename, $md5, $width, $height, $thumbnail, $tn_width, $tn_height ) = process_file( $file, $uploadname, $time );
      	# board, tmpid, filename, time, width, height, thumbnail, tn_width, tn_height
	$sth = $dbh->prepare("INSERT INTO `oekaki` VALUES(?,?,?,?,?,?,?,?,?);") or make_error($dbh->errstr);
	$sth->execute(BOARD_IDENT, $tmpid, $filename, $time, $width, $height, $thumbnail, $tn_width, $tn_height) or make_error($dbh->errstr);
	
    }  
    elsif ($do eq "proceed") {
        make_http_header();
        print "<pre>";
        print Dumper $query;
        print "</pre>";
    }  
}

$dbh->disconnect();

sub do_paint {
    my ($do, $applet, $width, $height) = @_;
    
    my ($title, $tmpid, $type);
    $tmpid = md5_hex(time());
    if ($applet eq "shipainter") {
	$title = "Shi-Painter";
	$type = "normal";
    }
    elsif ($applet eq "shipainterpro") {
	$title = "Shi-Painter Pro";
	$type = "pro";
    } else {
	make_error("Falscher Painter Typ");
    } 
    make_http_header();
    print(
        encode_string(
            OEKAKI_TEMPLATE->(
            	title => $title,
		height => $height,
		width => $width,
		type => $type,
		tmpid => $tmpid,
		)
        )
    );

}

sub output_json_threads {
    my ($row, $error, $code, %status, @data, %json);
    $sth = $dbh->prepare("SELECT num, sticky IS NULL OR sticky=0 AS sticky_isnull FROM " . SQL_TABLE . " WHERE parent = 0 ORDER BY sticky_isnull ASC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC");
    $sth->execute();
    $error = encode_entities(decode('utf8', $sth->errstr));
    while($row = $sth->fetch()) {
        push(@data, $$row[0]);
    }
    if(@data ne 0) {
        $code = 200;   
    } elsif($sth->rows eq 0) {
        $code = 404;
        $error = 'Element not found.';
    } else {
        $code = 500;
    }
    %status = (
            "error_code" => $code,
            "error_msg" => $error,
    );
    %json = (
            "data" => \@data,
            "status" => \%status,
    );

    make_json_header();
    print $JSON->encode(\%json);
}

sub output_json_thread {
    my ($id) = @_;
    my ($row, $error, $code, %status, @data, %json);
    $sth = $dbh->prepare("SELECT num, sticky IS NULL OR sticky=0 AS sticky_isnull FROM " . SQL_TABLE . " WHERE num=? OR parent=? ORDER BY num ASC;");
    $sth->execute($id, $id);
    $error = encode_entities(decode('utf8', $sth->errstr));
    while($row = $sth->fetch()) {
        push(@data, $$row[0]);
    }
    if(@data ne 0) {
        $code = 200;   
    } elsif($sth->rows eq 0) {
        $code = 404;
        $error = 'Element not found.';
    } else {
        $code = 500;
    }
    %status = (
            "error_code" => $code,
            "error_msg" => $error,
    );
    %json = (
            "data" => \@data,
            "status" => \%status,
    );

    make_json_header();
    print $JSON->encode(\%json);
}

sub output_json_meta {
	my ($id) = @_;
	my ($row, $error, $code, %status, %data, %json);	

	$sth = $dbh->prepare("SELECT * FROM " . SQL_TABLE . " WHERE num=?;");
	$sth->execute($id);
	$error = encode_entities(decode('utf8', $sth->errstr));
	$row = $sth->fetchrow_hashref();
	if($row ne undef) {
		$code = 200;
		add_secondary_images_to_row($row);
		$data{'file'} = [get_meta($$row{'image'}), get_meta($$row{'image1'}), get_meta($$row{'image2'}), get_meta($$row{'image3'})];
	} elsif($sth->rows eq 0) {
		$code = 404;
		$error = 'Element not found.';
	} else {
		$code = 500;
	}

	%status = (
		"error_code" => $code,
		"error_msg" => $error,
	);
	%json = (
		"data" => \%data,
		"status" => \%status,
	);

	make_json_header();
	print $JSON->encode(\%json);
}
		

sub output_json_ban {
	my ($id) = @_;
	my ($row, $error, $code, %status, %data, %json);

	$sth = $dbh->prepare("SELECT `comment`, `ival1` as `ip`, `ival2` as `mask`, `date` FROM " . SQL_ADMIN_TABLE . " WHERE num=?;");
	$sth->execute($id);
	$error = encode_entities(decode('utf8', $sth->errstr));
	$row = $sth->fetchrow_hashref();
	if($row ne undef) {
		$code = 200;
		$$row{'ip'} = dec_to_dot($$row{'ip'});
		$$row{'mask'} = dec_to_dot($$row{'mask'});
		$data{'ban_info'} = $row;
		$data{'ip_info'}{'asn_info'} = [get_asn_info($$row{'ip'})];
		$data{'ip_info'}{'as_desc'} = encode_entities(decode('utf8', get_as_description($data{'ip_info'}{'asn_info'}[0])));
		$data{'ip_info'}{'ptr'} = get_rdns($$row{'ip'});
		$data{'ip_info'}{'contacts'} = [get_ipwi_contacts($$row{'ip'})];
	} elsif($sth->rows eq 0) {
		$code = 404;
		$error = 'Element not found.';
	} else {
		$code = 500;
	}

	%status = (
		"error_code" => $code,
		"error_msg" => $error,
	);
	%json = (
		"data" => \%data,
		"status" => \%status,
	);

	make_json_header();
	print $JSON->encode(\%json);
}
	

sub output_json_post {
	my ($id) = @_;
	my ($row, $error, $code, %status, %data, %json);

	$sth = $dbh->prepare("SELECT * FROM " . SQL_TABLE . " WHERE num=?;");
	$sth->execute($id);
	$error = encode_entities(decode('utf8', $sth->errstr));
	$row = $sth->fetchrow_hashref();
	if($row ne undef) {
		$code = 200;
		$$row{'comment'} = encode_entities(decode('utf8', $$row{'comment'}));
		$$row{'ip'} = "[REDACTED]";
		$$row{'password'} = "[REDACTED]";
		add_secondary_images_to_row($row);
		$data{'post'} = $row;
	} elsif($sth->rows eq 0) {
		$code = 404;
		$error = 'Element not found.';
	} else {
		$code = 500;
	}

	%status = (
		"error_code" => $code,
		"error_msg" => $error,
	);
	%json = (
		"data" => \%data,
		"status" => \%status,
	);

	make_json_header();
	print $JSON->encode(\%json);
}

sub output_json_stats {
	my ($date_format) = @_;
	my (@data, $error, $code, %status, %data, %json);
	
	$sth = $dbh->prepare("SELECT DATE_FORMAT(FROM_UNIXTIME(`timestamp`), ?) as `datum`, COUNT(`num`) as `posts` FROM " . SQL_TABLE . " GROUP BY `datum`;");
	$sth->execute(encode_entities(decode('utf8', $date_format)));
	$error = encode_entities(decode('utf8', $sth->errstr));
	@data = $sth->fetchall_arrayref;
	if(@data ne undef) {
		$code = 200;
		$data{'stats'} = \@data;
	} elsif($sth->rows eq 0) {
		$code = 404;
		$error = 'No data available.';
	} else {
		$code = 500;
	}

	%status = (
		"error_code" => $code,
		"error_msg" => $error,
	);
	%json = (
		"data" => \%data,
		"status" => \%status,
	);

	make_json_header();
	print $JSON->encode(\%json);
}


# sub show_post
# shows a single post out of a thread, essential for the reloadless view of threads
# takes an integer as argument
# returns nothing
sub show_post {
    my ($id, $admin) = @_;
    my ($sth, $row, @thread);
    my $isAdmin = 0;
    if(defined($admin))
    {
	check_password($admin, ADMIN_PASS);
    	$isAdmin = 1;
    }

    $sth = $dbh->prepare(
            "SELECT *, sticky IS NULL OR sticky=0 AS sticky_isnull FROM "
          . SQL_TABLE
          . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute( $id ) or make_error(S_SQLFAIL);
    make_http_header();

    if ( $row = $sth->fetchrow_hashref() ) {
        add_secondary_images_to_row($row);
        push( @thread, $row );
    }
    else {
        print encode_json( { "error_code" => 400 } );
    }
	
    print(
            SINGLE_POST_TEMPLATE->(
            	thread	     => $id,
		posts        => \@thread,
		single	     => 1,
                isAdmin      => $isAdmin,
                admin        => $admin,
		locked       => $thread[0]{locked},
		
            )
    );

}

sub show_page {
    my ($pageToShow, $admin) = @_;
    my $page = 0;
    my ( $sth, $row, @thread );
	# if we try to call show_page with admin parameter
	# the admin password will be checked and this
	# variable will be 1
	my $isAdmin = 0;
	if(defined($admin))
	{
		check_password($admin, ADMIN_PASS);
		$isAdmin = 1;
	}

    # grab all posts, in thread order (ugh, ugly kludge)
    $sth = $dbh->prepare(
            "SELECT *, sticky IS NULL OR sticky=0 AS sticky_isnull FROM "
          . SQL_TABLE
          . " ORDER BY sticky_isnull ASC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC"
    ) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    $row = get_decoded_hashref($sth);

    if ( !$row )    # no posts on the board!
    {
        output_page( 0, 1, $isAdmin, $admin, () );    # make an empty page 0
    }
    else {
        my $threadcount = 0;
        my @threads;
        add_secondary_images_to_row($row);
		if($isAdmin) {
			fixup_admin_reference_links($row, $admin);
		}
        my @thread = ($row);

        my $totalThreadCount = count_threads();
        my $total;
		if($isAdmin) {
			$total = get_page_count_real($totalThreadCount);
		}
		else {
			$total = get_page_count($totalThreadCount);
		}
        if ( $pageToShow > ( $total - 1 ) ) {
            make_error(S_INVALID_PAGE);
        }

        while ( $row = get_decoded_hashref($sth)
            and $threadcount <= ( IMAGES_PER_PAGE * ( $pageToShow + 1 ) ) )
        {
            add_secondary_images_to_row($row);
			if($isAdmin) {
				fixup_admin_reference_links($row, $admin);
			}
            if ( !$$row{parent} ) {
                push @threads, { posts => [@thread] };
                @thread = ($row);    # start new thread
                $threadcount++;
            }
            else {
                push @thread, $row;
            }
        }
        push @threads, { posts => [@thread] };

        my @pagethreads;
        my $built_page = 0;
        while ( @pagethreads = splice @threads, 0, IMAGES_PER_PAGE
            and $built_page == 0 )
        {
            if ( $page == $pageToShow ) {
                output_page( $page, $total, $isAdmin, $admin, @pagethreads);
                $built_page = 1;
            }
            $page++;
        }
        if ( $built_page == 0 ) {
            make_error(S_INVALID_PAGE);
        }
    }
}

sub get_page_count_real {
    my ($total) = @_;
    return int( ( $total + IMAGES_PER_PAGE- 1 ) / IMAGES_PER_PAGE );
}

sub output_page {
    my ( $page, $total, $isAdmin, $adminPass, @threads) = @_;
    my ( $filename, $tmpname );

    # do abbrevations and such
    foreach my $thread (@threads) {

        # split off the parent post, and count the replies and images

        my ( $parent, @replies ) = @{ $$thread{posts} };
        my $replies = @replies;

        my $images = grep { $$_{image} } @replies;
        $images += grep { $$_{image1} } @replies;
        $images += grep { $$_{image2} } @replies;
        $images += grep { $$_{image3} } @replies;

        my $curr_replies = $replies;
        my $curr_images  = $images;
        my $max_replies  = REPLIES_PER_THREAD;
        my $max_images   = ( IMAGE_REPLIES_PER_THREAD or $images );

        # in case of a locked thread use custom number of replies
        if ( $$parent{locked} ) {
            $max_replies = REPLIES_PER_LOCKED_THREAD;
            $max_images = ( IMAGE_REPLIES_PER_LOCKED_THREAD or $images );
        }

        # in case of a sticky thread, use custom number of replies
        # NOTE: has priority over locked thread
        if ( !$$parent{sticky_isnull} ) {
            $max_replies = REPLIES_PER_STICKY_THREAD;
            $max_images = ( IMAGE_REPLIES_PER_STICKY_THREAD or $images );
        }

        # drop replies until we have few enough replies and images
        while ( $curr_replies > $max_replies or $curr_images > $max_images ) {
            my $post = shift @replies;
            $curr_images -= $$post{imagecount};
            $curr_replies--;
        }
        # write the shortened list of replies back
        $$thread{posts}      = [ $parent, @replies ];
        $$thread{omit}       = $replies - $curr_replies;
        $$thread{omitimages} = $images - $curr_images;
	$$thread{num}	     = ${$$thread{posts}}[0]{num};

        # abbreviate the remaining posts
        foreach my $post ( @{ $$thread{posts} } ) {
            my $abbreviation =
              abbreviate_html( $$post{comment}, MAX_LINES_SHOWN,
                APPROX_LINE_LENGTH );
            if ($abbreviation) {
                $$post{comment} = $abbreviation;
                $$post{abbrev}  = 1;
            }
        }
    }

    # make the list of pages
    my @pages = map +{ page => $_ }, ( 0 .. $total - 1 );
    foreach my $p (@pages) {
        if ( $$p{page} == 0 ) {
			if($isAdmin)
	        {
				$$p{filename} = expand_filename("wakaba.pl?task=show&amp;page=0&amp;admin=$adminPass");
			}
			else
			{
				$$p{filename} = expand_filename("wakaba.pl?task=show&amp;page=0");			
			}
        }    # first page
        else {
            if($isAdmin)
			{
				$$p{filename} =
	              expand_filename( "wakaba.pl?task=show&amp;page=" . $$p{page} . "&amp;admin=$adminPass" );
			}
			else
			{
				$$p{filename} =
	              expand_filename( "wakaba.pl?task=show&amp;page=" . $$p{page} );
			}
        }
        if ( $$p{page} == $page ) { $$p{current} = 1 }   # current page, no link
    }

    my ( $prevpage, $nextpage );
    $prevpage = $pages[ $page - 1 ]{filename} if ( $page != 0 );
    $nextpage = $pages[ $page + 1 ]{filename} if ( $page != $total - 1 );

    make_http_header();
    print(
        encode_string(
            PAGE_TEMPLATE->(
                postform => ( ALLOW_TEXTONLY or ALLOW_IMAGES ),
                image_inp    => ALLOW_IMAGES,
                textonly_inp => ( ALLOW_IMAGES and ALLOW_TEXTONLY ),
                prevpage     => $prevpage,
                nextpage     => $nextpage,
                pages        => \@pages,
                loc          => $loc,
                threads      => \@threads,
		isAdmin      => $isAdmin,
		admin        => $adminPass
            )
        )
    );
}

# TODO: hack to support >>1 references in admin mode.
# might want a much cleaner solution. as for example dynamically generated
# reflinks.
sub fixup_admin_reference_links
{
    my ($row, $admin) = @_;
	$$row{comment} =~ s/\/faden\/([0-9]*)#([0-9]*)/\/wakaba.pl?task=show&amp;thread=$1&amp;admin=$admin#$2/ig;
	$$row{comment} =~ s/\/faden\/([0-9]*)/\/wakaba.pl?task=show&amp;thread=$1&amp;admin=$admin/ig;
}

sub show_thread {
    my ($thread, $admin) = @_;
    my ( $sth, $row, @thread );
    my ( $filename, $tmpname );
	
	# if we try to call show_thread with admin parameter
	# the admin password will be checked and this
	# variable will be 1
	my $isAdmin = 0;
	if(defined($admin))
	{
		check_password($admin, ADMIN_PASS);
		$isAdmin = 1;
	}

    $sth = $dbh->prepare(
            "SELECT *, sticky IS NULL OR sticky=0 AS sticky_isnull FROM "
          . SQL_TABLE
          . " WHERE num=? OR parent=? ORDER BY num ASC;" )
      or make_error(S_SQLFAIL);
    $sth->execute( $thread, $thread ) or make_error(S_SQLFAIL);

    while ( $row = get_decoded_hashref($sth) ) {
        add_secondary_images_to_row($row);
		if($isAdmin) {
   			fixup_admin_reference_links($row, $admin);
		}
        push( @thread, $row );
    }

    make_error(S_NOTHREADERR) if ( !$thread[0] or $thread[0]{parent} );

    make_http_header();
    print(
        encode_string(
            PAGE_TEMPLATE->(
                thread       => $thread,
                title        => $thread[0]{subject},
                postform     => ( ALLOW_TEXT_REPLIES or ALLOW_IMAGE_REPLIES ),
                image_inp    => ALLOW_IMAGE_REPLIES,
                textonly_inp => 0,
                dummy        => $thread[$#thread]{num},
                loc          => $loc,
                threads      => [ { posts => \@thread } ],
                isAdmin      => $isAdmin, 
                admin        => $admin,
		        locked	     => $thread[0]{locked},
            )
        )
    );
}

sub add_secondary_images_to_row {

    #NOTE: this sub will also add a special field to the row
    # which will denote if the row contains more than 2 images.
    # this is used to determine the post style in the template
    my ($row)              = @_;
    my $extImageCount      = 0;
    my $secondaryImageSize = 0;

	if ( $$row{uploadname} )
	{
		$$row{uploadname} = clean_string($$row{uploadname});
	}


    if ( $$row{imageid_1} != 0 ) {
        my $sth2 = $dbh->prepare(
            "SELECT * FROM " . SQL_TABLE_IMG . " WHERE timestamp=?" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $$row{imageid_1} );
        my $res2 = get_decoded_hashref($sth2);    #$sth2->fetchrow_hashref();
        $$row{image1}       = $$res2{image};
        $$row{uploadname1}  = clean_string($$res2{uploadname});
        $$row{displaysize1} = $$res2{displaysize};
        $$row{width1}       = $$res2{width};
        $$row{height1}      = $$res2{height};
        $$row{thumbnail1}   = $$res2{thumbnail};
        $$row{tn_width1}    = $$res2{tn_width};
        $$row{tn_height1}   = $$res2{th_height};
        $$row{size1}        = $$res2{size};
        $secondaryImageSize += $$res2{size};
        $extImageCount++;
    }

    if ( $$row{imageid_2} != 0 ) {
        my $sth2 = $dbh->prepare(
            "SELECT * FROM " . SQL_TABLE_IMG . " WHERE timestamp=?" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $$row{imageid_2} );
        my $res2 = get_decoded_hashref($sth2);    #$sth2->fetchrow_hashref();
        $$row{image2}       = $$res2{image};
        $$row{uploadname2}  = clean_string($$res2{uploadname});
        $$row{displaysize2} = $$res2{displaysize};
        $$row{width2}       = $$res2{width};
        $$row{height2}      = $$res2{height};
        $$row{thumbnail2}   = $$res2{thumbnail};
        $$row{tn_width2}    = $$res2{tn_width};
        $$row{tn_height2}   = $$res2{th_height};
        $$row{size2}        = $$res2{size};
        $secondaryImageSize += $$res2{size};
        $extImageCount++;
    }
    if ( $$row{imageid_3} != 0 ) {
        my $sth2 = $dbh->prepare(
            "SELECT * FROM " . SQL_TABLE_IMG . " WHERE timestamp=?" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $$row{imageid_3} );
        my $res2 = get_decoded_hashref($sth2);    # $sth2->fetchrow_hashref();
        $$row{image3}       = $$res2{image};
        $$row{uploadname3}  = clean_string($$res2{uploadname});
        $$row{displaysize3} = $$res2{displaysize};
        $$row{width3}       = $$res2{width};
        $$row{height3}      = $$res2{height};
        $$row{thumbnail3}   = $$res2{thumbnail};
        $$row{tn_width3}    = $$res2{tn_width};
        $$row{tn_height3}   = $$res2{th_height};
        $$row{size3}        = $$res2{size};
        $secondaryImageSize += $$res2{size};
        $extImageCount++;
    }
    if ( $extImageCount >= 2 ) {
        $$row{threeimages} = 1;
    }
    else {
        $$row{threeimages} = 0;
    }
    if ( $extImageCount == 1 ) {
        $$row{twoimages} = 1;
    }
    else {
        $$row{twoimages} = 0;
    }
    $$row{imagecount} = $extImageCount + ( $$row{image} ? 1 : 0 );
    $$row{secondaryimagesize} = $secondaryImageSize;
}

sub print_page {
    my ( $filename, $contents ) = @_;

    $contents = encode_string($contents);

    #		$PerlIO::encoding::fallback=0x0200 if($has_encode);
    #		binmode PAGE,':encoding('.CHARSET.')' if($has_encode);

    if (USE_TEMPFILES) {
        my $tmpname = RES_DIR . 'tmp' . int( rand(1000000000) );

        open( PAGE, ">$tmpname" ) or make_error(S_NOTWRITE);
        print PAGE $contents;
        close PAGE;

        rename $tmpname, $filename;
    }
    else {
        open( PAGE, ">$filename" ) or make_error(S_NOTWRITE);
        print PAGE $contents;
        close PAGE;
    }
}

sub dnsbl_check {
    my ($ip) = @_;

    foreach my $dnsbl_info ( @{&DNSBL_INFOS} ) {
        my $dnsbl_host   = @$dnsbl_info[0];
        my $dnsbl_answer = @$dnsbl_info[1];
        my $dnsbl_error  = @$dnsbl_info[2];
        my $result;
        my $resolver;
        my $reverse_ip    = join( '.', reverse split /\./, $ip );
        my $dnsbl_request = join( '.', $reverse_ip,        $dnsbl_host );

        $resolver = Net::DNS::Resolver->new;
        my $bgsock = $resolver->bgsend($dnsbl_request);
        my $sel    = IO::Select->new($bgsock);

        my @ready = $sel->can_read(DNSBL_TIMEOUT);
        if (@ready) {
            foreach my $sock (@ready) {
                if ( $sock == $bgsock ) {
                    my $packet = $resolver->bgread($bgsock);
                    if ($packet) {
                        foreach my $rr ( $packet->answer ) {
                            next unless $rr->type eq "A";
                            $result = $rr->address;
                            last;
                        }
                    }
                    $bgsock = undef;
                }
                $sel->remove($sock);
                $sock = undef;
            }
        }

        if ( $result eq $dnsbl_answer ) {
            make_ban( $ip, 0, $dnsbl_error, 0, 1 );
        }
    }
}

#
# Posting
#
sub strip_html {
	my ($html) = @_;
	#  my $plain;
	# my $hs = HTML::Strip->new();
	#$plain = $hs->parse($html);
	#undef $hs;
	return $html;

}

sub post_stuff {
    my (
        $parent,  $name,  $email,      $gb2,       $subject,
        $comment, $file,  $uploadname, $password,  $nofile,
        $captcha, $admin, $no_captcha, $no_format, $postfix,
        $sage,    $file1, $file2,      $file3,     $postAsAdmin
    ) = @_;

    my $original_comment = $comment;
    # get a timestamp for future use
    my $time = time();
	my $isAdminPost = 0;

    # check that the request came in as a POST, or from the command line
    make_error(S_UNJUST)
      if ( $ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} ne "POST" );

    if ($admin)  # check admin password - allow both encrypted and non-encrypted
    {
        check_password( $admin, ADMIN_PASS );
		if(defined($postAsAdmin) && $postAsAdmin)
		{
			$isAdminPost = 1;
		}
    }
    else {

        # forbid admin-only features
        make_error(S_WRONGPASS) if ( $no_captcha or $no_format or $postfix );

        # check what kind of posting is allowed
        if ($parent) {

            # check if the thread is locked and return error if it is
            check_locked($parent);

            make_error(S_NOTALLOWED) if ( $file  and !ALLOW_IMAGE_REPLIES );
            make_error(S_NOTALLOWED) if ( !$file and !ALLOW_TEXT_REPLIES );
        }
        else {
            make_error(S_NOTALLOWED) if ( $file  and !ALLOW_IMAGES );
            make_error(S_NOTALLOWED) if ( !$file and !ALLOW_TEXTONLY );
        }
    }

    # check for weird characters
    make_error(S_UNUSUAL) if ( $parent  =~ /[^0-9]/ );
    make_error(S_UNUSUAL) if ( length($parent) > 10 );
    make_error(S_UNUSUAL) if ( $name    =~ /[\n\r]/ );
    make_error(S_UNUSUAL) if ( $email   =~ /[\n\r]/ );
    make_error(S_UNUSUAL) if ( $subject =~ /[\n\r]/ );

    # check for excessive amounts of text
    make_error(S_TOOLONG) if ( length($name) > MAX_FIELD_LENGTH );
    make_error(S_TOOLONG) if ( length($email) > MAX_FIELD_LENGTH );
    make_error(S_TOOLONG) if ( length($subject) > MAX_FIELD_LENGTH );
    make_error(S_TOOLONG) if ( length($comment) > MAX_COMMENT_LENGTH );

    # check to make sure the user selected a file, or clicked the checkbox
    make_error(S_NOPIC) if ( !$parent and !$file and !$nofile and !$isAdminPost );

    # check for empty reply or empty text-only post
    make_error(S_NOTEXT) if ( $comment =~ /^\s*$/ and !$file );

    # get file size, and check for limitations.
    my $size  = get_file_size($file)  if ($file);
    my $size1 = get_file_size($file1) if ($file1);
    my $size2 = get_file_size($file2) if ($file2);
    my $size3 = get_file_size($file3) if ($file3);

    # find IP
    #my $ip  = $ENV{REMOTE_ADDR};
    #my $ip  = substr($ENV{HTTP_X_FORWARDED_FOR}, 6); # :ffff:1.2.3.4
    my $ssl = $ENV{HTTP_X_ALUHUT};
    undef($ssl) unless $ssl;

    #$host = gethostbyaddr($ip);
    my $iph   = new Net::IP($ip);
    my $numip = $iph->intip();

    # set up cookies
    my $c_name     = $name;
    my $c_email    = $email;
    my $c_password = $password;
    my $c_gb2      = $gb2;

    # check if IP is whitelisted
    my $whitelisted = is_whitelisted($numip);
    dnsbl_check($ip) if ( !$whitelisted and ENABLE_DNSBL_CHECK );

    # process the tripcode - maybe the string should be decoded later
    my $trip;
    ( $name, $trip ) = process_tripcode( $name, TRIPKEY, SECRET, CHARSET );

    # check for bans
    ban_check( $numip, $c_name, $subject, $comment ) unless $whitelisted;

    # spam check
    spam_engine(
        query           => $query,
        trap_fields     => SPAM_TRAP ? [ "name", "link" ] : [],
        spam_files      => [SPAM_FILES],
        charset         => CHARSET,
        included_fields => [ "field1", "field2", "field3", "field4" ],
    ) unless $whitelisted;

    
    
    # check captcha
    check_captcha( $dbh, $captcha, $ip, $parent )
      if ( (use_captcha(ENABLE_CAPTCHA, $loc) and !$admin) or (ENABLE_CAPTCHA and !$admin and !$no_captcha and !is_trusted($trip)) );

    # proxy check
    proxy_check($ip) if ( !$whitelisted and ENABLE_PROXY_CHECK );

    # check if thread exists, and get lasthit value
    my ( $parent_res, $lasthit );
    if ($parent) {
        $parent_res = get_parent_post($parent) or make_error(S_NOTHREADERR);
        $lasthit = $$parent_res{lasthit};
    }
    else {
        $lasthit = $time;
    }

    # kill the name if anonymous posting is being enforced
    if (FORCED_ANON && !$admin) {
        $name = '';
        $trip = '';
	if(ENABLE_RANDOM_NAMES) {
		my @names = RANDOM_NAMES; 
		$name = $names[rand(@names)];
	}
        if   ($email) { $email = 'sage'; }
        else          { $email = ''; }
    }

    # clean up the inputs
    $email   = clean_string( decode_string( $email,   CHARSET ) );
    $subject = clean_string( decode_string( $subject, CHARSET ) );

    # fix up the email/link
    $email = "mailto:$email" if $email and $email !~ /^$protocol_re:/;

    # format comment
    $comment =
      format_comment( clean_string( decode_string( $comment, CHARSET ) ) )
      unless $no_format;
    $comment .= $postfix;

    # insert default values for empty fields
    $parent = 0 unless $parent;
    $name    = make_anonymous( $ip, $time ) unless $name or $trip;
    $subject = S_ANOTITLE                   unless $subject;
    $comment = S_ANOTEXT                    unless $comment;
    $original_comment = "empty"		    unless $original_comment;
#    $original_comment =~ s/\n/ /gm;
    # flood protection - must happen after inputs have been cleaned up
    flood_check( $numip, $time, $comment, $file );

    # Manager and deletion stuff - duuuuuh?

    # copy file, do checksums, make thumbnail, etc
    my ( $filename, $md5, $width, $height, $thumbnail, $tn_width, $tn_height ) =
      process_file( $file, $uploadname, $time )
      if ($file);



    my $displaysize = get_displaysize($size);

    my $tsf1 = 0;
    my $tsf2 = 0;
    my $tsf3 = 0;
    if ($file1) {
        $tsf1 = time() . sprintf( "%03d", int( rand(1000) ) );
        my (
            $filename1,  $md51,      $width1, $height1,
            $thumbnail1, $tn_width1, $tn_height1
        ) = process_file( $file1, $file1, $tsf1 );
        my $displaysize1 = get_displaysize($size1);
        my $sth2 =
          $dbh->prepare( "INSERT INTO "
              . SQL_TABLE_IMG
              . " VALUES(?,?,?,?,?,?,?,?,?,?,?);" )
          or make_error(S_SQLFAIL);
        $sth2->execute(
            $tsf1,       $filename1, $size1,        $md51,
            $width1,     $height1,   $thumbnail1,   $tn_width1,
            $tn_height1, $file1, $displaysize1
        ) or make_error(S_SQLFAIL);
    }

    if ($file2) {
        $tsf2 = time() . sprintf( "%03d", int( rand(1000) ) );
        my (
            $filename1,  $md51,      $width1, $height1,
            $thumbnail1, $tn_width1, $tn_height1
        ) = process_file( $file2, $file2, $tsf2 );
        my $displaysize1 = get_displaysize($size2);
        my $sth2 =
          $dbh->prepare( "INSERT INTO "
              . SQL_TABLE_IMG
              . " VALUES(?,?,?,?,?,?,?,?,?,?,?);" )
          or make_error(S_SQLFAIL);
        $sth2->execute(
            $tsf2,       $filename1, $size2,        $md51,
            $width1,     $height1,   $thumbnail1,   $tn_width1,
            $tn_height1, $file2, $displaysize1
        ) or make_error(S_SQLFAIL);
    }

    if ($file3) {
        $tsf3 = time() . sprintf( "%03d", int( rand(1000) ) );
        my (
            $filename1,  $md51,      $width1, $height1,
            $thumbnail1, $tn_width1, $tn_height1
        ) = process_file( $file3, $file3, $tsf3 );
        my $displaysize1 = get_displaysize($size3);
        my $sth2 =
          $dbh->prepare( "INSERT INTO "
              . SQL_TABLE_IMG
              . " VALUES(?,?,?,?,?,?,?,?,?,?,?);" )
          or make_error(S_SQLFAIL);
        $sth2->execute(
            $tsf3,       $filename1, $size3,        $md51,
            $width1,     $height1,   $thumbnail1,   $tn_width1,
            $tn_height1, $file3, $displaysize1
        ) or make_error(S_SQLFAIL);
    }

    # finally, write to the database
    my $sth = $dbh->prepare(
        "INSERT INTO " . SQL_TABLE . "
		VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,null,?,?,?,null,?,?,?,?,?,?);"
    ) or make_error(S_SQLFAIL);
    $sth->execute(
        $parent,      $time,                $lasthit,
        $numip,                $name,
        $trip,        $email,               $subject,
        $password,    $comment,             $filename,
        $size,        $md5,                 $width,
        $height,      $thumbnail,           $tn_width,
        $tn_height,   $isAdminPost,  $uploadname,
        $displaysize, $$parent_res{sticky}, $tsf1,
        $tsf2,        $tsf3,                $loc,
        $ssl
    ) or make_error(S_SQLFAIL);
    
    my $new_post_id = 0;

    if (ENABLE_IRC_NOTIFY) {
        my $sth = $dbh->prepare(
            "SELECT num FROM " . SQL_TABLE . " WHERE timestamp=? LIMIT 1;" )
          or make_error(S_SQLFAIL);
        $sth->execute($time) or make_error(S_SQLFAIL);
        my $row;
        if ( $row = $sth->fetchrow_hashref() ) {
            my $socket = new IO::Socket::INET(
                PeerAddr => IRC_NOTIFY_HOST,
                PeerPort => IRC_NOTIFY_PORT,
                Proto    => "tcp"
            );
            if ($socket) {
                if ( $parent and IRC_NOTIFY_ON_NEW_POST ) {
                    print $socket S_IRC_NEW_POST_PREPEND . "/"
                      . BOARD_IDENT . "/: "
                      . S_IRC_BASE_BOARDURL
                      . BOARD_IDENT
                      . S_IRC_BASE_THREADURL
                      . $parent . "#"
                      . $$row{num} . " ["
		      . get_preview($original_comment) . "]\n";
                }
                elsif ( !$parent and IRC_NOTIFY_ON_NEW_THREAD ) {
                    print $socket S_IRC_NEW_THREAD_PREPEND . "/"
                      . BOARD_IDENT . "/: "
                      . S_IRC_BASE_BOARDURL
                      . BOARD_IDENT
                      . S_IRC_BASE_THREADURL
                      . $$row{num} . " ["
                      . get_preview($original_comment) . "]\n";
                }
                close($socket);
            }
            $new_post_id = $$row{num};
        }
    }

    if (ENABLE_WEBSOCKET_NOTIFY) {
        my $ufoporno = system('/usr/local/bin/push-post', BOARD_IDENT, $parent, $new_post_id, "2>&1", ">/dev/null");
    }

    if ($parent)    # bumping
    {
        my $autosage;
        $sth = $dbh->prepare(
            "SELECT autosage FROM " . SQL_TABLE . " WHERE num=?;" );
        $sth->execute($parent);
        if ( ( $sth->fetchrow_array() )[0] ) { $autosage = 1; }

        # check for sage, or too many replies
        unless ( $email =~ /sage/i
            or sage_count($parent_res) > MAX_RES
	    and MAX_RES ne 0
            or $autosage )
        {
            $sth =
              $dbh->prepare( "UPDATE "
                  . SQL_TABLE
                  . " SET lasthit=$time WHERE num=? OR parent=?;" )
              ;    # or make_error(S_SQLFAIL);
            $sth->execute( $parent, $parent ) or make_error(S_SQLFAIL);
        }
        if ( sage_count($parent_res) > MAX_RES and MAX_RES ne 0) {
            $sth =
              $dbh->prepare( "UPDATE "
                  . SQL_TABLE
                  . " SET autosage=1 WHERE num=? OR parent=?;" )
              ;    # or make_error(S_SQLFAIL);
            $sth->execute( $parent, $parent ) or make_error(S_SQLFAIL);
        }
        if ($isAdminPost) {
            $sth =
              $dbh->prepare( "UPDATE "
                  . SQL_TABLE
                  . " SET adminpost=1 WHERE parent=? ORDER BY num DESC LIMIT 1;"
              );    # oh, you ugly fix :3
            $sth->execute($parent);    # or make_error(S_SQLFAIL);

        }
    }

    # remove old threads from the database
    trim_database();

    # set the name, email and password cookies
    make_cookies(
        name      => $c_name,
        email     => $c_email,
        gb2       => $c_gb2,
        password  => $c_password,
        -charset  => CHARSET,
        -autopath => COOKIE_PATH
    );    # yum!

	if(!$admin)
	{
	    # forward back to the main page
	    make_http_forward( HTML_SELF, ALTERNATE_REDIRECT ) if ( $parent eq '0' );
	    make_http_forward( HTML_SELF . "?task=show&thread=" . $parent,
	        ALTERNATE_REDIRECT )
	      if ( $c_gb2 =~ /thread/i );
	    make_http_forward( HTML_SELF, ALTERNATE_REDIRECT );
	}
	else
	{
		# forward back to moderation page
	    make_http_forward( HTML_SELF ."?task=show&amp;page=0&amp;admin=$admin", ALTERNATE_REDIRECT ) if ( $parent eq '0' );
	    make_http_forward( HTML_SELF . "?task=show&amp;thread=" . $parent . "&amp;admin=$admin",
	        ALTERNATE_REDIRECT )
	      if ( $c_gb2 =~ /thread/i );
	    make_http_forward( HTML_SELF . "?task=show&amp;page=0&amp;admin=$admin", ALTERNATE_REDIRECT );
	}
}

sub is_whitelisted {
    my ($numip) = @_;
    my ($sth);

    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . SQL_ADMIN_TABLE
          . " WHERE type='whitelist' AND ? & ival2 = ival1 & ival2;" )
      or make_error(S_SQLFAIL);
    $sth->execute($numip) or make_error(S_SQLFAIL);

    return 1 if ( ( $sth->fetchrow_array() )[0] );

    return 0;
}

sub make_kontra {
    my ( $admin, $threadid ) = @_;
    check_password( $admin, ADMIN_PASS );
    my ( $sth, $row );
    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($threadid) or make_error(S_SQLFAIL);
    if ( $row = $sth->fetchrow_hashref() ) {
        my $kontra = $$row{autosage} eq 1 ? 0 : 1;
        my $sth2;
        $sth2 = $dbh->prepare(
            "UPDATE " . SQL_TABLE . " SET autosage=? WHERE num=?;" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $kontra, $threadid ) or make_error(S_SQLFAIL);
    }
    make_http_forward( get_script_name() . "?admin=$admin&task=mpanel",
        ALTERNATE_REDIRECT );

}

sub is_trusted {
    my ($trip) = @_;
    my ($sth);
    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . SQL_ADMIN_TABLE
          . " WHERE type='trust' AND sval1 = ?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($trip) or make_error(S_SQLFAIL);

    return 1 if ( ( $sth->fetchrow_array() )[0] );

    return 0;
}

sub check_locked {
    my ($parent) = @_;
    my $sth;
    $sth = $dbh->prepare( "SELECT locked FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($parent) or make_error(S_SQLFAIL);
    if ( ( $sth->fetchrow_array() )[0] ) { make_error(S_LOCKED); }
}

sub ban_check {
    my ( $numip, $name, $subject, $comment ) = @_;
    my ($sth);

    my $sth2;
    my $row;
    my ( $reason, $mask, $id );
    my $iph = new Net::IP($numip);
    my $ip  = $iph->ip() unless !$iph;
    my $ip  = dec_to_dot($numip);
    my $_ip;

    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . SQL_ADMIN_TABLE
          . " WHERE type='ipban' AND ? & ival2 = ival1 & ival2;" )
      or make_error(S_SQLFAIL);
    $sth->execute($numip) or make_error(S_SQLFAIL);

    $sth2 =
      $dbh->prepare( "SELECT num,comment,ival2 FROM "
          . SQL_ADMIN_TABLE
          . " WHERE type='ipban' AND ? & ival2 = ival1 & ival2;" );
    $sth2->execute($numip) or make_error(S_SQLFAIL);
    while ( $row = $sth2->fetchrow_arrayref() ) {
        $id = $$row[0];
        my $_mask = new Net::IP( dec_to_dot($$row[2]) );
        $mask   = $_mask->ip();
        $reason = $$row[1];
    }
    $_ip = new Net::IP( $ip . '/' . $mask );
    make_ban( $ip, $_ip->prefix(), $reason, $_ip->size(), 0 )
      if ( ( $sth->fetchrow_array() )[0] );

# fucking mysql...
#	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='wordban' AND ? LIKE '%' || sval1 || '%';") or make_error(S_SQLFAIL);
#	$sth->execute($comment) or make_error(S_SQLFAIL);
#
#	make_error(S_STRREF) if(($sth->fetchrow_array())[0]);

    $sth =
      $dbh->prepare( "SELECT sval1,comment FROM "
          . SQL_ADMIN_TABLE
          . " WHERE type='wordban';" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    while ( $row = $sth->fetchrow_arrayref() ) {
        my $regexp = quotemeta $$row[0];

        #		make_error(S_STRREF) if($comment=~/$regexp/);
        if ( $comment =~ /$regexp/ ) {
            $comment = $$row[1];

            #make_error($$row[1]);
        }
        make_error(S_STRREF) if ( $name    =~ /$regexp/ );
        make_error(S_STRREF) if ( $subject =~ /$regexp/ );
    }

    # etc etc etc

    return (0);
}

sub flood_check {
    my ( $ip, $time, $comment, $file ) = @_;
    my ( $sth, $maxtime );

    if ($file) {

        # check for to quick file posts
        $maxtime = $time - (RENZOKU2);
        $sth =
          $dbh->prepare( "SELECT count(*) FROM "
              . SQL_TABLE
              . " WHERE ip=? AND timestamp>$maxtime;" )
          or make_error(S_SQLFAIL);
        $sth->execute($ip) or make_error(S_SQLFAIL);
        make_error(S_RENZOKU2) if ( ( $sth->fetchrow_array() )[0] );
    }
    else {

        # check for too quick replies or text-only posts
        $maxtime = $time - (RENZOKU);
        $sth =
          $dbh->prepare( "SELECT count(*) FROM "
              . SQL_TABLE
              . " WHERE ip=? AND timestamp>$maxtime;" )
          or make_error(S_SQLFAIL);
        $sth->execute($ip) or make_error(S_SQLFAIL);
        make_error(S_RENZOKU) if ( ( $sth->fetchrow_array() )[0] );

        # check for repeated messages
        $maxtime = $time - (RENZOKU3);
        $sth =
          $dbh->prepare( "SELECT count(*) FROM "
              . SQL_TABLE
              . " WHERE ip=? AND comment=? AND timestamp>$maxtime;" )
          or make_error(S_SQLFAIL);
        $sth->execute( $ip, $comment ) or make_error(S_SQLFAIL);
        make_error(S_RENZOKU3) if ( ( $sth->fetchrow_array() )[0] );
    }
}

sub proxy_check {
    my ($ip) = @_;
    my ($sth);

    proxy_clean();

    # check if IP is from a known banned proxy
    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . SQL_PROXY_TABLE
          . " WHERE type='black' AND ip = ?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($ip) or make_error(S_SQLFAIL);

    make_error(S_BADHOSTPROXY) if ( ( $sth->fetchrow_array() )[0] );

    # check if IP is from a known non-proxy
    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . SQL_PROXY_TABLE
          . " WHERE type='white' AND ip = ?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($ip) or make_error(S_SQLFAIL);

    my $timestamp = time();
    my $date = make_date( $timestamp, DATE_STYLE );

    if ( ( $sth->fetchrow_array() )[0] ) {    # known good IP, refresh entry
        $sth =
          $dbh->prepare( "UPDATE "
              . SQL_PROXY_TABLE
              . " SET timestamp=?, date=? WHERE ip=?;" )
          or make_error(S_SQLFAIL);
        $sth->execute( $timestamp, $date, $ip ) or make_error(S_SQLFAIL);
    }
    else {                                    # unknown IP, check for proxy
        my $command = PROXY_COMMAND . " " . $ip;
        $sth = $dbh->prepare(
            "INSERT INTO " . SQL_PROXY_TABLE . " VALUES(null,?,?,?,?);" )
          or make_error(S_SQLFAIL);

        if (`$command`) {
            $sth->execute( 'black', $ip, $timestamp, $date )
              or make_error(S_SQLFAIL);
            make_error(S_PROXY);
        }
        else {
            $sth->execute( 'white', $ip, $timestamp, $date )
              or make_error(S_SQLFAIL);
        }
    }
}

sub add_proxy_entry {
    my ( $admin, $type, $ip, $timestamp, $date ) = @_;
    my ($sth);

    check_password( $admin, ADMIN_PASS );

    # Verifies IP range is sane. The price for a human-readable db...
    unless ( $ip =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
        && $1 <= 255
        && $2 <= 255
        && $3 <= 255
        && $4 <= 255 )
    {
        make_error(S_BADIP);
    }
    if ( $type == 'white' ) {
        $timestamp = $timestamp - PROXY_WHITE_AGE + time();
    }
    else {
        $timestamp = $timestamp - PROXY_BLACK_AGE + time();
    }

    # This is to ensure user doesn't put multiple entries for the same IP
    $sth = $dbh->prepare( "DELETE FROM " . SQL_PROXY_TABLE . " WHERE ip=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($ip) or make_error(S_SQLFAIL);

    # Add requested entry
    $sth = $dbh->prepare(
        "INSERT INTO " . SQL_PROXY_TABLE . " VALUES(null,?,?,?,?);" )
      or make_error(S_SQLFAIL);
    $sth->execute( $type, $ip, $timestamp, $date ) or make_error(S_SQLFAIL);

    make_http_forward( get_script_name() . "?admin=$admin&task=proxy",
        ALTERNATE_REDIRECT );
}

sub proxy_clean {
    my ( $sth, $timestamp );

    if ( PROXY_BLACK_AGE == PROXY_WHITE_AGE ) {
        $timestamp = time() - PROXY_BLACK_AGE;
        $sth       = $dbh->prepare(
            "DELETE FROM " . SQL_PROXY_TABLE . " WHERE timestamp<?;" )
          or make_error(S_SQLFAIL);
        $sth->execute($timestamp) or make_error(S_SQLFAIL);
    }
    else {
        $timestamp = time() - PROXY_BLACK_AGE;
        $sth =
          $dbh->prepare( "DELETE FROM "
              . SQL_PROXY_TABLE
              . " WHERE type='black' AND timestamp<?;" )
          or make_error(S_SQLFAIL);
        $sth->execute($timestamp) or make_error(S_SQLFAIL);

        $timestamp = time() - PROXY_WHITE_AGE;
        $sth =
          $dbh->prepare( "DELETE FROM "
              . SQL_PROXY_TABLE
              . " WHERE type='white' AND timestamp<?;" )
          or make_error(S_SQLFAIL);
        $sth->execute($timestamp) or make_error(S_SQLFAIL);
    }
}

sub remove_proxy_entry {
    my ( $admin, $num ) = @_;
    my ($sth);

    check_password( $admin, ADMIN_PASS );

    $sth = $dbh->prepare( "DELETE FROM " . SQL_PROXY_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($num) or make_error(S_SQLFAIL);

    make_http_forward( get_script_name() . "?admin=$admin&task=proxy",
        ALTERNATE_REDIRECT );

}

sub format_comment {
    my ($comment) = @_;

    # hide >>1 references from the quoting code
    $comment =~ s/&gt;&gt;([0-9\-]+)/&gtgt;$1/g;

    my $handler = sub    # fix up >>1 references
    {
        my $line = shift;

        $line =~ s!&gtgt;([0-9]+)!
			my $res=get_post($1);
			if($res) { '<a href="'.get_reply_link($$res{num},$$res{parent}).'" onclick="highlight('.$1.')">&gt;&gt;'.$1.'</a>' }
			else { "&gt;&gt;$1"; }
		!ge;

        return $line;
    };

    if ( ENABLE_WAKABAMARK && ENABLE_BBCODE ) {
        make_error("only activate either BBCODE or WAKABAMARK");
    }

    if (ENABLE_WAKABAMARK) { $comment = do_wakabamark( $comment, $handler ) }
    elsif (ENABLE_BBCODE) { $comment = do_bbcode( $comment, $handler ) }
    else { $comment = "<p>" . simple_format( $comment, $handler ) . "</p>" }

    # fix <blockquote> styles for old stylesheets
    $comment =~ s/<blockquote>/<blockquote class="unkfunc">/g;

    # restore >>1 references hidden in code blocks
    $comment =~ s/&gtgt;/&gt;&gt;/g;

    # restore >>1 references hidden in bbcode-code blocks
    $comment =~ s/&gtgt_;/&gt;&gt;/g;

    # restore quotes hidden in bbcode-code blocks
    $comment =~ s/&gt_;/&gt;/g;

    return $comment;
}

sub simple_format {
    my ( $comment, $handler ) = @_;
    return join "<br />", map {
        my $line = $_;

        # make URLs into links
        $line =~
s{(https?://[^\s<>"]*?)((?:\s|<|>|"|\.|\)|\]|!|\?|,|&#44;|&quot;)*(?:[\s<>"]|$))}{\<a href="$1"\>$1\</a\>$2}sgi;

        # colour quoted sections if working in old-style mode.
        $line =~ s!^(&gt;.*)$!\<span class="unkfunc"\>$1\</span\>!g
          unless (ENABLE_WAKABAMARK);

        $line = $handler->($line) if ($handler);

        $line;
    } split /\n/, $comment;
}

sub encode_string {
    my ($str) = @_;

    return $str unless ($has_encode);
    return encode( CHARSET, $str, 0x0400 );
}

sub make_anonymous {
    my ( $ip, $time ) = @_;

    return S_ANONAME unless (SILLY_ANONYMOUS);

    my $string = $ip;
    $string .= "," . int( $time / 86400 ) if ( SILLY_ANONYMOUS =~ /day/i );
    $string .= "," . $ENV{SCRIPT_NAME} if ( SILLY_ANONYMOUS =~ /board/i );

    srand unpack "N", hide_data( $string, 4, "silly", SECRET );

    return cfg_expand(
        "%G% %W%",
        W => [
            "%B%%V%%M%%I%%V%%F%", "%B%%V%%M%%E%",
            "%O%%E%",             "%B%%V%%M%%I%%V%%F%",
            "%B%%V%%M%%E%",       "%O%%E%",
            "%B%%V%%M%%I%%V%%F%", "%B%%V%%M%%E%"
        ],
        B => [
            "B",  "B",  "C",  "D",  "D", "F", "F", "G", "G",  "H",
            "H",  "M",  "N",  "P",  "P", "S", "S", "W", "Ch", "Br",
            "Cr", "Dr", "Bl", "Cl", "S"
        ],
        I => [
            "b", "d", "f", "h", "k",  "l", "m", "n",
            "p", "s", "t", "w", "ch", "st"
        ],
        V => [ "a", "e", "i", "o", "u" ],
        M => [
            "ving",  "zzle",  "ndle",  "ddle",  "ller", "rring",
            "tting", "nning", "ssle",  "mmer",  "bber", "bble",
            "nger",  "nner",  "sh",    "ffing", "nder", "pper",
            "mmle",  "lly",   "bling", "nkin",  "dge",  "ckle",
            "ggle",  "mble",  "ckle",  "rry"
        ],
        F => [
            "t",  "ck",  "tch", "d",   "g",   "n",
            "t",  "t",   "ck",  "tch", "dge", "re",
            "rk", "dge", "re",  "ne",  "dging"
        ],
        O => [
            "Small",    "Snod",   "Bard",    "Billing",
            "Black",    "Shake",  "Tilling", "Good",
            "Worthing", "Blythe", "Green",   "Duck",
            "Pitt",     "Grand",  "Brook",   "Blather",
            "Bun",      "Buzz",   "Clay",    "Fan",
            "Dart",     "Grim",   "Honey",   "Light",
            "Murd",     "Nickle", "Pick",    "Pock",
            "Trot",     "Toot",   "Turvey"
        ],
        E => [
            "shaw",  "man",   "stone", "son",   "ham",   "gold",
            "banks", "foot",  "worth", "way",   "hall",  "dock",
            "ford",  "well",  "bury",  "stock", "field", "lock",
            "dale",  "water", "hood",  "ridge", "ville", "spear",
            "forth", "will"
        ],
        G => [
            "Albert",    "Alice",     "Angus",     "Archie",
            "Augustus",  "Barnaby",   "Basil",     "Beatrice",
            "Betsy",     "Caroline",  "Cedric",    "Charles",
            "Charlotte", "Clara",     "Cornelius", "Cyril",
            "David",     "Doris",     "Ebenezer",  "Edward",
            "Edwin",     "Eliza",     "Emma",      "Ernest",
            "Esther",    "Eugene",    "Fanny",     "Frederick",
            "George",    "Graham",    "Hamilton",  "Hannah",
            "Hedda",     "Henry",     "Hugh",      "Ian",
            "Isabella",  "Jack",      "James",     "Jarvis",
            "Jenny",     "John",      "Lillian",   "Lydia",
            "Martha",    "Martin",    "Matilda",   "Molly",
            "Nathaniel", "Nell",      "Nicholas",  "Nigel",
            "Oliver",    "Phineas",   "Phoebe",    "Phyllis",
            "Polly",     "Priscilla", "Rebecca",   "Reuben",
            "Samuel",    "Sidney",    "Simon",     "Sophie",
            "Thomas",    "Walter",    "Wesley",    "William"
        ],
    );
}

sub make_id_code {
    my ( $ip, $time, $link ) = @_;

    return EMAIL_ID if ( $link and DISPLAY_ID =~ /link/i );
    return EMAIL_ID if ( $link =~ /sage/i and DISPLAY_ID =~ /sage/i );

    return resolve_host( $ENV{REMOTE_ADDR} ) if ( DISPLAY_ID =~ /host/i );
    return $ENV{REMOTE_ADDR} if ( DISPLAY_ID =~ /ip/i );

    my $string = "";
    $string .= "," . int( $time / 86400 ) if ( DISPLAY_ID =~ /day/i );
    $string .= "," . $ENV{SCRIPT_NAME} if ( DISPLAY_ID =~ /board/i );

    return mask_ip( $ENV{REMOTE_ADDR},
        make_key( "mask", SECRET, 32 ) . $string )
      if ( DISPLAY_ID =~ /mask/i );

    return hide_data( $ip . $string, 6, "id", SECRET, 1 );
}

sub get_post {
    my ($thread) = @_;
    my ($sth);

    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($thread) or make_error(S_SQLFAIL);

    return $sth->fetchrow_hashref();
}

sub get_parent_post {
    my ($thread) = @_;
    my ($sth);

    $sth = $dbh->prepare(
        "SELECT * FROM " . SQL_TABLE . " WHERE num=? AND parent=0;" )
      or make_error(S_SQLFAIL);
    $sth->execute($thread) or make_error(S_SQLFAIL);

    return $sth->fetchrow_hashref();
}

sub sage_count {
    my ($parent) = @_;
    my ($sth);

    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . SQL_TABLE
          . " WHERE parent=? AND NOT ( timestamp<? AND ip=? );" )
      or make_error(S_SQLFAIL);
    $sth->execute( $$parent{num}, $$parent{timestamp} + (NOSAGE_WINDOW),
        $$parent{ip} )
      or make_error(S_SQLFAIL);

    return ( $sth->fetchrow_array() )[0];
}

sub get_file_size {
    my ($file) = @_;
    my ($size);
    my ($ext) = $file =~ /\.([^\.]+)$/;
    my %sizehash = FILESIZES;

    $size = stat($file)->size;
    if ( $sizehash{$ext} ) {
        make_error(S_TOOBIG) if ( $size > $sizehash{$ext} * 1024 );
    }
    else {
        make_error(S_TOOBIG) if ( $size > MAX_KB * 1024 );
    }
    make_error(S_TOOBIGORNONE) if ( $size == 0 );  # check for small files, too?

    return ($size);
}


sub get_preview {
    my ($comment) = @_;
    my $preview;
# remove linebreaks
    $comment =~ s/\r?\n|\r\n|\r|\n/ /g;
# remove control chars
    $comment =~ s/[\000-\037]/ /g;
# shorten string
    $preview = substr($comment, 0, 70);
# append ... if length above 50
    if(length($preview) >= 70) {
	$preview = $preview . "...";
    }
    return $preview;
}

sub get_displaysize {
    my ($size) = @_;
    my $displaysize = $size;
    $displaysize = sprintf( "%d B", $size ) if ( $size < 1024 );
    $displaysize = sprintf( "%.2f K", $displaysize / 1024 )
      if ( $displaysize > 1024 );    #KB
    $displaysize = sprintf( "%.2f M", $displaysize / 1024 )
      if ( $displaysize > 1024 );    #MB
    return $displaysize;
}

sub process_file {
    my ( $file, $uploadname, $time ) = @_;
    my %filetypes = FILETYPES;

# make sure to read file in binary mode on platforms that care about such things
    binmode $file;

    # analyze file and check that it's in a supported format
    my ( $ext, $width, $height ) = analyze_image( $file, $uploadname );

    #my ($known,$ext,$width,$height) = analyze_file($file, $uploadname);

    my $known = ( $width or $filetypes{$ext} );

    make_error(S_BADFORMAT) unless ( ALLOW_UNKNOWN or $known );
    make_error(S_BADFORMAT) if ( grep { $_ eq $ext } FORBIDDEN_EXTENSIONS );
    make_error(S_TOOBIG) if ( MAX_IMAGE_WIDTH  and $width > MAX_IMAGE_WIDTH );
    make_error(S_TOOBIG) if ( MAX_IMAGE_HEIGHT and $height > MAX_IMAGE_HEIGHT );
    make_error(S_TOOBIG)
      if ( MAX_IMAGE_PIXELS and $width * $height > MAX_IMAGE_PIXELS );

    # generate random filename - fudges the microseconds
    my $filebase  = $time . sprintf( "%03d", int( rand(1000) ) );
    my $filename  = IMG_DIR . $filebase . '.' . $ext;
    my $thumbnail = THUMB_DIR . $filebase;
	if ( $ext eq "png" )
	{
		$thumbnail .= "s.png";
	}
	elsif ( $ext eq "gif" )
	{
		$thumbnail .= "s.gif";
	}
	else
	{
		$thumbnail .= "s.jpg";
	}

    $filename .= MUNGE_UNKNOWN unless ($known);

    # do copying and MD5 checksum
    my ( $md5, $md5ctx, $buffer );

    # prepare MD5 checksum if the Digest::MD5 module is available
    eval 'use Digest::MD5 qw(md5_hex)';
    $md5ctx = Digest::MD5->new unless ($@);

    # copy file
    open( OUTFILE, ">>$filename" ) or make_error(S_NOTWRITE);
    binmode OUTFILE;
    while ( read( $file, $buffer, 1024 ) )    # should the buffer be larger?
    {
        print OUTFILE $buffer;
        $md5ctx->add($buffer) if ($md5ctx);
    }
    close $file;
    close OUTFILE;

#	if($md5ctx) # if we have Digest::MD5, get the checksum
#	{
#		$md5=$md5ctx->hexdigest();
#	}
#	else # otherwise, try using the md5sum command
#	{
#		my $md5sum=`md5sum $filename`; # filename is always the timestamp name, and thus safe
#		($md5)=$md5sum=~/^([0-9a-f]+)/ unless($?);
#	}

#	if($md5) # if we managed to generate an md5 checksum, check for duplicate files
#	{
#		my $sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE md5=?;") or make_error(S_SQLFAIL);
#		$sth->execute($md5) or make_error(S_SQLFAIL);
#
#		if(my $match=$sth->fetchrow_hashref())
#		{
#			unlink $filename; # make sure to remove the file
#			make_error(sprintf(S_DUPE,get_reply_link($$match{num},$$match{parent})));
#		}
#	}

    # do thumbnail
    my ( $tn_width, $tn_height, $tn_ext );

    if ( !$width or !$filename =~ /\.svg$/ )    # unsupported file
    {
        if ( $filetypes{$ext} )                 # externally defined filetype
        {
            open THUMBNAIL, $filetypes{$ext};
            binmode THUMBNAIL;
            ( $tn_ext, $tn_width, $tn_height ) =
              analyze_image( \*THUMBNAIL, $filetypes{$ext} );
            close THUMBNAIL;

            # was that icon file really there?
            if   ( !$tn_width ) { $thumbnail = undef }
            else                { $thumbnail = $filetypes{$ext} }
        }
        else {
            $thumbnail = undef;
        }
    }
    elsif ($width > MAX_W
        or $height > MAX_H
        or THUMBNAIL_SMALL
        or $filename =~ /\.svg$/ )
    {
        if ( $width <= MAX_W and $height <= MAX_H ) {
            $tn_width  = $width;
            $tn_height = $height;
        }
        else {
            $tn_width = MAX_W;
            $tn_height = int( ( $height * (MAX_W) ) / $width );

            if ( $tn_height > MAX_H ) {
                $tn_width = int( ( $width * (MAX_H) ) / $height );
                $tn_height = MAX_H;
            }
        }

        if (STUPID_THUMBNAILING) { $thumbnail = $filename }
        else {
            $thumbnail = undef
              unless (
                make_thumbnail(
                    $filename,         $thumbnail,
                    $tn_width,         $tn_height,
                    THUMBNAIL_QUALITY, CONVERT_COMMAND
                )
              );
        }
    }
    else {
        $tn_width  = $width;
        $tn_height = $height;
        $thumbnail = $filename;
    }

    #	if($filetypes{$ext}) # externally defined filetype - restore the name
    #	{
    #		my $newfilename=$uploadname;
    #		$newfilename=~s!^.*[\\/]!!; # cut off any directory in filename
    #		$newfilename=IMG_DIR.$newfilename;
    #
    #		unless(-e $newfilename) # verify no name clash
    #		{
    #			rename $filename,$newfilename;
    #			$thumbnail=$newfilename if($thumbnail eq $filename);
    #			$filename=$newfilename;
    #		}
    #		else
    #		{
    #			unlink $filename;
    #			make_error(S_DUPENAME);
    #		}
    #	}

    if (ENABLE_LOAD) {    # only called if files to be distributed across web
        $ENV{SCRIPT_NAME} =~ m!^(.*/)[^/]+$!;
        my $root = $1;
        system( LOAD_SENDER_SCRIPT. " $filename $root $md5 &" );
    }

    return ( clean_string( decode_string( $filename, CHARSET ) ), $md5, $width, $height, $thumbnail, $tn_width,
        $tn_height );
}

#
# Deleting
#

sub delete_stuff {
    my ( $password, $fileonly, $archive, $admin, @posts ) = @_;
    my ($post);
    my $deletebyip = 0;

    check_password( $admin, ADMIN_PASS ) if ($admin);
    if ( !$password and !$admin ) { $deletebyip = 1; }
    make_error(S_BADDELPASS)
      unless ( ( !$password and $deletebyip )
        or ( $password and !$deletebyip )
        or $admin );    # allow deletion by ip with empty password
                        # no password means delete always

    $password = "" if ($admin);

    foreach $post (@posts) {
        delete_post( $post, $password, $fileonly, $archive, $deletebyip, $admin );
    }

    if ($admin) {
        make_http_forward( get_script_name() . "?admin=$admin&task=mpanel",
            ALTERNATE_REDIRECT );
    }
    else { make_http_forward( HTML_SELF, ALTERNATE_REDIRECT ); }
}

sub make_locked {
    my ( $admin, $threadid ) = @_;

    check_password( $admin, ADMIN_PASS );

    my ( $sth, $row );
    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($threadid) or make_error(S_SQLFAIL);

    if ( $row = $sth->fetchrow_hashref() ) {
        my $locked = $$row{locked} eq 1 ? 0 : 1;
        my $sth2;
        $sth2 =
          $dbh->prepare( "UPDATE " . SQL_TABLE . " SET locked=? WHERE num=?;" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $locked, $threadid ) or make_error(S_SQLFAIL);
    }
    make_http_forward( get_script_name() . "?admin=$admin&task=mpanel",
        ALTERNATE_REDIRECT );
}

sub make_sticky {
    my ( $admin, $threadid ) = @_;

    check_password( $admin, ADMIN_PASS );

    my ( $sth, $row );
    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($threadid) or make_error(S_SQLFAIL);

    if ( $row = $sth->fetchrow_hashref() ) {
        my $sticky = $$row{sticky} eq 1 ? 0 : 1;
        my $sth2;
        $sth2 =
          $dbh->prepare( "UPDATE " . SQL_TABLE . " SET sticky=? WHERE num=?;" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $sticky, $threadid ) or make_error(S_SQLFAIL);
        my $threadchilds = $dbh->prepare(
            "UPDATE " . SQL_TABLE . " SET sticky=? WHERE parent=?;" )
          or make_error(S_SQLFAIL);
        $threadchilds->execute( $sticky, $threadid ) or make_error(S_SQLFAIL);
    }

    make_http_forward( get_script_name() . "?admin=$admin&task=mpanel",
        ALTERNATE_REDIRECT );
}

sub delete_post {
    my ( $post, $password, $fileonly, $archiving, $deletebyip, $admin ) = @_;
    my ( $sth, $row, $res, $reply );

	if(defined($admin))
	{
		check_password($admin, ADMIN_PASS);
	}

    my $thumb   = THUMB_DIR;
    my $archive = ARCHIVE_DIR;
    my $src     = IMG_DIR;
    my $ip      = dot_to_dec( $ENV{REMOTE_ADDR} );
    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($post) or make_error(S_SQLFAIL);

    if ( $row = $sth->fetchrow_hashref() ) {
        make_error(S_BADDELPASS)
          if ( $password and $$row{password} ne $password );
        make_error(S_BADDELIP)
          if ( $deletebyip and ( $ip and $$row{ip} ne $ip ) );

        unless ($fileonly) {

            # remove files from comment and possible replies
            $sth = $dbh->prepare(
                    "SELECT image,thumbnail,imageid_1,imageid_2,imageid_3 FROM "
                  . SQL_TABLE
                  . " WHERE num=? OR parent=?" )
              or make_error(S_SQLFAIL);
            $sth->execute( $post, $post ) or make_error(S_SQLFAIL);

            while ( $res = $sth->fetchrow_hashref() ) {
                my @secondaryImages =
                  ( $$res{imageid_1}, $$res{imageid_2}, $$res{imageid_3} );
                foreach my $secImgID (@secondaryImages) {
                    my $sth2 =
                      $dbh->prepare( "SELECT image,thumbnail FROM "
                          . SQL_TABLE_IMG
                          . " WHERE timestamp=?" )
                      or make_error(S_SQLFAIL);
                    $sth2->execute($secImgID);
                    my $res2 = $sth2->fetchrow_hashref();
                    system( LOAD_SENDER_SCRIPT. " $$res2{image} &" )
                      if (ENABLE_LOAD);
                    if ($archiving) {
                        rename $$res2{image}, ARCHIVE_DIR . $$res2{image};
                        rename $$res2{thumbnail},
                          ARCHIVE_DIR . $$res2{thumbnail}
                          if ( $$res2{thumbnail} =~ /^$thumb/ );
                    }
                    else {
                        unlink $$res2{image};
                        unlink $$res2{thumbnail}
                          if ( $$res2{thumbnail} =~ /^$thumb/ );
                    }

                    # remove the row in image table
                    $sth2 = $dbh->prepare(
                        "DELETE FROM " . SQL_TABLE_IMG . " WHERE timestamp=?;" )
                      or make_error(S_SQLFAIL);
                    $sth2->execute($secImgID) or make_error(S_SQLFAIL);
                }

                system( LOAD_SENDER_SCRIPT. " $$res{image} &" )
                  if (ENABLE_LOAD);

                if ($archiving) {

                    # archive images
                    rename $$res{image},     ARCHIVE_DIR . $$res{image};
                    rename $$res{thumbnail}, ARCHIVE_DIR . $$res{thumbnail}
                      if ( $$res{thumbnail} =~ /^$thumb/ );
                }
                else {

                    # delete images if they exist
                    unlink $$res{image};
                    unlink $$res{thumbnail}
                      if ( $$res{thumbnail} =~ /^$thumb/ );
                }
            }

            # remove post and possible replies
            $sth = $dbh->prepare(
                "DELETE FROM " . SQL_TABLE . " WHERE num=? OR parent=?;" )
              or make_error(S_SQLFAIL);
            $sth->execute( $post, $post ) or make_error(S_SQLFAIL);

# prevent GHOST BUMPING by hanging a thread where it belongs: at the time of the last non sage post
            if (PREVENT_GHOST_BUMPING) {

                # first find the parent of the post
                my $parent = $$row{parent};
                if ( $parent != 0 ) {

                    # its actually a post in a thread, not a thread itself
                    # find the thread to check for autosage
                    $sth = $dbh->prepare(
                        "SELECT * FROM " . SQL_TABLE . " WHERE num=?" )
                      or make_error(S_SQLFAIL);
                    $sth->execute($parent);
                    my $threadRow = $sth->fetchrow_hashref();
                    if ( $threadRow and $$threadRow{autosage} != 1 ) {
                        my $sth2;
                        $sth2 =
                          $dbh->prepare( "SELECT * FROM "
                              . SQL_TABLE
                              . " WHERE num=? OR parent=? ORDER BY timestamp DESC"
                          ) or make_error(S_SQLFAIL);
                        $sth2->execute( $parent, $parent );
                        my $postRow;
                        my $foundLastNonSage = 0;
                        while ( ( $postRow = $sth2->fetchrow_hashref() )
                            and $foundLastNonSage == 0 )
                        {

# takes into account, that threads can have SAGE and are of course counted as
# normal post! this is a special case where we accept sage and the timestamp as valid
                            if (  !( $$postRow{email} =~ /sage/i )
                                or ( $$postRow{parent} == 0 ) )
                            {
                                $foundLastNonSage = $$postRow{timestamp};
                            }
                        }
                        if ($foundLastNonSage) {

                   # var now contains the timestamp we have to update lasthit to
                            my $upd;
                            $upd =
                              $dbh->prepare( "UPDATE "
                                  . SQL_TABLE
                                  . " SET lasthit=? WHERE parent=? OR num=?;" )
                              or make_error(S_SQLFAIL);
                            $upd->execute( $foundLastNonSage, $parent, $parent )
                              or make_error( S_SQLFAIL . " " . $dbh->errstr() );
                        }
                    }
                }
            }

        }
        else    # remove just the image and update the database
        {
            if ( $$row{image} ) {
                system( LOAD_SENDER_SCRIPT. " $$row{image} &" )
                  if (ENABLE_LOAD);

                # remove images
                unlink $$row{image};
                unlink $$row{thumbnail} if ( $$row{thumbnail} =~ /^$thumb/ );

                $sth =
                  $dbh->prepare( "UPDATE "
                      . SQL_TABLE
                      . " SET size=0,md5=null,thumbnail=null WHERE num=?;" )
                  or make_error(S_SQLFAIL);
                $sth->execute($post) or make_error(S_SQLFAIL);
            }

            my @secondaryImages =
              ( $$row{imageid_1}, $$row{imageid_2}, $$row{imageid_3} );
            foreach my $secImgID (@secondaryImages) {
                my $sth2 =
                  $dbh->prepare( "SELECT image,thumbnail FROM "
                      . SQL_TABLE_IMG
                      . " WHERE timestamp=?" )
                  or make_error(S_SQLFAIL);
                $sth2->execute($secImgID);
                my $res2 = $sth2->fetchrow_hashref();
                system( LOAD_SENDER_SCRIPT. " $$res2{image} &" )
                  if (ENABLE_LOAD);
                unlink $$res2{image};
                unlink $$res2{thumbnail} if ( $$res2{thumbnail} =~ /^$thumb/ );

                # remove the row in image table
                $sth2 = $dbh->prepare(
                    "DELETE FROM " . SQL_TABLE_IMG . " WHERE timestamp=?;" )
                  or make_error(S_SQLFAIL);
                $sth2->execute($secImgID) or make_error(S_SQLFAIL);
            }
            $sth =
              $dbh->prepare( "UPDATE "
                  . SQL_TABLE
                  . " SET imageid_1=0,imageid_2=0,imageid_3=0 WHERE num=?;" )
              or make_error(S_SQLFAIL);
            $sth->execute($post) or make_error(S_SQLFAIL);

        }

        ###### NOT SURE IF THIS IS NEEDED! (maybe for archiving mode?) ####

        # fix up the thread cache
        if ( !$$row{parent} ) {
            unless ($fileonly)    # removing an entire thread
            {
                if ($archiving) {
                    my $captcha = CAPTCHA_SCRIPT;
                    my $line;

                    open RESIN, '<', RES_DIR . $$row{num} . PAGE_EXT;
                    open RESOUT, '>',
                      ARCHIVE_DIR . RES_DIR . $$row{num} . PAGE_EXT;
                    while ( $line = <RESIN> ) {
                        $line =~
                          s/img src="(.*?)$thumb/img src="$1$archive$thumb/g;
                        if (ENABLE_LOAD)

                        {
                            my $redir = REDIR_DIR;
                            $line =~
s/href="(.*?)$redir(.*?).html/href="$1$archive$src$2/g;
                        }
                        else {
                            $line =~ s/href="(.*?)$src/href="$1$archive$src/g;
                        }
                        $line =~ s/src="[^"]*$captcha[^"]*"/src=""/g
                          if (ENABLE_CAPTCHA);
                        print RESOUT $line;
                    }
                    close RESIN;
                    close RESOUT;
                }
                unlink RES_DIR . $$row{num} . PAGE_EXT;
            }
            else    # removing parent image
            {
                show_thread( $$row{num}, $admin );
            }
        }
        else        # removing a reply, or a reply's image
        {
            show_thread( $$row{parent}, $admin );
        }

        ###### END #####

    }
}

#
# Admin interface
#

sub make_admin_login {
    make_http_header();
    print encode_string( ADMIN_LOGIN_TEMPLATE->() );
}

# TODO: DEPRECATED - remove
sub make_admin_post_panel {
    my ( $admin, $pageToShow ) = @_;
    my ( $sth, $row, @posts, $size, $rowtype );

    check_password( $admin, ADMIN_PASS );

    $sth = $dbh->prepare(
            "SELECT *, sticky IS NULL OR sticky=0 AS sticky_isnull FROM "
          . SQL_TABLE
          . " ORDER BY sticky_isnull ASC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC"
    ) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    my $totalThreadCount = count_threads();
    my $totalPages       = get_page_count_real($totalThreadCount);
    if ( $pageToShow > ( $totalPages - 1 ) ) {
        make_error(S_INVALID_PAGE);
    }

    $size    = 0;
    $rowtype = 1;
    my $displayPage = 0;
    my $threadcount = 0;
    while ( $row = get_decoded_hashref($sth)
        and $threadcount < ( IMAGES_PER_PAGE * ( $pageToShow + 1 ) ) )
    {
        add_secondary_images_to_row($row);
		if($admin) {
			fixup_admin_reference_links($row, $admin);
		}
        if ( !$$row{parent} ) {
            $rowtype = 1;
            $threadcount++;
            if ( $threadcount > IMAGES_PER_PAGE * $pageToShow ) {
                $displayPage = 1;
            }
        }
        else { $rowtype ^= 3; }

        if ($displayPage) {
            $$row{rowtype} = $rowtype;
            $size += $$row{size} + $$row{secondaryimagesize};
            push @posts, $row;
        }
    }

    # make the list of pages
    my @pages = map +{ page => $_ }, ( 0 .. $totalPages - 1 );
    foreach my $p (@pages) {
        if ( $$p{page} == 0 ) {
            $$p{filename} =
              expand_filename("wakaba.pl?task=mpanel&amp;admin=$admin&amp;page=0");
        }    # first page
        else {
            $$p{filename} = expand_filename(
                "wakaba.pl?task=mpanel&amp;admin=$admin&amp;page=" . $$p{page} );
        }
        if ( $$p{page} == $pageToShow ) {
            $$p{current} = 1;
        }    # current page, no link
    }

    my ( $prevpage, $nextpage );
    $prevpage = $pages[ $pageToShow - 1 ]{filename} if ( $pageToShow != 0 );
    $nextpage = $pages[ $pageToShow + 1 ]{filename}
      if ( $pageToShow != $totalPages - 1 );

    make_http_header();
    print encode_string(
        POST_PANEL_TEMPLATE->(
            admin    => $admin,
            posts    => \@posts,
            size     => $size,
            pages    => \@pages,
            prevpage => $prevpage,
            nextpage => $nextpage
        )
    );
}

sub make_admin_ban_panel {
    my ($admin) = @_;
    my ( $sth, $row, @bans, $prevtype );

    check_password( $admin, ADMIN_PASS );

    $sth =
      $dbh->prepare( "SELECT * FROM "
          . SQL_ADMIN_TABLE
          . " WHERE type='ipban' OR type='wordban' OR type='whitelist' OR type='trust' ORDER BY type ASC, num ASC, date ASC;"
      ) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
    while ( $row = get_decoded_hashref($sth) ) {
        $$row{divider} = 1 if ( $prevtype ne $$row{type} );
        $prevtype      = $$row{type};
        $$row{rowtype} = @bans % 2 + 1;
        push @bans, $row;
    }

    make_http_header();
    print encode_string(
        BAN_PANEL_TEMPLATE->( admin => $admin, bans => \@bans ) );
}

sub make_admin_proxy_panel {
    my ($admin) = @_;
    my ( $sth, $row, @scanned, $prevtype );

    check_password( $admin, ADMIN_PASS );

    proxy_clean();

    $sth = $dbh->prepare(
        "SELECT * FROM " . SQL_PROXY_TABLE . " ORDER BY timestamp ASC;" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
    while ( $row = get_decoded_hashref($sth) ) {
        $$row{divider} = 1 if ( $prevtype ne $$row{type} );
        $prevtype      = $$row{type};
        $$row{rowtype} = @scanned % 2 + 1;
        push @scanned, $row;
    }

    make_http_header();
    print encode_string(
        PROXY_PANEL_TEMPLATE->( admin => $admin, scanned => \@scanned ) );
}

sub make_admin_spam_panel {
    my ($admin)    = @_;
    my @spam_files = SPAM_FILES;
    my @spam       = read_array( $spam_files[0] );

    check_password( $admin, ADMIN_PASS );

    make_http_header();
    print encode_string(
        SPAM_PANEL_TEMPLATE->(
            admin     => $admin,
            spamlines => scalar @spam,
            spam      => join "\n",
            map { clean_string( $_, 1 ) } @spam
        )
    );
}

sub make_sql_dump {
    my ($admin) = @_;
    my ( $sth, $row, @database );

    check_password( $admin, ADMIN_PASS );

    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . ";" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
    while ( $row = get_decoded_arrayref($sth) ) {
        push @database,
            "INSERT INTO "
          . SQL_TABLE
          . " VALUES('"
          . ( join "','", map { s/\\/&#92;/g; $_ } @{$row} )
          . # escape ' and \, and join up all values with commas and apostrophes
          "');";
    }

    make_http_header();
    print encode_string(
        SQL_DUMP_TEMPLATE->(
            admin    => $admin,
            database => join "<br />",
            map { clean_string( $_, 1 ) } @database
        )
    );
}

sub make_sql_interface {
    my ( $admin, $nuke, $sql ) = @_;
    my ( $sth, $row, @results );

    check_password( $admin, ADMIN_PASS );

    if ($sql) {
        make_error(S_WRONGPASS) if ( $nuke ne NUKE_PASS ); # check nuke password

        my @statements = grep { /^\S/ } split /\r?\n/,
          decode_string( $sql, CHARSET, 1 );

        foreach my $statement (@statements) {
            push @results, ">>> $statement";
            if ( $sth = $dbh->prepare($statement) ) {
                if ( $sth->execute() ) {
                    while ( $row = get_decoded_arrayref($sth) ) {
                        push @results, join ' | ', @{$row};
                    }
                }
                else { push @results, "!!! " . $sth->errstr() }
            }
            else { push @results, "!!! " . $sth->errstr() }
        }
    }

    make_http_header();
    print encode_string(
        SQL_INTERFACE_TEMPLATE->(
            admin   => $admin,
            nuke    => $nuke,
            results => join "<br />",
            map { clean_string( $_, 1 ) } @results
        )
    );
}

sub make_admin_post {
    my ($admin) = @_;

    check_password( $admin, ADMIN_PASS );

    make_http_header();
    print encode_string( ADMIN_POST_TEMPLATE->( admin => $admin ) );
}

sub do_login {
    my ( $password, $nexttask, $savelogin, $admincookie ) = @_;
    my $crypt;

    if ($password) {
        $crypt = crypt_password($password);
    }
    elsif ( $admincookie eq crypt_password(ADMIN_PASS) ) {
        $crypt    = $admincookie;
        $nexttask = "mpanel";
    }

    if ($crypt) {
        if ( $savelogin and $nexttask ne "nuke" ) {
            make_cookies(
                wakaadmin => $crypt,
                -charset  => CHARSET,
                -autopath => COOKIE_PATH,
                -expires  => time + 365 * 24 * 3600
            );
        }

        make_http_forward( get_script_name() . "?task=$nexttask&amp;admin=$crypt",
            ALTERNATE_REDIRECT );
    }
    else { make_admin_login() }
}

sub do_logout {
    make_cookies( wakaadmin => "", -expires => 1 );
    make_http_forward( get_script_name() . "?task=admin", ALTERNATE_REDIRECT );
}

sub add_admin_entry {
    my ($blame) =
"<br /><span class=\"user_banned\">(USER WURDE F&Uuml;R DIESEN POST GESPERRT)</span>";
    my ( $admin, $type, $comment, $ival1, $ival2, $sval1, $postid ) = @_;
    my ( $sth, $row, $oldcomment, $newcomment, $threadid, $utf8_encoded_json_text);
    my ($time) = time();
    check_password( $admin, ADMIN_PASS );

    $comment = clean_string( decode_string( $comment, CHARSET ) );

    $sth = $dbh->prepare(
        "INSERT INTO " . SQL_ADMIN_TABLE . " VALUES(null,?,?,?,?,?,FROM_UNIXTIME(?));" )
      or make_error(S_SQLFAIL);
    $sth->execute( $type, $comment, $ival1, $ival2, $sval1, $time )
      or make_error(S_SQLFAIL);
    if ($postid) {
        $sth =
          $dbh->prepare( "SELECT num,parent,comment FROM "
              . SQL_TABLE
              . " WHERE num=? LIMIT 1;" )
          or make_error(S_SQLFAIL);
        $sth->execute($postid) or make_error(S_SQLFAIL);
        $row        = get_decoded_hashref($sth);
        $oldcomment = $$row{comment};
        $newcomment = $oldcomment . $blame;
        $threadid   = $$row{parent} if $$row{parent} ne 0;
        $threadid   = $$row{num} if $$row{parent} eq 0;

        $sth = $dbh->prepare(
            "UPDATE " . SQL_TABLE . " SET comment = ? WHERE num=? LIMIT 1;" )
          or make_error(S_SQLFAIL);
        $sth->execute( $newcomment, $postid ) or make_error(S_SQLFAIL);
    }
    $utf8_encoded_json_text = encode_json( { "error_code" => 200, "banned_ip" => dec_to_dot($ival1), "banned_mask" => dec_to_dot($ival2), "reason" => $comment, "postid" => $postid, "debug" => $ival1 } );
    make_http_header();
    print $utf8_encoded_json_text;
    #make_http_forward( get_script_name() . "?admin=$admin&task=bans", ALTERNATE_REDIRECT );
}

sub check_admin_entry {
    my ($admin, $ival1) = @_;
    my ($sth, $utf8_encoded_json_text, $results);
    check_password( $admin, ADMIN_PASS );
    if (!$ival1) {
	$utf8_encoded_json_text = encode_json( { "error_code" => 500, "error_detail" => "Invalid parameter"});
    } else {
	$sth = $dbh->prepare("SELECT COUNT(*) AS count FROM " . SQL_ADMIN_TABLE . " WHERE ival1=?;");
	$sth->execute(dot_to_dec($ival1));
	$results = get_decoded_hashref($sth);

        $utf8_encoded_json_text = encode_json({ "error_code" => 200, "results" => $$results{count}});
	if ($$results{count} eq 0) {
	    $utf8_encoded_json_text = encode_json( { "error_code" => 200, "results" => 0});
	}
    }
    make_http_header();
    print $utf8_encoded_json_text;

}

sub remove_admin_entry {
    my ( $admin, $num ) = @_;
    my ($sth);

    check_password( $admin, ADMIN_PASS );

    $sth = $dbh->prepare( "DELETE FROM " . SQL_ADMIN_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($num) or make_error(S_SQLFAIL);

    make_http_forward( get_script_name() . "?admin=$admin&task=bans",
        ALTERNATE_REDIRECT );
}

sub delete_all {
    my ( $admin, $ip, $mask ) = @_;
    my ( $sth, $row, @posts );

    check_password( $admin, ADMIN_PASS );

    $sth =
      $dbh->prepare( "SELECT num FROM " . SQL_TABLE . " WHERE ip & ? = ? & ?;" )
      or make_error(S_SQLFAIL);
    $sth->execute( $mask, $ip, $mask ) or make_error(S_SQLFAIL);
    while ( $row = $sth->fetchrow_hashref() ) { push( @posts, $$row{num} ); }

    delete_stuff( '', 0, 0, $admin, @posts );
}

sub update_spam_file {
    my ( $admin, $spam ) = @_;

    check_password( $admin, ADMIN_PASS );

    my @spam = split /\r?\n/, $spam;
    my @spam_files = SPAM_FILES;
    write_array( $spam_files[0], @spam );

    make_http_forward( get_script_name() . "?admin=$admin&task=spam",
        ALTERNATE_REDIRECT );
}

sub do_nuke_database {
    my ($admin) = @_;

    check_password( $admin, NUKE_PASS );

    init_database();

    #init_admin_database();
    #init_proxy_database();

    # remove images, thumbnails and threads
    unlink glob IMG_DIR . '*';
    unlink glob THUMB_DIR . '*';
    unlink glob RES_DIR . '*';

    make_http_forward( HTML_SELF, ALTERNATE_REDIRECT );
}

sub check_password {
    my ( $admin, $password ) = @_;

    return if ( $admin eq ADMIN_PASS );
    return if ( $admin eq crypt_password($password) );

    make_error(S_WRONGPASS);
}

sub crypt_password {
    my $crypt = hide_data( (shift) . $ENV{REMOTE_ADDR}, 9, "admin", SECRET, 1 );
    $crypt =~ tr/+/./;    # for web shit
    return $crypt;
}

#
# Page creation utils
#

sub make_http_header {
    print "Content-Type: "
      . get_xhtml_content_type( CHARSET, USE_XHTML ) . "\n";
    print "\n";
}

sub make_json_header {
	print "Content-Type: application/json\n";
	print "Access-Control-Allow-Origin: *\n";
	print "\n";
}

sub make_error {
    my ($error) = @_;

    make_http_header();

    print encode_string(
        ERROR_TEMPLATE->(
            error          => $error,
            error_page     => 'Fehler aufgetreten',
            error_subtitle => 'Fehler aufgetreten',
            error_title    => 'Fehler aufgetreten'
        )
    );

    if ($dbh) {
        $dbh->{Warn} = 0;
        $dbh->disconnect();
    }

    if (ERRORLOG)    # could print even more data, really.
    {
        open ERRORFILE, '>>' . ERRORLOG;
        print ERRORFILE $error . "\n";
        print ERRORFILE $ENV{HTTP_USER_AGENT} . "\n";
        print ERRORFILE "**\n";
        close ERRORFILE;
    }

    # delete temp files

    exit;
}

sub make_ban {
    my ( $ip, $subnet, $reason, $size, $mode ) = @_;

    make_http_header();
    if ( $mode == 1 ) {
        print encode_string(
            ERROR_TEMPLATE->(
                ip             => $ip,
                dnsbl          => $reason,
                error_page     => 'HTTP 403 - Proxy found',
                error_subtitle => 'HTTP 403 - Proxy found',
                error_title    => 'Proxy found'
            )
        );
    }
    else {
        print encode_string(
            ERROR_TEMPLATE->(
                ip             => $ip,
                reason         => $reason,
                subnet         => $subnet,
                size           => $size,
                error_page     => 'Banned',
                error_subtitle => 'GEH ZUR&Uuml;CK NACH KRAUTKANAL!',
                error_title    => 'Banned :<',
                banned         => 1
            )
        );
    }
    if ($dbh) {
        $dbh->{Warn} = 0;
        $dbh->disconnect();
    }
    exit;
}

sub get_script_name {
    return $ENV{SCRIPT_NAME};
}

sub get_secure_script_name {
    return 'https://' . $ENV{SERVER_NAME} . $ENV{SCRIPT_NAME}
      if (USE_SECURE_ADMIN);
    return $ENV{SCRIPT_NAME};
}

sub expand_image_filename {
    my $filename = shift;

    return expand_filename( clean_path($filename) ) unless ENABLE_LOAD;

    my ($self_path) = $ENV{SCRIPT_NAME} =~ m!^(.*/)[^/]+$!;
    my $src = IMG_DIR;
    $filename =~ /$src(.*)/;
    return $self_path . REDIR_DIR . clean_path($1) . '.html';
}

sub get_reply_link {
    my ( $reply, $parent, $admin ) = @_;

	if(defined($admin))
	{
		# TODO: a bit hacky!
		return expand_filename( HTML_SELF."?task=show&amp;thread=$parent&amp;admin=$admin".'#'."$reply" ) if ($parent);
		return expand_filename( HTML_SELF."?task=show&amp;thread=$reply&amp;admin=$admin" );
	}
	else
	{
	    #	return expand_filename(RES_DIR.$parent.PAGE_EXT).'#'.$reply if($parent);
	    #	return expand_filename(RES_DIR.$reply.PAGE_EXT);
	 	return expand_filename( "faden/" . $parent ) . '#' . $reply if ($parent);
   		return expand_filename( "faden/" . $reply );
	}
}

sub get_page_count {
    my ($total) = @_;
    if ( $total > MAX_SHOWN_THREADS ) {
        $total = MAX_SHOWN_THREADS;
    }
    return int( ( $total + IMAGES_PER_PAGE- 1 ) / IMAGES_PER_PAGE );
}

sub get_filetypes {
    my %filetypes = FILETYPES;
    $filetypes{gif} = $filetypes{jpg} = $filetypes{png} = 1;
    return join ", ", map { uc } sort keys %filetypes;
}

#sub dot_to_dec($)
#{
#	return unpack('N',pack('C4',split(/\./, $_[0]))); # wow, magic.
#}

#sub dec_to_dot($)
#{
#	return join('.',unpack('C4',pack('N',$_[0])));
#}

sub parse_range {
    my ( $ip, $mask ) = @_;

    $ip = dot_to_dec($ip) if ( $ip =~ /^\d+\.\d+\.\d+\.\d+$/ );

    if ( $mask =~ /^\d+\.\d+\.\d+\.\d+$/ ) { $mask = dot_to_dec($mask); }
    elsif ( $mask =~ /(\d+)/ ) { $mask = ( ~( ( 1 << $1 ) - 1 ) ); }
    else                       { $mask = 0xffffffff; }

    return ( $ip, $mask );
}

#
# Database utils
#

sub init_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . SQL_TABLE . ";" )
      if ( table_exists(SQL_TABLE) );
    $sth = $dbh->prepare(
            "CREATE TABLE "
          . SQL_TABLE . " ("
          .

          "num "
          . get_sql_autoincrement() . ","
          .    # Post number, auto-increments
          "parent INTEGER,"
          . # Parent post for replies in threads. For original posts, must be set to 0 (and not null)
          "timestamp INTEGER,"
          .    # Timestamp in seconds for when the post was created
          "lasthit INTEGER,"
          . # Last activity in thread. Must be set to the same value for BOTH the original post and all replies!
          "ip TEXT," .    # IP number of poster, in integer form!

          "date TEXT," .        # The date, as a string
          "name TEXT," .        # Name of the poster
          "trip TEXT," .        # Tripcode (encoded)
          "email TEXT," .       # Email address
          "subject TEXT," .     # Subject
          "password TEXT," .    # Deletion password (in plaintext)
          "comment TEXT," .     # Comment text, HTML encoded.

          "image TEXT,"
          . # Image filename with path and extension (IE, src/1081231233721.jpg)
          "size INTEGER," .        # File size in bytes
          "md5 TEXT," .            # md5 sum in hex
          "width INTEGER," .       # Width of image in pixels
          "height INTEGER," .      # Height of image in pixels
          "thumbnail TEXT," .      # Thumbnail filename with path and extension
          "tn_width TEXT," .       # Thumbnail width in pixels
          "tn_height TEXT," .      # Thumbnail height in pixels
          "uploadname TEXT," .     # Thumbnail height in pixels
          "displaysize TEXT" .     # Thumbnail height in pixels

          ");"
    ) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
}

sub init_admin_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . SQL_ADMIN_TABLE . ";" )
      if ( table_exists(SQL_ADMIN_TABLE) );
    $sth = $dbh->prepare(
            "CREATE TABLE "
          . SQL_ADMIN_TABLE . " ("
          .

          "num "
          . get_sql_autoincrement() . ","
          .                    # Entry number, auto-increments
          "type TEXT," .       # Type of entry (ipban, wordban, etc)
          "comment TEXT," .    # Comment for the entry
          "ival1 TEXT," .      # Integer value 1 (usually IP)
          "ival2 TEXT," .      # Integer value 2 (usually netmask)
          "sval1 TEXT" .       # String value 1

          ");"
    ) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
}

sub init_proxy_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . SQL_PROXY_TABLE . ";" )
      if ( table_exists(SQL_PROXY_TABLE) );
    $sth = $dbh->prepare(
            "CREATE TABLE "
          . SQL_PROXY_TABLE . " ("
          .

          "num "
          . get_sql_autoincrement() . ","
          .                         # Entry number, auto-increments
          "type TEXT," .            # Type of entry (black, white, etc)
          "ip TEXT," .              # IP address
          "timestamp INTEGER," .    # Age since epoch
          "date TEXT" .             # Human-readable form of date

          ");"
    ) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
}

sub repair_database {
    my ( $sth, $row, @threads, $thread );

    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE parent=0;" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    while ( $row = $sth->fetchrow_hashref() ) { push( @threads, $row ); }

    foreach $thread (@threads) {

        # fix lasthit
        my ($upd);

        $upd = $dbh->prepare(
            "UPDATE " . SQL_TABLE . " SET lasthit=? WHERE parent=?;" )
          or make_error(S_SQLFAIL);
        $upd->execute( $$thread{lasthit}, $$thread{num} )
          or make_error( S_SQLFAIL . " " . $dbh->errstr() );
    }
}

sub get_sql_autoincrement {
    return 'INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT'
      if ( SQL_DBI_SOURCE =~ /^DBI:mysql:/i );
    return 'INTEGER PRIMARY KEY' if ( SQL_DBI_SOURCE =~ /^DBI:SQLite:/i );
    return 'INTEGER PRIMARY KEY' if ( SQL_DBI_SOURCE =~ /^DBI:SQLite2:/i );

    make_error(S_SQLCONF);  # maybe there should be a sane default case instead?
}

sub trim_database {
    my ( $sth, $row, $order );

    if   ( TRIM_METHOD == 0 ) { $order = 'num ASC'; }
    else                      { $order = 'lasthit ASC'; }

    if (MAX_AGE)            # needs testing
    {
        my $mintime = time() - (MAX_AGE) * 3600;

        $sth =
          $dbh->prepare( "SELECT * FROM "
              . SQL_TABLE
              . " WHERE parent=0 AND timestamp<=$mintime AND (sticky=0 OR sticky IS NULL);"
          ) or make_error(S_SQLFAIL);
        $sth->execute() or make_error(S_SQLFAIL);

        while ( $row = $sth->fetchrow_hashref() ) {
            delete_post( $$row{num}, "", 0, ARCHIVE_MODE, 0 );
        }
    }

    my $threads = count_threads();
    my ( $posts, $size ) = count_posts();
    my $max_threads = ( MAX_THREADS                 or $threads );
    my $max_posts   = ( MAX_POSTS                   or $posts );
    my $max_size    = ( MAX_MEGABYTES * 1024 * 1024 or $size );

    while ($threads > $max_threads
        or $posts > $max_posts
        or $size > $max_size )
    {
        $sth =
          $dbh->prepare( "SELECT * FROM "
              . SQL_TABLE
              . " WHERE parent=0 AND (sticky=0 OR sticky IS NULL) ORDER BY $order LIMIT 1;"
          ) or make_error(S_SQLFAIL);
        $sth->execute() or make_error(S_SQLFAIL);

        if ( $row = $sth->fetchrow_hashref() ) {
            my ( $threadposts, $threadsize ) = count_posts( $$row{num} );

            delete_post( $$row{num}, "", 0, ARCHIVE_MODE, 0 );

            $threads--;
            $posts -= $threadposts;
            $size  -= $threadsize;
        }
        else { last; }    # shouldn't happen
    }
}

sub table_exists {
    my ($table) = @_;
    my ($sth);

    return 0
      unless ( $sth =
        $dbh->prepare( "SELECT * FROM " . $table . " LIMIT 1;" ) );
    return 0 unless ( $sth->execute() );
    return 1;
}

sub count_threads {
    my ($sth);

    $sth =
      $dbh->prepare( "SELECT count(*) FROM " . SQL_TABLE . " WHERE parent=0;" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    return ( $sth->fetchrow_array() )[0];
}

sub count_posts {
    my ($parent) = @_;
    my ( $sth, $where );

    $where = "WHERE parent=$parent or num=$parent" if ($parent);
    $sth = $dbh->prepare(
        "SELECT count(*),sum(size) FROM " . SQL_TABLE . " $where;" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    return $sth->fetchrow_array();
}

sub thread_exists {
    my ($thread) = @_;
    my ($sth);

    $sth = $dbh->prepare(
        "SELECT count(*) FROM " . SQL_TABLE . " WHERE num=? AND parent=0;" )
      or make_error(S_SQLFAIL);
    $sth->execute($thread) or make_error(S_SQLFAIL);

    return ( $sth->fetchrow_array() )[0];
}

sub get_decoded_hashref {
    my ($sth) = @_;

    my $row = $sth->fetchrow_hashref();

    if ( $row and $has_encode ) {
        for my $k (
            keys %$row
          )    # don't blame me for this shit, I got this from perlunicode.
        {
            defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$k};
        }

        if ( SQL_DBI_SOURCE =~ /^DBI:mysql:/i )    # OMGWTFBBQ
        {
            for my $k ( keys %$row ) {
                $$row{$k} =~ s/chr\(([0-9]+)\)/chr($1)/ge if defined;
            }
        }
    }

    return $row;
}

sub get_decoded_arrayref {
    my ($sth) = @_;

    my $row = $sth->fetchrow_arrayref();

    if ( $row and $has_encode ) {

        # don't blame me for this shit, I got this from perlunicode.
        defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;

        if ( SQL_DBI_SOURCE =~ /^DBI:mysql:/i )    # OMGWTFBBQ
        {
            s/chr\(([0-9]+)\)/chr($1)/ge for @$row;
        }
    }

    return $row;

}
