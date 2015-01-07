#!/usr/bin/perl -X

use CGI::Carp qw(fatalsToBrowser set_message);

umask 0022;    # Fix some problems

use strict;
use CGI;
use DBI;
use Net::DNS;
#use Net::IP qw(:PROC);
use HTML::Entities;
use HTML::Strip;
#use Math::BigInt;
use JSON::XS;
use JSON;
use Digest::MD5 qw(md5 md5_hex md5_base64);
#use Image::ExifTool qw(:Public);
use File::stat;
#use File::MimeInfo::Magic;
use IO::Socket;
use IO::Scalar;
use Data::Dumper;


my $sth;
my $JSON = JSON->new->utf8;
$JSON = $JSON->pretty(1);



use constant HANDLER_ERROR_PAGE_HEAD => q{
<!DOCTYPE html>
<html lang="de"> 
<head>
<title>Ernstchan &raquo; Serverfehler</title>
<meta charset="utf-8" />
<link rel="shortcut icon" href="/img/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/css/phutaba.css" />
</head>
<body>
<div class="content">
<header>
	<div class="header">
		<div class="banner"><a href="/"><img src="/banner.pl" alt="Ernstchan" /></a></div>
		<div class="boardname">Serverfehler</div>
	</div>
</header>
	<hr />

<div class="container" style="background-color: rgba(170, 0, 0, 0.2);margin-top: 50px;"> 
<p>

};

use constant HANDLER_ERROR_PAGE_FOOTER => q{

</p>
</div> 
<p style="text-align: center;margin-top: 50px;"><span style="font-size: small; font-style: italic;">This is a <strong>fatal error</strong> in the <em>request/response handler</em>. Please contact the administrator of this site at the <a href="irc://irc.euirc.net/#ernstchan">IRC</a> or via <a href="mailto:admin@ernstchan.net">email</a> and ask him to fix this error</span></p>


	<hr />
	<footer>Powered by <img src="/img/phutaba_icon.png" alt="" /> <strong>Phutaba</strong>.</footer>
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
    require "../lib/config_defaults.pl";
    require "../lib/strings_en.pl"; # need some good replacement
    require "../lib/wakautils.pl";
    require "../lib/futaba_style.pl";
    require "../lib/captcha.pl";
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

$sth = $dbh->prepare("SET NAMES 'latin1';");
$sth->execute() or make_error(S_SQLFAIL);

return 1 if (caller);    # stop here if we're being called externally

my $query = CGI->new;

my $task  = ( $query->param("task") or $query->param("action")) unless $query->param("POSTDATA");
$task = ( $query->url_param("task") ) unless $task;
my $json  = ( $query->param("json") or "" );

# fill meta-data fields of all existing board files. this will run only once after schema migration.
# placed before migration to prevent both functions running in the same script call which could cause a timeout.
update_files_meta();

# schema migration.
update_db_schema();

# schema migration 2 - change location column
update_db_schema2();

# check for admin table
init_admin_database() if ( !table_exists(SQL_ADMIN_TABLE) );

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
	my $admin = $query->cookie("wakaadmin");
	if ($id ne undef) {
		output_json_ban($id, $admin);
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
    show_page(1);
}
elsif ( !$task and !$json ) {
    my $admin  = $query->cookie("wakaadmin");
    # when there is no task, show the first page.
    show_page(1, $admin);
}
elsif ( $task eq "show" ) {
    my $page   = $query->param("page");
    my $thread = $query->param("thread");
    my $post   = $query->param("post");
    my $admin  = $query->cookie("wakaadmin");

    # outputs a single post only
    if (defined($post) and $post =~ /^[+-]?\d+$/)
    {
        show_post($post, $admin);
    }
    # show the requested thread
    elsif (defined($thread) and $thread =~ /^[+-]?\d+$/)
    {
	    if($thread ne 0) {
	        show_thread($thread, $admin);
	    } else {
		    make_error(S_STOP_FOOLING);
	    }
    }
    # show the requested page (if any)
	else
	{
		# fallback to page 1 if parameter was empty or incorrect
		$page = 1 unless (defined($page) and $page =~ /^[+-]?\d+$/);
        show_page($page, $admin);
	}
}
elsif ($task eq "search") {
	my $find			= $query->param("find");
	my $op_only			= $query->param("op");
	my $in_subject		= $query->param("subject");
	my $in_filenames	= $query->param("files");
	my $in_comment		= $query->param("comment");

	find_posts($find, $op_only, $in_subject, $in_filenames, $in_comment);
}
elsif ( $task eq "post" ) {
    my $parent     = $query->param("parent");
    my $spam1      = $query->param("name");
    my $spam2      = $query->param("link");
    my $name       = $query->param("field1");
    my $email      = $query->param("field2");
    my $subject    = $query->param("field3");
    my $comment    = $query->param("field4");
    my $gb2        = $query->param("gb2");
    my $captcha    = $query->param("captcha");
    my $password   = $query->param("password");
    my $admin      = $query->cookie("wakaadmin");
    my $nofile     = $query->param("nofile");
    my $no_captcha = $query->param("no_captcha");
    my $no_format  = $query->param("no_format");
    my $postfix    = $query->param("postfix");
	my $postAsAdmin = $query->param("as_admin");
	my @files = $query->param("file"); # multiple uploads

    post_stuff(
        $parent,  $spam1,   $spam2,      $name,      $email,
        $subject, $comment, $gb2,        $captcha,   $password,
        $admin,   $nofile,  $no_captcha, $no_format, $postfix,
        $postAsAdmin, @files
    );
}
elsif ( $task eq "delete" ) {
    my $password = $query->param("password");
    my $fileonly = $query->param("fileonly");
    my $admin    = $query->cookie("wakaadmin");
	my $parent   = $query->param("parent");
    my @posts    = $query->param("delete");

    delete_stuff( $password, $fileonly, $admin, $parent, @posts );
}
elsif ( $task eq "sticky" ) {
    my $admin    = $query->cookie("wakaadmin");
    my $threadid = $query->param("threadid");
    make_sticky( $admin, $threadid );
}
elsif ( $task eq "kontra" ) {
    my $admin    = $query->cookie("wakaadmin");
    my $threadid = $query->param("threadid");
    make_kontra( $admin, $threadid );

}
elsif ( $task eq "lock" ) {
    my $admin    = $query->cookie("wakaadmin");
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
    my $admin = $query->cookie("wakaadmin");
	make_admin_post_panel($admin);
}
elsif ( $task eq "deleteall" ) {
    my $admin = $query->cookie("wakaadmin");
    my $ip    = $query->param("ip");
    my $mask  = $query->param("mask");
	my $go    = $query->param("go");
    delete_all($admin, parse_range($ip, $mask), $go);
}
elsif ( $task eq "bans" ) {
    my $admin = $query->cookie("wakaadmin");
    make_admin_ban_panel($admin);
}
elsif ( $task eq "addip" ) {
    my $admin   = $query->cookie("wakaadmin");
    my $type    = $query->param("type");
    my $string  = $query->param("string");
    my $comment = $query->param("comment");
    my $ip      = $query->param("ip");
    my $mask    = $query->param("mask");
    my $postid  = $query->param("postid");
	my $ajax    = $query->param("ajax");
    add_admin_entry( $admin, $type, $comment, parse_range( $ip, $mask ),
        $string, $postid, $ajax );
}
elsif ( $task eq "addstring" ) {
    my $admin   = $query->cookie("wakaadmin");
    my $type    = $query->param("type");
    my $string  = $query->param("string");
    my $comment = $query->param("comment");
    add_admin_entry( $admin, $type, $comment, 0, 0, $string, 0, 0 );
}
elsif ( $task eq "checkban" ) {
    my $ival1	= $query->param("ip");
    my $admin   = $query->cookie("wakaadmin");
    check_admin_entry($admin, $ival1);
}
elsif ( $task eq "removeban" ) {
    my $admin = $query->cookie("wakaadmin");
    my $num   = $query->param("num");
    remove_admin_entry( $admin, $num );
}
elsif ( $task eq "mpost" ) {
    my $admin = $query->cookie("wakaadmin");
    make_admin_post($admin);
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
	
	my ( $filename, $md5, $width, $height, $thumbnail, $tn_width, $tn_height, $ignore1, $ignore2, $ignore3 )
		= process_file( $file, $uploadname, $time );

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
else {
	unless ($json) {
		make_http_header();
		print "Unknown task parameter.\n";
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
		add_images_to_row($row);
		$data{'file'} = [
			get_meta($$row{'files'}[0]{'image'}),
			get_meta($$row{'files'}[1]{'image'}),
			get_meta($$row{'files'}[2]{'image'}),
			get_meta($$row{'files'}[3]{'image'})
		];
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
	my ($id, $admin) = @_;
	my ($row, $error, $code, %status, %data, %json);
	use Net::Abuse::Utils qw( :all );

	if (!check_password_silent($admin, ADMIN_PASS)) {
		$code = 401;
		$error = 'Unauthorized';
	} else {
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
		$$row{'comment'} = resolve_reflinks($$row{'comment'});
		$$row{'comment'} = encode_entities(decode('utf8', $$row{'comment'}));
		delete $$row{'ip'};
		delete $$row{'password'};
		delete $$row{'location'};
		add_images_to_row($row);
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
		#check_password($admin, ADMIN_PASS);
		if (check_password_silent($admin, ADMIN_PASS)) { $isAdmin = 1; } else { $admin = ""; }
    }

    $sth = $dbh->prepare(
            "SELECT *, sticky IS NULL OR sticky=0 AS sticky_isnull FROM "
          . SQL_TABLE
          . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute( $id ) or make_error(S_SQLFAIL);
    make_http_header();
	$row = get_decoded_hashref($sth);

    if ($row) {
        add_images_to_row($row);
		$$row{comment} = resolve_reflinks($$row{comment});
        push(@thread, $row);
		my $output =
			encode_string(
				SINGLE_POST_TEMPLATE->(
					thread	     => $id,
					posts        => \@thread,
					single	     => 1,
					isAdmin      => $isAdmin,
					admin        => $admin,
					locked       => $thread[0]{locked}
				)
			);
		$output =~ s/^\s+//; # remove whitespace at the beginning
		$output =~ s/^\s+\n//mg; # remove empty lines
		print($output);
    }
    else {
        print encode_json( { "error_code" => 400, "error_msg" => 'Bad Request' } );
    }
}

sub show_page {
    my ($pageToShow, $admin) = @_;
    my $page = 1;
    my ( $sth, $row, @thread );
	# if we try to call show_page with admin parameter
	# the admin password will be checked and this
	# variable will be 1
	my $isAdmin = 0;
	if(defined($admin))
	{
		#check_password($admin, ADMIN_PASS);
		if (check_password_silent($admin, ADMIN_PASS)) { $isAdmin = 1; } else { $admin = ""; }
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
        output_page( 1, 1, $isAdmin, $admin, () );    # make an empty page 1
    }
    else {
        my $threadcount = 0;
        my @threads;

        my @thread = ($row);

        my $totalThreadCount = count_threads();
        my $total;
		if($isAdmin) {
			$total = get_page_count_real($totalThreadCount);
		}
		else {
			$total = get_page_count($totalThreadCount);
		}
        if ( $pageToShow > ( $total ) ) {
            make_error(S_INVALID_PAGE);
        }

        while ( $row = get_decoded_hashref($sth)
            and $threadcount <= ( IMAGES_PER_PAGE * ( $pageToShow ) ) )
        {
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

		add_images_to_thread(@{$$thread{posts}});

        # split off the parent post, and count the replies and images

        my ( $parent, @replies ) = @{ $$thread{posts} };
        my $replies = @replies;

		# count files in replies - TODO: check for size == 0 for ignoring deleted files
		my $images = 0;
		foreach my $post (@replies) {
			$images += @{$$post{files}} if (exists $$post{files});
		}

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
			# TODO: ignore files with size == 0
			$curr_images -= @{$$post{files}} if (exists $$post{files});
            $curr_replies--;
        }
        # write the shortened list of replies back
        $$thread{posts}      = [ $parent, @replies ];
#        $$thread{omit}       = $replies - $curr_replies;
#        $$thread{omitimages} = $images - $curr_images;
		$$thread{omitmsg}    = get_omit_message($replies - $curr_replies, $images - $curr_images);
		$$thread{num}	     = ${$$thread{posts}}[0]{num};

        # abbreviate the remaining posts
        foreach my $post ( @{ $$thread{posts} } ) {
			# create ref-links
			$$post{comment} = resolve_reflinks($$post{comment});

            my $abbreviation =
              abbreviate_html( $$post{comment}, MAX_LINES_SHOWN,
                APPROX_LINE_LENGTH );
            if ($abbreviation) {
                $$post{abbrev} = get_abbrev_message(count_lines($$post{comment}) - count_lines($abbreviation));
                $$post{comment_full} = $$post{comment};
                $$post{comment} = $abbreviation;
            }
        }
    }

    # make the list of pages
    my @pages = map +{ page => $_ }, ( 1 .. $total );
    foreach my $p (@pages) {
        #if ( $$p{page} == 1 ) {
		#		$$p{filename} = expand_filename("wakaba.pl");			
        #}    # first page
        #else {
			#$$p{filename} = expand_filename( "wakaba.pl?task=show&amp;page=" . $$p{page} );
			$$p{filename} = expand_filename( "page/" . $$p{page} );
        #}
        if ( $$p{page} == $page ) { $$p{current} = 1 }   # current page, no link
    }

    my ( $prevpage, $nextpage );
	# phutaba pages:    1 2 3
	# perl array index: 0 1 2
	# example for page 2: the prev page is at array pos 0, current page at array pos 1, next page at array pos 2
    $prevpage = $pages[ $page - 2 ]{filename} if ( $page != 1 );
    $nextpage = $pages[ $page     ]{filename} if ( $page != $total );

    make_http_header();
	my $loc = get_geolocation(get_remote_addr());
	my $output =
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
		);

	$output =~ s/^\s+\n//mg;
	print($output);
}

sub get_omit_message($$) {
	my ($posts, $files) = @_;
	return "" if !$posts;

	my $omitposts = S_ABBR1;
	$omitposts = sprintf(S_ABBR2, $posts) if ($posts > 1);

	my $omitfiles = "";
	$omitfiles = S_ABBRIMG1 if ($files == 1);
	$omitfiles = sprintf(S_ABBRIMG2, $files) if ($files > 1);

	return $omitposts . $omitfiles . S_ABBR_END;
}

sub get_abbrev_message($) {
	my ($lines) = @_;
	return S_ABBRTEXT1 if ($lines == 1);
	return sprintf(S_ABBRTEXT2, $lines);
}

sub show_thread {
    my ($thread, $admin) = @_;
    my ( $sth, $row, @thread );
#    my ( $filename, $tmpname );
	
	# if we try to call show_thread with admin parameter
	# the admin password will be checked and this
	# variable will be 1
	my $isAdmin = 0;
	if(defined($admin))
	{
		#check_password($admin, ADMIN_PASS);
		if (check_password_silent($admin, ADMIN_PASS)) { $isAdmin = 1; } else { $admin = ""; }
	}

    $sth = $dbh->prepare(
            "SELECT *, sticky IS NULL OR sticky=0 AS sticky_isnull FROM "
          . SQL_TABLE
          . " WHERE num=? OR parent=? ORDER BY num ASC;" )
      or make_error(S_SQLFAIL);
    $sth->execute( $thread, $thread ) or make_error(S_SQLFAIL);

    while ( $row = get_decoded_hashref($sth) ) {
		$$row{comment} = resolve_reflinks($$row{comment});
        push( @thread, $row );
    }
    make_error(S_NOTHREADERR, 1) if ( !$thread[0] or $thread[0]{parent} );

	add_images_to_thread(@thread);

    make_http_header();
	my $loc = get_geolocation(get_remote_addr());
	my $output = 
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
				locked       => $thread[0]{locked}
            )
        );
	$output =~ s/^\s+\n//mg;
	print($output);
}

sub add_images_to_thread(@) {
	my (@posts) = @_;
	my ($parent, $sthfiles, $res, @files, $uploadname, $post);

	$parent = $posts[0]{num};

	@files = ();
	# get all files of a thread with one query
	$sthfiles = $dbh->prepare(
		"SELECT * FROM " . SQL_TABLE_IMG . " WHERE thread=? OR post=? ORDER BY post ASC, num ASC;")
		or make_error(S_SQLFAIL);
	$sthfiles->execute($parent, $parent) or make_error(S_SQLFAIL);
	while ($res = get_decoded_hashref($sthfiles)) {
		$uploadname = remove_path($$res{uploadname});
		$$res{uploadname} = clean_string($uploadname);
		$$res{displayname} = clean_string(get_displayname($uploadname));

		$$res{thumbnail} = undef if ($$res{thumbnail} =~ m|^\.\./img/|); # temporary, static thumbs are not used anymore

		push(@files, $res);
	}

	return unless @files;

	foreach $post (@posts) {
		while (@files and $$post{num} == $files[0]{post}) {
			push(@{$$post{files}}, shift(@files))
		}
	}
}

sub add_images_to_array($@) {
	my ($postid, $files) = @_;
	my ($sth, $res, $uploadname, $count, $size);
	$count = 0;
	$size = 0;

	$sth = $dbh->prepare("SELECT * FROM " . SQL_TABLE_IMG . " WHERE post=? ORDER BY num ASC;")
		or make_error(S_SQLFAIL);
	$sth->execute($postid);
	while ($res = get_decoded_hashref($sth)) {  # $sth->fetchrow_hashref();
		$count++;
		$size += $$res{size};

		$uploadname = remove_path($$res{uploadname});
		$$res{uploadname} = clean_string($uploadname);
		$$res{displayname} = clean_string(get_displayname($uploadname));

		$$res{thumbnail} = undef if ($$res{thumbnail} =~ m|^\.\./img/|); # temporary, static thumbs are not used anymore

		push(@$files, $res); # @$ dereferences the array to modify it in the calling sub
	}

	return ($count, $size);
}

sub add_images_to_row {
    my ($row) = @_;

	my @files; # this array holds all files of one post for loop-processing in the template
	@files = ();

	($$row{imagecount}, $$row{total_imagesize}) = add_images_to_array($$row{num}, \@files);

	$row->{'files'}=[@files] if @files; # add the hashref with files to the post	
}

sub resolve_reflinks($) {
	my ($comment) = @_;

	$comment =~ s|<!--reflink-->&gt;&gt;([0-9]+)|
		my $res = get_post($1);
		if ($res) { '<span class="backreflink"><a href="'.get_reply_link($$res{num},$$res{parent}).'">&gt;&gt;'.$1.'</a></span>' }
		else { '<span class="backreflink"><del>&gt;&gt;'.$1.'</del></span>'; }
	|ge;

	return $comment;
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
            make_ban( $ip, $dnsbl_error, 1 );
        }
    }
}


sub find_posts($$$$) {
	my ($find, $op_only, $in_subject, $in_filenames, $in_comment) = @_;
	# TODO: add $admin / admin-reflinks?

	#todo: search in filenames
	#todo: remove hide thread button, remove checkboxes in front of postername

	$find = clean_string(decode_string($find, CHARSET));
	$find =~ s/^\s+|\s+$//g; # trim
	$in_comment = 1 unless $find; # make the box checked for the first call.	

	my ($sth, $row);
	my ($search, $subject);
	my $lfind = lc($find); # ignore case
	my $count = 0;
	my $threads = 0;
	my @results = ();

	if (length($lfind) >= 3) {
		# grab all posts, in thread order (ugh, ugly kludge)
		$sth = $dbh->prepare(
			"SELECT * FROM " . SQL_TABLE . " ORDER BY sticky DESC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC"
		) or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);

		while (($row = get_decoded_hashref($sth)) and ($count < MAX_SEARCH_RESULTS) and ($threads <= MAX_SHOWN_THREADS)) {
			$threads++ if !$$row{parent};
			$search = $$row{comment};
			$search =~ s/<.+?>//mg; # must not search inside html-tags. remove them.
			$search = lc($search);
			$subject = lc($$row{subject});

			if (($in_comment and (index($search, $lfind) > -1)) or ($in_subject and (index($subject, $lfind) > -1))) {

# highlight found words - this can break HTML tags
# TODO: select or define CSS style
#$$row{comment} =~ s/($find)/<span style="background-color: #706B5E; color: #FFFFFF; font-weight: bold;">$1<\/span>/ig;

				add_images_to_row($row);
				$$row{comment} = resolve_reflinks($$row{comment});
				if (!$$row{parent}) { # OP post
					$$row{sticky_isnull} = 1; # hack, until this field is removed.
					push @results, $row;
				} else { # reply post
					push @results, $row unless ($op_only);
				}
				$count = @results;
			}
		}
		$sth->finish(); # Clean up the record set
	}

	make_http_header();
	my $output =
		encode_string(
			SEARCH_TEMPLATE->(
				title		=> S_SEARCHTITLE,
				posts		=> \@results,
				find		=> $find,
				oponly		=> $op_only,
				insubject	=> $in_subject,
				filenames	=> $in_filenames,
				comment		=> $in_comment,
				count		=> $count,
				isAdmin		=> 0,
				admin		=> ''
			)
		);

	$output =~ s/^\s+\n//mg;
	print($output);
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
        $parent,  $spam1,   $spam2,      $name,      $email,
        $subject, $comment, $gb2,        $captcha,   $password,
        $admin,   $nofile,  $no_captcha, $no_format, $postfix,
        $postAsAdmin, @files
    ) = @_;

	my $file = $files[0];
	my $uploadname = $files[0];
	my $file1 = $files[1];
	my $file2 = $files[2];
	my $file3 = $files[3];

    my $original_comment = $comment;
    # get a timestamp for future use
    my $time = time();
	my $isAdminPost = 0;

    # check that the request came in as a POST, or from the command line
    make_error(S_UNJUST)
      if ( $ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} ne "POST" );

	# clean up invalid admin cookie/session or posting would fail
	$admin = "" unless ($admin eq crypt_password(ADMIN_PASS));

    if ($admin)  # check admin password
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
            make_error(S_NONEWTHREADS) if (DISABLE_NEW_THREADS);
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
    my $size  = get_file_size($files[0]) if ($files[0]);
    my $size1 = get_file_size($files[1]) if ($files[1]);
    my $size2 = get_file_size($files[2]) if ($files[2]);
    my $size3 = get_file_size($files[3]) if ($files[3]);

    # find IP
    #my $ip  = $ENV{REMOTE_ADDR};
    #my $ip  = substr($ENV{HTTP_X_FORWARDED_FOR}, 6); # :ffff:1.2.3.4
	my $ip = get_remote_addr();	
    my $ssl = $ENV{HTTP_X_ALUHUT};
	$ssl =  $ENV{SSL_CIPHER} unless $ssl;
    undef($ssl) unless $ssl;

    #$host = gethostbyaddr($ip);
	my $numip = dot_to_dec($ip);

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

	# get as number and owner
	my ($as_num, $as_info) = get_as_info($ip);
	$as_info = clean_string($as_info);

    # check for bans
    ban_check($numip, $c_name, $subject, $comment, $as_num) unless $whitelisted;

	# check for spam trap fields
	if ($spam1 or $spam2) {
		my ($banip, $banmask) = parse_range($numip, '');

		$sth = $dbh->prepare(
			"INSERT INTO " . SQL_ADMIN_TABLE . " VALUES(null,?,?,?,?,?,FROM_UNIXTIME(?));")
		  or make_error(S_SQLFAIL);
		$sth->execute('ipban', 'Spam [Auto Ban]', $banip, $banmask, $time + 259200, $time)
		  or make_error(S_SQLFAIL);

		make_error(S_SPAM);
	}

	# get geoip info
	my ($city, $region_name, $country_name, $loc) = get_geolocation($ip);
	$region_name = "" if ($region_name eq $city);
	$region_name = clean_string($region_name);
	$city = clean_string($city);
    # check captcha
    check_captcha( $dbh, $captcha, $ip, $parent, BOARD_IDENT )
      if ( (use_captcha(ENABLE_CAPTCHA, $loc) and !$admin) or (ENABLE_CAPTCHA and !$admin and !$no_captcha and !is_trusted($trip)) );
	$loc = join("<br />", $loc, $country_name, $region_name, $city, $as_info);

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
    my (@filename, @md5, @width, @height, @thumbnail, @tn_width, @tn_height, @info, @info_all);

	($filename[0], $md5[0], $width[0], $height[0], $thumbnail[0], $tn_width[0], $tn_height[0], $info[0], $info_all[0], $file) =
		process_file($files[0], $uploadname, $time) if ($files[0]);

    my $tsf1 = 0;
    my $tsf2 = 0;
    my $tsf3 = 0;
    if ($files[1]) {
        $tsf1 = time() . sprintf( "%03d", int( rand(1000) ) );
		($filename[1], $md5[1], $width[1], $height[1], $thumbnail[1], $tn_width[1], $tn_height[1], $info[1], $info_all[1], $file1) =
			process_file($files[1], $files[1], $tsf1);
    }

    if ($files[2]) {
        $tsf2 = time() . sprintf( "%03d", int( rand(1000) ) );
		($filename[2], $md5[2], $width[2], $height[2], $thumbnail[2], $tn_width[2], $tn_height[2], $info[2], $info_all[2], $file2) =
			process_file($files[2], $files[2], $tsf2);
    }

    if ($files[3]) {
        $tsf3 = time() . sprintf( "%03d", int( rand(1000) ) );
		($filename[3], $md5[3], $width[3], $height[3], $thumbnail[3], $tn_width[3], $tn_height[3], $info[3], $info_all[3], $file3) =
			process_file($files[3], $files[3], $tsf3);
    }

    $numip = "0" if (ANONYMIZE_IP_ADDRESSES);
    # finally, write to the database
    my $sth = $dbh->prepare(
        "INSERT INTO " . SQL_TABLE . "
		VALUES(null,?,?,?,?,?,?,?,?,?,?,null,null,?,null,?,?,?);"
    ) or make_error(S_SQLFAIL);
    $sth->execute(
		$parent,    $time,     $lasthit,      $numip,
		$name,      $trip,     $email,        $subject,
		$password,  $comment,  $isAdminPost,  $$parent_res{sticky},
		$loc,       $ssl
    ) or make_error(S_SQLFAIL);

	# get the new post id
	$sth = $dbh->prepare("SELECT " . get_sql_lastinsertid() . ";") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	my $new_post_id = ($sth->fetchrow_array())[0];

	# insert file information into database
	if ($file) {
		$sth = $dbh->prepare("INSERT INTO " . SQL_TABLE_IMG . " VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?);" )
			or make_error(S_SQLFAIL);

		my $thread_id = $parent;
		$thread_id = $new_post_id if (!$parent);

		$sth->execute(
			$thread_id, $new_post_id, $filename[0], $size, $md5[0], $width[0], $height[0],
			$thumbnail[0], $tn_width[0], $tn_height[0], $file, $info[0], $info_all[0]
		) or make_error(S_SQLFAIL);

		($sth->execute(
			$thread_id, $new_post_id, $filename[1], $size1, $md5[1], $width[1], $height[1],
			$thumbnail[1], $tn_width[1], $tn_height[1], $file1, $info[1], $info_all[1]
		) or make_error(S_SQLFAIL)) if ($files[1]);

		($sth->execute(
			$thread_id, $new_post_id, $filename[2], $size2, $md5[2], $width[2], $height[2],
			$thumbnail[2], $tn_width[2], $tn_height[2], $file2, $info[2], $info_all[2]
		) or make_error(S_SQLFAIL)) if ($files[2]);

		($sth->execute(
			$thread_id, $new_post_id, $filename[3], $size3, $md5[3], $width[3], $height[3],
			$thumbnail[3], $tn_width[3], $tn_height[3], $file3, $info[3], $info_all[3]
		) or make_error(S_SQLFAIL)) if ($files[3]);
	}


    if (ENABLE_IRC_NOTIFY) {
		my $socket = new IO::Socket::INET(
			PeerAddr => IRC_NOTIFY_HOST,
			PeerPort => IRC_NOTIFY_PORT,
			Proto    => "tcp"
		);
		if ($socket) {
			if ( $parent and IRC_NOTIFY_ON_NEW_POST ) {
				print $socket S_IRC_NEW_POST_PREPEND . "/"
				  . encode('utf-8', decode_entities(BOARD_IDENT)) . "/: "
				  . S_IRC_BASE_BOARDURL
				  . encode('utf-8', decode_entities(BOARD_IDENT))
				  . S_IRC_BASE_THREADURL
				  . $parent . "#"
				  . $new_post_id . " ["
				  . get_preview($original_comment) . "]\n";
			}
			elsif ( !$parent and IRC_NOTIFY_ON_NEW_THREAD ) {
				print $socket S_IRC_NEW_THREAD_PREPEND . "/"
				  . encode('utf-8', decode_entities(BOARD_IDENT)) . "/: "
				  . S_IRC_BASE_BOARDURL
				  . encode('utf-8', decode_entities(BOARD_IDENT))
				  . S_IRC_BASE_THREADURL
				  . $new_post_id . " ["
				  . get_preview($original_comment) . "]\n";
			}
			close($socket);
		}
    }

    if (ENABLE_WEBSOCKET_NOTIFY) {
        my $ufoporno = system('/usr/local/bin/push-post', decode_entities(BOARD_IDENT), $parent, $new_post_id, "2>&1", ">/dev/null");
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
        #email     => $c_email,
        gb2       => $c_gb2,
        password  => $c_password,
        -charset  => CHARSET,
        -autopath => COOKIE_PATH,
		-expires  => time + 14 * 24 * 3600
    );    # yum!

	# go back to thread or board page
    make_http_forward("/" . encode('utf-8', BOARD_IDENT) . "/") if ($parent eq '0');
    make_http_forward("thread/" . $parent . "#" . $new_post_id) if ($c_gb2 =~ /thread/i);
    make_http_forward("/" . encode('utf-8', BOARD_IDENT) . "/");
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
    make_http_forward( get_script_name() . "?task=show");

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
    my ($numip, $name, $subject, $comment, $as_num) = @_;
    my ($sth, $row);
    my $ip  = dec_to_dot($numip);

	# check for as num ban
	if ($as_num) {
		$sth =
		  $dbh->prepare( "SELECT count(*) FROM "
			  . SQL_ADMIN_TABLE
			  . " WHERE type='asban' AND sval1 = ?;" )
		  or make_error(S_SQLFAIL);
		$sth->execute($as_num) or make_error(S_SQLFAIL);

		make_ban(0, '', 0, { ip => $ip, showmask => 0, reason => 'AS-Netz-Sperre' }) if (($sth->fetchrow_array())[0]);
	}

	# check if the IP (ival1) belongs to a banned IP range (ival2) using MySQL 5 64 bit BIGINT bitwise logic
	# also checks expired (sval2) and fetches the ban reason(s) (comment)
	my @bans = ();

    $sth =
      $dbh->prepare( "SELECT comment,ival2,sval1 FROM "
		  . SQL_ADMIN_TABLE
		  . " WHERE type='ipban' AND ? & ival2 = ival1 & ival2"
		  . " AND (CAST(sval1 AS UNSIGNED)>? OR sval1='')"
		  . " ORDER BY num;" )
      or make_error(S_SQLFAIL);
    $sth->execute($numip, time()) or make_error(S_SQLFAIL);

    while ($row = get_decoded_hashref($sth)) {
		my ($ban);
		$$ban{ip}       = $ip;
		$$ban{network}  = dec_to_dot($numip & $$row{ival2});
		$$ban{setbits}  = unpack("%32b*", pack( 'N', $$row{ival2}));
		$$ban{showmask} = $$ban{setbits} < 32 ? 1 : 0;
		$$ban{reason}   = $$row{comment};
		$$ban{expires}  = $$row{sval1};
		push @bans, $ban;
    }

	# this will send the ban message(s) to the client
    make_ban(0, '', 0, @bans) if (@bans);

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

    while ( $row = $sth->fetchrow_arrayref() ) { # TODO: use get_decoded_hashref()
        my $regexp = quotemeta $$row[0];

        #		make_error(S_STRREF) if($comment=~/$regexp/);
        if ( $comment =~ /$regexp/ ) {
            $comment = $$row[1]; # this does not work as $comment is a local variable

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



sub format_comment {
    my ($comment) = @_;

    # hide >>1 references from the quoting code
    $comment =~ s/&gt;&gt;([0-9\-]+)/&gtgt;$1/g;

    my $handler = sub    # mark >>1 references
    {
        my $line = shift;

		# ref-links will be resolved on every page creation to support links to deleted (and also future) posts.
		# ref-links are marked with a html-comment and checked/generated on every page output.
		$line =~ s/&gtgt;([0-9]+)/<!--reflink-->&gt;&gt;$1/g;

        return $line;
    };


	if (ENABLE_WAKABAMARK) {
		$comment = do_wakabamark($comment, $handler);
	} elsif (ENABLE_BBCODE) {
		# do_bbcode() will always try to apply (at least some) wakabamark
		$comment = do_bbcode($comment, $handler);
	} else {
		$comment = "<p>" . simple_format($comment, $handler) . "</p>";
	}

    # fix <blockquote> styles for old stylesheets
    $comment =~ s/<blockquote>/<blockquote class="unkfunc">/g;

    # restore >>1 references hidden in code blocks
    $comment =~ s/&gtgt;/&gt;&gt;/g;

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

	# replaced $ENV{REMOTE_ADDR} by get_remote_addr()
    return resolve_host( get_remote_addr() ) if ( DISPLAY_ID =~ /host/i );
    return get_remote_addr() if ( DISPLAY_ID =~ /ip/i );

    my $string = "";
    $string .= "," . int( $time / 86400 ) if ( DISPLAY_ID =~ /day/i );
    $string .= "," . $ENV{SCRIPT_NAME} if ( DISPLAY_ID =~ /board/i );

    return mask_ip( get_remote_addr(), make_key( "mask", SECRET, 32 ) . $string )
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
    my ($size) = 0;
    my ($ext) = $file =~ /\.([^\.]+)$/;
    my %sizehash = FILESIZES;
	#my $errfname = clean_string(decode_string($uploadname, CHARSET));

    $size = stat($file)->size if (defined($file));
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
# remove smiley expressions
	$comment =~ s/\:[A-Za-z]+\:/ /g;
# shorten string
    $preview = substr($comment, 0, 70);
# append ... if too long
	if (length($comment) > 70) {
		$preview .= "...";
	}
    return $preview;
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
	my $errfname = clean_string(decode_string($uploadname, CHARSET));

    make_error(S_BADFORMAT . ' ('.$errfname.')') unless ( ALLOW_UNKNOWN or $known );
    make_error(S_BADFORMAT . ' ('.$errfname.')') if ( grep { $_ eq $ext } FORBIDDEN_EXTENSIONS );
    make_error(S_TOOBIG . ' ('.$errfname.')') if ( MAX_IMAGE_WIDTH  and $width > MAX_IMAGE_WIDTH );
    make_error(S_TOOBIG . ' ('.$errfname.')') if ( MAX_IMAGE_HEIGHT and $height > MAX_IMAGE_HEIGHT );
    make_error(S_TOOBIG . ' ('.$errfname.')')
      if ( MAX_IMAGE_PIXELS and $width * $height > MAX_IMAGE_PIXELS );

	# jpeg -> jpg
	$uploadname =~ s/\.jpeg$/\.jpg/i;

	# make sure $uploadname file extension matches detected extension (for internal formats)
	my ($uploadext) = $uploadname =~ /\.([^\.]+)$/;
	$uploadname .= "." . $ext if (lc($uploadext) ne $ext);

    # generate random filename - fudges the microseconds
    my $filebase  = $time . sprintf( "%03d", int( rand(1000) ) );
    my $filename  = IMG_DIR . $filebase . '.' . $ext;
    my $thumbnail = THUMB_DIR . $filebase;
	if ( $ext eq "png" or $ext eq "svg" )
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
#        if ( $filetypes{$ext} )                 # externally defined filetype
#        {
#            open THUMBNAIL, $filetypes{$ext};
#            binmode THUMBNAIL;
#            ( $tn_ext, $tn_width, $tn_height ) =
#              analyze_image( \*THUMBNAIL, $filetypes{$ext} );
#            close THUMBNAIL;
#
#            # was that icon file really there?
#            if   ( !$tn_width ) { $thumbnail = undef }
#            else                { $thumbnail = $filetypes{$ext} }
#        }
#        else {
            $thumbnail = undef;
#        }
    }
    elsif ($width > MAX_W
        or $height > MAX_H
        or THUMBNAIL_SMALL
        or $filename =~ /\.svg$/ # why not check $ext?
		or $ext eq 'pdf'
		or $ext eq 'webm')
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

		if ($ext eq 'pdf' or $ext eq 'svg') { # cannot determine dimensions for these files
			$width = undef;
			$height = undef;
			$tn_width = MAX_W;
			$tn_height = MAX_H;				
		}

        if (STUPID_THUMBNAILING) {
			$thumbnail = $filename;
			$thumbnail = undef if($ext eq 'pdf' or $ext eq 'svg' or $ext eq 'webm');
		}
        else {
			if ($ext eq 'webm') {
				$thumbnail = undef
				  unless (
					make_video_thumbnail(
						$filename,         $thumbnail,
						$tn_width,         $tn_height,
						VIDEO_CONVERT_COMMAND
					)
				  );
			}
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

			# get the thumbnail size created by external program
			if ($thumbnail and ($ext eq 'pdf' or $ext eq 'svg')) {
				open THUMBNAIL,$thumbnail;
				binmode THUMBNAIL;
				($tn_ext, $tn_width, $tn_height) = analyze_image(\*THUMBNAIL, $thumbnail);
				close THUMBNAIL;
			}
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

	my ($info, $info_all) = get_meta_markup($filename);
    return ($filename, $md5, $width, $height, $thumbnail, $tn_width, $tn_height, $info, $info_all, $uploadname);
}

#
# Deleting
#

sub delete_stuff {
    my ( $password, $fileonly, $admin, $parent, @posts ) = @_;
    my ($post);
    my $deletebyip = 0;
	my $noko = 1; # try to stay in thread after deletion by default	

	# clean up invalid admin cookie/session or deletion would always fail
	$admin = "" unless ($admin eq crypt_password(ADMIN_PASS));

    check_password( $admin, ADMIN_PASS ) if ($admin);

    if ( !$password and !$admin ) { $deletebyip = 1; }

    # no password means delete always
    $password = "" if ($admin);

    make_error(S_BADDELPASS)
      unless ( ( !$password and $deletebyip ) # allow deletion by ip with empty password
        or ( $password and !$deletebyip )
        or $admin );

    foreach $post (@posts) {
        delete_post( $post, $password, $fileonly, $deletebyip, $admin );
		$noko = 0 if ( $parent and $post eq $parent ); # the thread is deleted and cannot be redirected to		
    }

    if ($admin) {
        make_http_forward( get_script_name() . "?task=show");
    } elsif ( $noko == 1 and $parent ) {
		make_http_forward("thread/" . $parent);
	} else { make_http_forward("/" . encode('utf-8', BOARD_IDENT) . "/"); }
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
    make_http_forward( get_script_name() . "?task=show");
}

sub make_sticky {
    my ( $admin, $threadid ) = @_;

    check_password( $admin, ADMIN_PASS );

    my ( $sth, $row );
    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($threadid) or make_error(S_SQLFAIL);

    if ( $row = $sth->fetchrow_hashref() ) {
        my $sticky = $$row{sticky} eq 1 ? undef : 1;
        my $sth2;
        $sth2 =
          $dbh->prepare( "UPDATE " . SQL_TABLE . " SET sticky=? WHERE num=? OR parent=?;" )
          or make_error(S_SQLFAIL);
        $sth2->execute( $sticky, $threadid, $threadid) or make_error(S_SQLFAIL);
    }

    make_http_forward( get_script_name() . "?task=show");
}

sub delete_post {
    my ( $post, $password, $fileonly, $deletebyip, $admin ) = @_;
    my ( $sth, $row, $res, $reply );

	if($admin)
	{
		check_password($admin, ADMIN_PASS);
	}

    my $thumb   = THUMB_DIR;
    my $src     = IMG_DIR;
    my $numip   = dot_to_dec(get_remote_addr()); # do not use $ENV{REMOTE_ADDR}
    $sth = $dbh->prepare( "SELECT * FROM " . SQL_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($post) or make_error(S_SQLFAIL);

    if ( $row = $sth->fetchrow_hashref() ) {
        make_error(S_BADDELPASS)
          if ( $password and $$row{password} ne $password );
        make_error(S_BADDELIP)
          if ( $deletebyip and ( $numip and $$row{ip} ne $numip ) );
		make_error(S_RENZOKU4)
		  if ( $$row{timestamp} + RENZOKU4 >= time() and !$admin );

        unless ($fileonly) {

            # remove files from comment and possible replies
            $sth = $dbh->prepare(
                    "SELECT image,thumbnail FROM " . SQL_TABLE_IMG . " WHERE post=? OR thread=?" )
              or make_error(S_SQLFAIL);
            $sth->execute( $post, $post ) or make_error(S_SQLFAIL);

            while ( $res = $sth->fetchrow_hashref() ) {
				# delete images if they exist
				unlink $$res{image};
				unlink $$res{thumbnail} if ( $$res{thumbnail} =~ /^$thumb/ );
            }

            # remove post and possible replies
            $sth = $dbh->prepare(
                "DELETE FROM " . SQL_TABLE . " WHERE num=? OR parent=?;" )
              or make_error(S_SQLFAIL);
            $sth->execute( $post, $post ) or make_error(S_SQLFAIL);

            $sth = $dbh->prepare(
                "DELETE FROM " . SQL_TABLE_IMG . " WHERE post=? OR thread=?;" )
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
        else    # remove just the image(s) and update the database
        {
            $sth = $dbh->prepare(
                    "SELECT image,thumbnail FROM " . SQL_TABLE_IMG . " WHERE post=?;" )
              or make_error(S_SQLFAIL);
            $sth->execute($post) or make_error(S_SQLFAIL);

            while ( $res = $sth->fetchrow_hashref() ) {
				# delete images if they exist
				unlink $$res{image};
				unlink $$res{thumbnail} if ( $$res{thumbnail} =~ /^$thumb/ );
            }

			$sth = $dbh->prepare( "UPDATE "
				  . SQL_TABLE_IMG
				  . " SET size=0,md5=null,thumbnail=null,info=null,info_all=null WHERE post=?;" )
				or make_error(S_SQLFAIL);
			$sth->execute($post) or make_error(S_SQLFAIL);
        }
    }
}

#
# Admin interface
#

sub make_admin_login {
    make_http_header();
    print encode_string( ADMIN_LOGIN_TEMPLATE->() );
}

sub make_admin_post_panel {
    my ($admin) = @_;

    check_password( $admin, ADMIN_PASS );

	# geoip
	my $api = 'n/a';
	my $path = "/usr/local/share/GeoIP/";
	my @geo_dbs = qw(GeoIP.dat GeoIPv6.dat GeoLiteCity.dat GeoLiteCityv6.dat GeoIPASNum.dat GeoIPASNumv6.dat);
	my @results = ();

	eval 'use Geo::IP';
	unless ($@) {
		eval '$api = Geo::IP->api';

		$api .= ' (IPv6-Lookups erfordern CAPI)' unless ($api eq 'CAPI');

		foreach (@geo_dbs) {
			my ($gi, $geo_db);
			$$geo_db{file} = $_;
			$$geo_db{result} = 'n/a';
			eval '$gi = Geo::IP->open($path . "$_")';
			$$geo_db{result} = $gi->database_info unless ($@ or !$gi);
			push(@results, $geo_db);
		}
	}

	# statistics
	my $sth;
	my $threads = count_threads();
	my ($posts, $size) = count_posts();

    $sth = $dbh->prepare(
		"SELECT count(*) FROM " . SQL_TABLE_IMG . " WHERE image IS NOT NULL AND size>0;"
	) or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);

    my $files = ($sth->fetchrow_array())[0];

    make_http_header();
    print encode_string(
        POST_PANEL_TEMPLATE->(
            admin    => $admin,
            posts    => $posts,
            threads  => $threads,
            files    => $files,
            size     => $size,
            geoip_api      => $api,
            geoip_results  => \@results
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
          . " WHERE type='ipban' OR type='wordban' OR type='whitelist' OR type='trust' OR type='asban' ORDER BY type ASC, num ASC, date ASC;"
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
		check_password( $crypt, ADMIN_PASS );
    }
    elsif ( $admincookie eq crypt_password(ADMIN_PASS) ) {
        $crypt    = $admincookie;
        $nexttask = "show";
    }

    if ($crypt) {
		my $expires = 0;
        if ( $savelogin ) {
			$expires = time + 14 * 24 * 3600;		
        }

		make_cookies(
			wakaadmin => $crypt,
			-charset  => CHARSET,
			-autopath => COOKIE_PATH,
			-expires  => $expires,
			-httponly => 1
            );

        make_http_forward( get_script_name() . "?task=$nexttask");
    }
    else { make_admin_login() }
}

sub do_logout {
    make_cookies( wakaadmin => "", -expires => 1 );
    make_http_forward( get_script_name() . "?task=admin");
}

sub add_admin_entry {
    my ($admin, $type, $comment, $ival1, $ival2, $sval1, $postid, $ajax) = @_;
    my ($sth, $utf8_encoded_json_text, $expires, $authorized);
    my ($time) = time();

    check_password( $admin, ADMIN_PASS ) if (!$ajax);

	# checks password a second time on non-ajax call to make sure $authorized is always correct.
    $authorized = check_password_silent( $admin, ADMIN_PASS );

	if (!$authorized) {
		$utf8_encoded_json_text = encode_json({
			"error_code" => 401,
			"error_msg" => 'Unauthorized'
		});
	} else {
		$comment = clean_string( decode_string( $comment, CHARSET ) );

		if ($type eq 'ipban') {
			if ($sval1 =~ /\d+/) {
				$sval1 += $time;
				$expires = get_date($sval1);
			} else { $sval1 = ""; }
		}

		$sth = $dbh->prepare(
			"INSERT INTO " . SQL_ADMIN_TABLE . " VALUES(null,?,?,?,?,?,FROM_UNIXTIME(?));" )
		  or make_error(S_SQLFAIL);
		$sth->execute( $type, $comment, $ival1, $ival2, $sval1, $time )
		  or make_error(S_SQLFAIL);

		if ($postid) {
			$sth = $dbh->prepare( "UPDATE " . SQL_TABLE . " SET banned=? WHERE num=? LIMIT 1;" )
			  or make_error(S_SQLFAIL);
			$sth->execute($time, $postid) or make_error(S_SQLFAIL);
		}

		$utf8_encoded_json_text = encode_json({
			"error_code" => 200,
			"banned_ip" => dec_to_dot($ival1),
			"banned_mask" => dec_to_dot($ival2),
			"expires" => $expires,
			"reason" => $comment,
			"postid" => $postid
		});
	}

	if ($ajax) {
		make_json_header();
		print $utf8_encoded_json_text;
	} else {
		make_http_forward(get_script_name() . "?task=bans");
	}
}

sub check_admin_entry {
    my ($admin, $ival1) = @_;
    my ($sth, $utf8_encoded_json_text, $results);
    if (!check_password_silent( $admin, ADMIN_PASS )) {
		$utf8_encoded_json_text = encode_json({"error_code" => 401, "error_msg" => 'Unauthorized'});
	} else {
		if (!$ival1) {
			$utf8_encoded_json_text = encode_json({"error_code" => 500, "error_msg" => 'Invalid parameter'});
		} else {
			$sth = $dbh->prepare("SELECT count(*) FROM "
				. SQL_ADMIN_TABLE
				. " WHERE type='ipban' AND ival1=? AND (CAST(sval1 AS UNSIGNED)>? OR sval1='');");
			$sth->execute(dot_to_dec($ival1), time());
			$results = ($sth->fetchrow_array())[0];

			$utf8_encoded_json_text = encode_json({"error_code" => 200, "results" => $results});
		}
	}
    make_json_header();
    print $utf8_encoded_json_text;
}

sub remove_admin_entry {
    my ( $admin, $num ) = @_;
    my ($sth);

    check_password( $admin, ADMIN_PASS );

    $sth = $dbh->prepare( "DELETE FROM " . SQL_ADMIN_TABLE . " WHERE num=?;" )
      or make_error(S_SQLFAIL);
    $sth->execute($num) or make_error(S_SQLFAIL);

    make_http_forward( get_script_name() . "?task=bans");
}

sub delete_all {
    my ($admin, $ip, $mask, $go) = @_;
    my ($sth, $row, @posts);

    check_password( $admin, ADMIN_PASS );

	unless($go and $ip) # do not allow empty IP (as it would delete anonymized (staff) posts)
	{
		my ($pcount, $tcount);

		$sth = $dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip & ? = ? & ?;") or make_error(S_SQLFAIL);
		$sth->execute($mask, $ip, $mask) or make_error(S_SQLFAIL);
		$pcount = ($sth->fetchrow_array())[0];

		$sth = $dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip & ? = ? & ? AND parent=0;") or make_error(S_SQLFAIL);
		$sth->execute($mask, $ip, $mask) or make_error(S_SQLFAIL);
		$tcount = ($sth->fetchrow_array())[0];

		make_http_header();
		print encode_string(DELETE_PANEL_TEMPLATE->(admin=>$admin, ip=>$ip, mask=>$mask, posts=>$pcount, threads=>$tcount));
	}
	else
	{
		$sth =
		  $dbh->prepare( "SELECT num FROM " . SQL_TABLE . " WHERE ip & ? = ? & ?;" )
		  or make_error(S_SQLFAIL);
		$sth->execute( $mask, $ip, $mask ) or make_error(S_SQLFAIL);
		while ( $row = $sth->fetchrow_hashref() ) { push( @posts, $$row{num} ); }

		delete_stuff('', 0, $admin, 0, @posts);
	}
}

sub check_password {
    my ( $admin, $password ) = @_;

    return if ( $admin eq ADMIN_PASS );
    return if ( $admin eq crypt_password($password) );

    make_error(S_WRONGPASS);
}

sub check_password_silent {
    my ( $admin, $password ) = @_;

    return 1 if ( $admin eq ADMIN_PASS );
    return 1 if ( $admin eq crypt_password($password) );

    return 0;
}

sub crypt_password {
    my $crypt = hide_data( (shift) . get_remote_addr(), 18, "admin", SECRET, 1 ); # do not use $ENV{REMOTE_ADDR}
    $crypt =~ tr/+/./;    # for web shit
    return $crypt;
}

#
# Page creation utils
#

sub make_http_header {
	my ($not_found) = @_;
	print $query->header(-type=>'text/html', -status=>'404 Not found', -charset=>CHARSET) if ($not_found);
	print $query->header(-type=>'text/html', -charset=>CHARSET) if (!$not_found);
}

sub make_json_header {
	print "Cache-Control: no-cache, no-store, must-revalidate\n";
	print "Expires: Mon, 12 Apr 2010 05:00:00 GMT\n";
	print "Content-Type: application/json\n";
	print "Access-Control-Allow-Origin: *\n";
	print "\n";
}

sub make_error {
    my ($error, $not_found) = @_;

    make_http_header() if (!defined $not_found);
    make_http_header($not_found) if (defined $not_found);

    print encode_string(
        ERROR_TEMPLATE->(
            error          => $error,
            error_page     => 'Fehler aufgetreten',
            #error_subtitle => 'Fehler aufgetreten',
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
    my ($ip, $reason, $mode, @bans) = @_;

    make_http_header();
    if ( $mode == 1 ) {
        print encode_string(
            ERROR_TEMPLATE->(
                ip             => $ip,
                dnsbl          => $reason,
                error_page     => 'HTTP 403 - Proxy found',
                #error_subtitle => 'HTTP 403 - Proxy found',
                error_title    => 'Proxy found'
            )
        );
    }
    else {
        print encode_string(
            ERROR_TEMPLATE->(
                bans           => \@bans,
                error_page     => 'Banned',
                #error_subtitle => 'GEH ZUR&Uuml;CK NACH KRAUTKANAL!',
                error_title    => 'Banned :&lt;',
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
    #return encode('utf-8', $ENV{SCRIPT_NAME});
    return $ENV{SCRIPT_NAME};
}

sub get_secure_script_name {
    return 'https://' . $ENV{SERVER_NAME} . $ENV{SCRIPT_NAME}
      if (USE_SECURE_ADMIN);
    return $ENV{SCRIPT_NAME};
}

sub expand_image_filename {
    my $filename = shift;

    return expand_filename( clean_path($filename) );

    my ($self_path) = $ENV{SCRIPT_NAME} =~ m!^(.*/)[^/]+$!;
    my $src = IMG_DIR;
    $filename =~ /$src(.*)/;
    return $self_path . REDIR_DIR . clean_path($1) . '.html';
}

sub get_reply_link {
    my ($reply, $parent) = @_;

	return expand_filename( "thread/" . $parent ) . '#' . $reply if ($parent);
   	return expand_filename( "thread/" . $reply );
}

sub get_page_count {
    my ($total) = @_;
    if ( $total > MAX_SHOWN_THREADS ) {
        $total = MAX_SHOWN_THREADS;
    }
    return int( ( $total + IMAGES_PER_PAGE- 1 ) / IMAGES_PER_PAGE );
}

sub get_filetypes_hash {
    my %filetypes = FILETYPES;
    $filetypes{gif} = $filetypes{jpg} = $filetypes{jpeg} = $filetypes{png} = $filetypes{svg} = 'image';
	$filetypes{pdf} = 'doc';
	$filetypes{webm} = 'video';
	return %filetypes;
}

sub get_filetypes {
	my %filetypes = get_filetypes_hash();
    return join ", ", map { uc } sort keys %filetypes;
}

sub get_filetypes_table {
	my %filetypes = get_filetypes_hash();
	my %filegroups = FILEGROUPS;
	my %filesizes = FILESIZES;
	my @groups = GROUPORDER;
	my @rows;
	my $blocks = 0;
	my $output = '<table style="margin:0px;border-collapse:collapse;display:inline-table;">' . "\n<tr>\n\t" . '<td colspan="4">'
		. sprintf(S_ALLOWED, get_displaysize(MAX_KB*1024, DECIMAL_MARK, 0)) . "</td>\n</tr><tr>\n";
	delete $filetypes{'jpeg'}; # show only jpg

	foreach my $group (@groups) {
		my @extensions;
		foreach my $ext (keys %filetypes) {
			if ($filetypes{$ext} eq $group or $group eq 'other') {
				my $ext_desc = uc($ext);
				$ext_desc .= ' (' . get_displaysize($filesizes{$ext}*1024, DECIMAL_MARK, 0) . ')' if ($filesizes{$ext});
				push(@extensions, $ext_desc);
				delete $filetypes{$ext};
			}
		}
		if (@extensions) {
			$output .= "\t<td><strong>" . $filegroups{$group} . ":</strong>&nbsp;</td>\n\t<td>"
				. join(", ", sort(@extensions)) . "&nbsp;&nbsp;&nbsp;</td>\n";
			$blocks++;
			if (!($blocks % 2)) {
				push(@rows, $output);
				$output = '';
				$blocks = 0;
			}
		}
	}
	push(@rows, $output) if ($output);
	return join("</tr><tr>\n", @rows) . "</tr>\n</table>";
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

	if ($ip =~ /:/ or length(pack('w', $ip)) > 5) # IPv6
	{
		# ignore mask because MySQL 5 will only do bit shifting operations up to 64 bit
		$mask = "340282366920938463463374607431768211455";
	}
	else # IPv4
	{
		if ( $mask =~ /^\d+\.\d+\.\d+\.\d+$/ ) { $mask = dot_to_dec($mask); }
		elsif ( $mask =~ /(\d+)/ ) { $mask = ( ~( ( 1 << $1 ) - 1 ) ); }
		else                       { $mask = 0xffffffff; }
	}

    $ip = dot_to_dec($ip) if ( $ip =~ /(^\d+\.\d+\.\d+\.\d+$)|:/ );

    return ( $ip, $mask );
}

sub get_remote_addr {
	my $ip;

	$ip = $ENV{HTTP_X_REAL_IP};
	$ip = $ENV{REMOTE_ADDR} if (!defined($ip));

	return $ip;
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
          "uploadname TEXT," .     # Original filename supplied by the user agent
          "displaysize TEXT" .     # Human readable size with B/K/M

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
          "sval1 TEXT," .       # String value 1
          "date TEXT" .        # Human-readable form of date		  

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

sub get_sql_lastinsertid()
{
	return 'LAST_INSERT_ID()' if(SQL_DBI_SOURCE=~/^DBI:mysql:/i);
	return 'last_insert_rowid()' if(SQL_DBI_SOURCE=~/^DBI:SQLite:/i);
	return 'last_insert_rowid()' if(SQL_DBI_SOURCE=~/^DBI:SQLite2:/i);

	make_error(S_SQLCONF);
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
            delete_post( $$row{num}, "", 0, 0 );
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

            delete_post( $$row{num}, "", 0, 0 );

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
    my ($sth, $where, $count, $size);

    $where = "WHERE parent=$parent or num=$parent" if ($parent);
    $sth = $dbh->prepare(
        "SELECT count(*) FROM " . SQL_TABLE . " $where;" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
	$count = ($sth->fetchrow_array())[0];

    $where = "WHERE thread=$parent" if ($parent);
    $sth = $dbh->prepare(
        "SELECT sum(size) FROM " . SQL_TABLE_IMG . " $where;" )
      or make_error(S_SQLFAIL);
    $sth->execute() or make_error(S_SQLFAIL);
	$size = ($sth->fetchrow_array())[0];

    return ($count, $size);
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

#        if ( SQL_DBI_SOURCE =~ /^DBI:mysql:/i )    # OMGWTFBBQ
#        {
#            for my $k ( keys %$row ) {
#                $$row{$k} =~ s/chr\(([0-9]+)\)/chr($1)/ge if defined;
#            }
#        }
    }

    return $row;
}

sub get_decoded_arrayref {
    my ($sth) = @_;

    my $row = $sth->fetchrow_arrayref();

    if ( $row and $has_encode ) {

        # don't blame me for this shit, I got this from perlunicode.
        defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;

#        if ( SQL_DBI_SOURCE =~ /^DBI:mysql:/i )    # OMGWTFBBQ
#        {
#            s/chr\(([0-9]+)\)/chr($1)/ge for @$row;
#        }
    }

    return $row;

}

sub update_db_schema2 {  # mysql-specific. will be removed after migration is done.
	$sth = $dbh->prepare("SHOW COLUMNS FROM " . SQL_TABLE . " WHERE field = 'location';");
	if ($sth->execute()) {
		if (my $row = $sth->fetchrow_hashref()) {
			if ($$row{Type} eq 'varchar(25)') {
				$sth = $dbh->prepare(
					"ALTER TABLE " . SQL_TABLE . " CHANGE location location TEXT;"
				) or make_error($dbh->errstr);
				$sth->execute() or make_error($dbh->errstr);
			} else {
				$sth->finish;
			}
		}
	}
}

sub update_db_schema {  # mysql-specific. will be removed after migration is done.

# try to select a field that only exists if migration was already done
# exit if no error occurs
	my $done = 0;

    $sth = $dbh->prepare("SELECT banned FROM " . SQL_TABLE . " LIMIT 1;");
	if ($sth->execute()) {
		$sth->finish;
		$done = 1;
	}

	return if ($done);

# remove primary key constraint from image table, remove unneeded column, add new columns
   $sth = $dbh->prepare(
		"ALTER TABLE " . SQL_TABLE_IMG . " DROP PRIMARY KEY, DROP displaysize,
		ADD thread INT NULL AFTER timestamp, ADD post INT NULL AFTER thread,
		ADD info TEXT NULL, ADD info_all TEXT NULL, ADD temp_sort INT NULL;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

# link images 1-3 to posts and threads
   $sth = $dbh->prepare(
		"UPDATE " . SQL_TABLE_IMG . " JOIN " . SQL_TABLE . " ON imageid_1=" . SQL_TABLE_IMG . ".timestamp
		SET thread=parent, post=num, temp_sort=1;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

   $sth = $dbh->prepare(
		"UPDATE " . SQL_TABLE_IMG . " JOIN " . SQL_TABLE . " ON imageid_2=" . SQL_TABLE_IMG . ".timestamp
		SET thread=parent, post=num, temp_sort=2;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

   $sth = $dbh->prepare(
		"UPDATE " . SQL_TABLE_IMG . " JOIN " . SQL_TABLE . " ON imageid_3=" . SQL_TABLE_IMG . ".timestamp
		SET thread=parent, post=num, temp_sort=3;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

# copy image 0 from comment table to image table
   $sth = $dbh->prepare(
		"INSERT " . SQL_TABLE_IMG . " (timestamp, thread, post, image, size, md5, width, height,
		thumbnail, tn_width, tn_height, uploadname, temp_sort)
		SELECT 1, parent, num, image, size, md5, width, height, thumbnail, tn_width, tn_height, uploadname, 0
		FROM " . SQL_TABLE . " WHERE image IS NOT NULL;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

# replace thread=0 with post-id for OP images
   $sth = $dbh->prepare(
		"UPDATE " . SQL_TABLE_IMG . " SET thread=post WHERE thread=0;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

# add new primary key to image table, order records to make sure images stay in the right order, remove unneeded columns
   $sth = $dbh->prepare(
		"ALTER TABLE " . SQL_TABLE_IMG . " ADD num INT PRIMARY KEY AUTO_INCREMENT FIRST,
		DROP timestamp, DROP temp_sort, ORDER BY temp_sort ASC;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);

# remove unneeded columns from comments table, rename column, add banned column
   $sth = $dbh->prepare(
		"ALTER TABLE " . SQL_TABLE . " DROP image, DROP size, DROP md5, DROP width, DROP height, DROP thumbnail,
		DROP tn_width, DROP tn_height, DROP uploadname, DROP displaysize, DROP imageid_1, DROP imageid_2, DROP imageid_3,
		CHANGE `ssl` secure TEXT, ADD banned INT AFTER comment;"
   ) or make_error($dbh->errstr);
   $sth->execute() or make_error($dbh->errstr);
}

sub update_files_meta {
	my ($row, $sth2, $info, $info_all);

    return unless ($sth = $dbh->prepare("SELECT 1 FROM " . SQL_TABLE_IMG . " WHERE info_all IS NOT NULL LIMIT 1;"));
	return unless ($sth->execute()); # exit if schema was not yet updated
	return if (($sth->fetchrow_array())[0]); # at least one info_all field was filled. update already done, exit.

    $sth = $dbh->prepare(
		"SELECT num, image FROM " . SQL_TABLE_IMG . " WHERE image IS NOT NULL AND size>0 AND info_all IS NULL;"
	) or make_error($dbh->errstr);
    $sth->execute() or make_error($dbh->errstr);

	$sth2 = $dbh->prepare(
		"UPDATE " . SQL_TABLE_IMG . " SET info=?, info_all=? WHERE num=?;"
	) or make_error($dbh->errstr);
    while ($row = get_decoded_hashref($sth)) {
		if (-e $$row{image}) {
			($info, $info_all) = get_meta_markup($$row{image});
		} else {
			$info = undef;
			$info_all = "File not found";
		}
		$sth2->execute($info, $info_all, $$row{num}) or make_error($dbh->errstr);
	}
}
