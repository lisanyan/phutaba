#!/usr/bin/perl -X

package Wakaba;

use strict;
# umask 0022;    # Fix some problems

use lib '.';
use CGI::Carp qw(fatalsToBrowser set_message);
use CGI::Fast;
use DBI;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use File::Copy;
use FCGI::ProcManager qw(pm_manage pm_pre_dispatch 
                         pm_post_dispatch);
use JSON::XS;
use List::Util qw(first);
use Net::DNS; # DNSBL request
use Net::IP qw(:PROC);
use SimpleCtemplate;
use Pomf qw(pomf_upload);

$CGI::LIST_CONTEXT_WARN = 0; # UFOPORNO
my $JSON = JSON::XS->new->pretty->utf8;

use constant HANDLER_ERROR_PAGE_HEAD => q{
<!DOCTYPE html>
<html lang="en"> 
<head>
<title>02ch &raquo; Server Error</title>
<meta charset="utf-8" />
<link rel="shortcut icon" href="/img/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/static/css/phutaba.css" />
</head>
<body>
<div class="content">
<header>
    <div class="header">
        <div class="banner"><a href="/"><img src="/banner.pl" alt="02ch" /></a></div>
        <div class="boardname">Server Error</div>
    </div>
</header>
    <hr />

<div class="container" style="background-color: rgba(170, 0, 0, 0.2);margin-top: 50px;"> 
<p>

};

use constant HANDLER_ERROR_PAGE_FOOTER => q{

</p>
</div> 
<p style="text-align: center;margin-top: 50px;">
<span style="font-size: small; font-style: italic;">This is a <strong>fatal error</strong> in the <em>request/response handler</em>. Please contact the administrator of this site via <a href="mailto:admin@02ch.in">email</a> and ask him to fix this error
</span></p>

    <hr />
    <footer>Powered by <img src="/img/phutaba_icon.png" alt="" /> <strong>Phutaba</strong>.</footer>
</div>
</body>
</html>
};

# Error Handling
BEGIN {
    sub handler_errors {
        my ($msg) = @_;
        $msg =~ s/\n/\n<br \/>/g;
        print HANDLER_ERROR_PAGE_HEAD;
        print $msg;
        print HANDLER_ERROR_PAGE_FOOTER;
    }
    set_message( \&handler_errors );
}

#
# Import settings
#
BEGIN {
  require "lib/site_config.pl";
  require "lib/config_defaults.pl";
  require "lib/wakautils.pl";
  require "captcha.pl";
}

#
# Optional modules
#
my ($has_encode);
eval 'use Encode qw(decode encode)';
$has_encode = 1 unless $@;

#
# Global init
#
my $protocol_re = qr/(?:http|https|ftp|mailto|nntp|irc|xmpp|skype)/;
my $pomf_domain = "a.pomf.cat";

my ($dbh, $query, $boardSection, $moders);

my $cfg = my $locale = {};
my $fcgi_counter = 0;
my $max_fcgi_loops = 250;
my $tpl = SimpleCtemplate->new({ tmpl_dir => 'tpl/board/' });

return 1 if (caller); # stop here if we're being called externally

pm_manage(n_processes => 4, die_timeout => 10, pm_title => 'perl-fcgi-pm-02ch');

# FCGI init
while($query=CGI::Fast->new)
{
    pm_pre_dispatch();
    $fcgi_counter++;

    unless (0)
    {
        $boardSection   = ($query->param("section") or &DEFAULT_BOARD);
        $cfg            = fetch_config(decode_string($boardSection, CHARSET));
        $moders         = get_settings('mods');
        $locale         = get_settings($$cfg{BOARD_LOCALE})
                            unless ($$cfg{NOTFOUND});

        if( $$cfg{NOTFOUND} ) {
            print ("Content-type: text/plain\n\nBoard not found.");
            next;
        }
        elsif( !($$cfg{BOARD_ENABLED}) ) {
            print ("Content-type: text/plain\n\nThis board has been disabled by administrator.");
            next;
        }
    }

    $dbh = DBI->connect_cached(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,
        {AutoCommit => 1} ) or make_error($$locale{S_SQLCONF});

    my $sth = $dbh->prepare("SET NAMES 'utf8'") or make_error("SPODRO BORDO");
    $sth->execute();
    $sth->finish;

    my $task  = ( $query->param("task") or $query->param("action"));
    my $json  = ( $query->param("json") or "" );

    # check for admin table
    init_admin_database() if ( !table_exists($$cfg{SQL_ADMIN_TABLE}) );

    # check for log table
    init_log_database() if ( !table_exists($$cfg{SQL_LOG_TABLE}) );

    # check for backup tables
    init_backup_database() if ( !table_exists($$cfg{SQL_BACKUP_TABLE}) );
    init_backup_files_database() if ( !table_exists($$cfg{SQL_BACKUP_IMG_TABLE}) );

    # cleanup backups table
    cleanup_backups_database();
    # cleanup logs table
    cleanup_log_database();

    if ( $json eq "post" ) {
        my $id = $query->param("id");
        if ( defined $id and $id =~ /^[+-]?\d+$/ ) {
            output_json_post($id);
        }
    }
    if ( $json eq "newposts" ) {
        my $id = $query->param("id");
        my $after = $query->param("after");
        if ( defined $id && defined $after and
             $after =~ /^[+-]?\d+$/ && $id =~ /^[+-]?\d+$/ ) {
            output_json_newposts($after, $id);
        }
    }
    elsif ( $json eq "threads" ) {
        my $page=$query->param("page");
        $page=1 unless($page and $page =~ /^[+-]?\d+$/);
        output_json_threads($page);
    }
    elsif ($json eq "thread") {
        my $id = $query->param("id");
        if (defined $id and $id =~ /^[+-]?\d+$/) {
            output_json_thread($id);
        }
    }
    elsif ( $json eq "stats" ) {
        my $date_format = $query->param("date_format");
        if ( defined $date_format ) {
            output_json_stats($date_format);
        }
    }
    elsif ($json) {
        make_json_header();
        print $JSON->encode({
            code => 500,
            error => 'Unknown json parameter.'
        });
    }

    if ( !table_exists($$cfg{SQL_TABLE}) ) {   # check for comments table
        init_database();
        init_files_database() unless table_exists($$cfg{SQL_TABLE_IMG});
        # if nothing exists show the first page.
        show_page(1);
    }
    elsif ( !$task and !$json ) {
        my $admin  = $query->cookie("wakaadmin");
        my $c_name = $query->cookie("name");
        # when there is no task, show the first page.
        show_page(1, $admin, $c_name);
    }
    elsif ( $task eq "show" ) {
        my $page   = $query->param("page");
        my $thread = $query->param("thread");
        my $post   = $query->param("post");
        my $after  = $query->param("after");
        my $admin  = $query->cookie("wakaadmin");
        my $c_name = $query->cookie("name");

        # outputs a single post only
        if (defined($post) and $post =~ /^[+-]?\d+$/)
        {
            show_post($post, $admin);
        }
        elsif (defined($after) && $thread =~ /^[+-]?\d+$/ and $after =~ /^[+-]?\d+$/)
        {
            show_newposts($after, $thread, $admin);
        }
        # show the requested thread
        elsif (defined($thread) and $thread =~ /^[+-]?\d+$/)
        {
            if($thread ne 0) {
                show_thread($thread, $admin, $c_name);
            } else {
                make_error($$locale{S_STOP_FOOLING});
            }
        }
        # show the requested page (if any)
        else
        {
            # fallback to page 1 if parameter was empty or incorrect
            $page = 1 unless (defined($page) and $page =~ /^[+-]?\d+$/);
            show_page($page, $admin, $c_name);
        }
    }
    elsif ( $task eq "search" ) {
        my $find            = $query->param("find");
        my $op_only         = $query->param("op");
        my $in_subject      = $query->param("subject");
        my $in_filenames    = $query->param("files");
        my $in_comment      = $query->param("comment");

        find_posts($find, $op_only, $in_subject, $in_filenames, $in_comment);
    }
    elsif ( $task eq "post" ) {
        my $parent     = $query->param("parent");
        my $spam1      = $query->param("name");
        my $spam2      = $query->param("link");
        my $gb2        = $query->param("gb2");
        my $name       = $query->param("nya1"); # obfuscation LOL
        my $email      = $query->param("nya2");
        my $subject    = $query->param("nya3");
        my $comment    = $query->param("nya4");
        my $password   = $query->param("password");
        my $nofile     = $query->param("nofile");
        my $captcha    = $query->param("captcha");
        my $admin      = $query->cookie("wakaadmin");
        my $no_format  = $query->param("no_format");
        my $postfix    = $query->param("postfix");
        my $as_staff   = $query->param("as_staff");
        my $no_pomf    = $query->param("no_pomf");
        my $sticky     = $query->param("sticky");
        my $locked     = $query->param("lock");
        my $autosage   = $query->param("autosage");
        my @files      = $query->param("file"); # multiple uploads

        post_stuff(
            $parent,  $spam1,     $spam2,     $name,     $email,  $gb2,
            $subject, $comment,   $password,  $nofile,   $captcha,
            $admin,   $no_format, $postfix,   $as_staff, $no_pomf,
            $sticky,  $locked,    $autosage,
            @files
        );
    }
    elsif ( $task eq "delete" ) {
        my $password = $query->param("password");
        my $fileonly = $query->param("fileonly");
        my $admin    = $query->cookie("wakaadmin");
        my $parent   = $query->param("parent");
        my $admindel = $query->param("admindel");
        my @posts    = $query->param("delete");

        delete_stuff( $password, $fileonly, $admin, $admindel, $parent, @posts );
    }
    elsif ( $task eq "sticky" ) {
        my $admin    = $query->cookie("wakaadmin");
        my $threadid = $query->param("thread");
        thread_control( $admin, $threadid, "sticky" );
    }
    elsif ( $task eq "kontra" ) {
        my $admin    = $query->cookie("wakaadmin");
        my $threadid = $query->param("thread");
        thread_control( $admin, $threadid, "autosage" );

    }
    elsif ( $task eq "lock" ) {
        my $admin    = $query->cookie("wakaadmin");
        my $threadid = $query->param("thread");
        thread_control( $admin, $threadid, "locked" );
    }
    elsif( $task eq "loginpanel" ) {
        my $admincookie = $query->cookie("wakaadmin");
        my $savelogin = $query->param("savelogin");

        unless ($admincookie) { make_admin_login(); } # Direct to login panel unless already logged in via cookie.
        else { do_login('','',$savelogin,$admincookie); }
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
        # my $page  = $query->param("page");
        # if ( !defined($page) ) { $page = 1; }
        make_admin_post_panel($admin);
    }
    elsif ( $task eq "deleteall" ) {
        my $admin = $query->cookie("wakaadmin");
        my $ip    = $query->param("ip");
        my $mask  = $query->param("mask");
        my $go    = $query->param("go");
        delete_all( $admin, parse_range( $ip, $mask ), $go );
    }
    elsif ( $task eq "bans" ) {
        my $admin = $query->cookie("wakaadmin");
        my $filter = $query->param("filter");
        make_admin_ban_panel($admin, $filter);
    }
    elsif ( $task eq "addip" ) {
        my $admin   = $query->cookie("wakaadmin");
        my $type    = $query->param("type");
        my $comment = $query->param("comment");
        my $ip      = $query->param("ip");
        my $mask    = $query->param("mask");
        my $postid  = $query->param("postid");
        my $blame   = $query->param("blame");
        my $expires = $query->param("expires");
        my $ajax    = $query->param("ajax");
        add_admin_entry( $admin, $type, $comment, parse_range( $ip, $mask ),
            '', $postid, $expires, $blame, $ajax );
    }
    elsif ( $task eq "addstring" ) {
        my $admin   = $query->cookie("wakaadmin");
        my $type    = $query->param("type");
        my $string  = $query->param("string");
        my $comment = $query->param("comment");
        my $expires = $query->param("expires");
        add_admin_entry( $admin, $type, $comment, 0, 0, $string, $expires, 0, 0, 0 );
    }
    elsif ( $task eq "checkban" ) {
        my $ival1   = $query->param("ip");
        my $admin   = $query->cookie("wakaadmin");
        check_admin_entry($admin, $ival1);
    }
    elsif ( $task eq "removeban" ) {
        my $admin = $query->cookie("wakaadmin");
        my $num   = $query->param("num");
        remove_admin_entry( $admin, $num );
    }
    elsif ( $task eq "orphans" ) {
        my $admin = $query->cookie("wakaadmin");
        make_admin_orphans($admin);
    }
    elsif ( $task eq "movefiles" ) {
        my $admin = $query->cookie("wakaadmin");
        my @files = $query->param("file");
        move_files($admin, @files);
    }
    # post editing
    elsif( $task eq "edit" ) {
        my $admin = $query->cookie("wakaadmin");
        my $post = $query->param("num");
        my $noformat = $query->param("noformat");
        make_edit_post_panel( $admin, $post, $noformat );
    }
    elsif( $task eq "doedit" ) {
        my $admin = $query->cookie("wakaadmin");
        my $num = $query->param("num");
        my $name = $query->param("field1");
        my $email = $query->param("field2");
        my $subject = $query->param("field3");
        my $comment = $query->param("field4");
        my $no_format = $query->param("noformat");
        my $capcode = $query->param("capcode");
        my $killtrip = $query->param("notrip");
        my $by_admin = $query->param("admin_post");
        edit_post( $admin, $num, $name, $email, $subject, $comment, $capcode, $killtrip, $by_admin, $no_format);
    }
    # ban editing
    elsif( $task eq "baneditwindow" ) {
        my $admin = $query->cookie("wakaadmin");
        my $num = $query->param("num");
        make_admin_ban_edit($admin, $num);  
    }
    elsif( $task eq "adminedit" ) {
        my $admin = $query -> cookie("wakaadmin");
        my $num = $query->param("num");
        my $comment = $query->param("comment");
        my $sec = $query->param("sec"); # Expiration Info
        my $min = $query->param("min");
        my $hour = $query->param("hour");
        my $day = $query->param("day");
        my $month = $query->param("month");
        my $year = $query->param("year");
        my $noexpire = $query->param("noexpire");
        edit_admin_entry($admin,$num,$comment,$sec,$min,$hour,$day,$month,$year,$noexpire);
    }
    elsif( $task eq "rss" ) {
        make_rss();
    }
    elsif( $task eq "viewlog" ) {
        my $admin=$query->cookie("wakaadmin");
        my $page=$query->param("page");
        # my $filter=$query->param("filter");
        $page = 1 unless (defined($page) and $page =~ /^[+-]?\d+$/);
        make_view_log_panel($admin, $page);
    }
    elsif( $task eq "clearlog" ) {
        my $admin=$query->cookie("wakaadmin");
        my $all=$query->param("clearall");
        clear_log($admin,$all);
    }
    # Post Backups (Staff Only)
    elsif ($task eq "postbackups")
    {   
        my $admin = $query->cookie("wakaadmin");
        my $page = $query->param("page");
        my $perpage = $query->param("perpage");

        make_backup_posts_panel($admin, $page, $perpage);
    }
    elsif ($task eq "restorebackups")
    {
        my $admin = $query->cookie("wakaadmin");
        my @num = $query->param("num");
        my $board_name = $query->param("board") || $$cfg{SELFPATH};
        my $handle = lc $query->param("handle");

        if ($handle eq "restore"
            or decode_string($handle, CHARSET) eq $$locale{S_MPRESTORE})
        {
            restore_stuff($admin, $board_name, @num);
        }
        else
        {
            remove_post_from_backup($admin, $board_name, @num);
        }
    }
    # return error on unknown task
    else {
        make_error("Invalid task") if (!$json);
    }

    if ($fcgi_counter > $max_fcgi_loops)
    {
        $fcgi_counter = 0;
        exit(0); # Hoping this will help with memory leaks. fork() may be preferable
    }

    # $dbh->disconnect();
    pm_post_dispatch();
}

#
# JSON stuff
#

sub hide_row_els {
    my ($row) = @_;
    my ($items, $loc) = get_geo_array($$cfg{SELFPATH}, $$row{location}, 0);
    $$row{'location'} = (@$loc ? join(', ', @$loc) : $$items[0])
      if $$cfg{SHOW_COUNTRIES};
    $$row{'admin_post'} = $$row{'ip'} = $$row{'password'} = undef;
    $$row{'location'} = $$cfg{SHOW_COUNTRIES} ? $$row{'location'} : undef;
}

sub output_json_threads {
    my ($pageToShow) = @_;
    my $page = $pageToShow <= 0 ? 1 : $pageToShow;
    my ( $sth, $row, @threads );
    my ( $code, $error );
    my @session;

    my $threadcount;
    my $offset = ceil($page*$$cfg{IMAGES_PER_PAGE}-$$cfg{IMAGES_PER_PAGE});
    my $totalThreadCount = count_threads();
    my $total = get_page_count($totalThreadCount);

    if ( $page > $total ) {
        $error = $$locale{S_INVALID_PAGE};
    }

    $sth = $dbh->prepare(
            "SELECT * FROM "
          . $$cfg{SQL_TABLE}
          . " WHERE parent IS NULL or parent=0 ORDER BY sticky DESC,lasthit DESC LIMIT ?,?"
    );
    $sth->execute($offset,$$cfg{IMAGES_PER_PAGE});

    my @thread;
    my $posts = $dbh->prepare("SELECT * FROM ".$$cfg{SQL_TABLE}." WHERE parent=? ORDER BY num DESC LIMIT ?;");

    while ($row = get_decoded_hashref($sth)
            and $threadcount <= ( $$cfg{IMAGES_PER_PAGE} * ( $page ) ) )
    {
        add_images_to_row($row);
        hide_row_els($row);
        $posts->execute($$row{num}, count_maxreplies($row));
        @thread=($row);
        my @replies;
        while( my $post=get_decoded_hashref( $posts ) ) {
            hide_row_els( $post );
            add_images_to_row( $post );
            push( @replies, $post ) if(defined $post);
        }
        push @thread, rev(@replies);
        push @threads, { posts => [@thread] };
        $threadcount++;
    }

    # do abbrevations and such
    foreach my $thread (@threads) {

        # split off the parent post, and count the replies and images
        my ( $parent, @replies ) = @{ $$thread{posts} };
        my ($replies, $size, $images) = count_posts($$parent{num});

        # count files in replies - TODO: check for size == 0 for ignoring deleted files

        my $curr_images = 0;
        my $curr_replies = @replies;
        do { $curr_images +=  @{$$_{files}} if (exists $$_{files}) } for (@replies);

        # write the shortened list of replies back
        $$thread{posts}      = [ $parent, @replies ];
        $$thread{num}        = ${$$thread{posts}}[0]{num};
        $$thread{omit}       = ($replies-1)-$curr_replies;
        $$thread{omitimages} = ($images-1)-$curr_images;

        # abbreviate the remaining posts
        foreach ( @{ $$thread{posts} } ) {
            # create ref-links
            $$_{comment} = resolve_reflinks($$_{comment});

            my $abbreviation =
              abbreviate_html( $$_{comment}, $$cfg{MAX_LINES_SHOWN},
                $$cfg{APPROX_LINE_LENGTH} );
             if ($abbreviation) {
                $$_{abbrev} = get_abbrev_message(count_lines($$_{comment}) - count_lines($abbreviation));
                $$_{comment_full} = $$_{comment};
                $$_{comment} = $abbreviation;
            }
        }
    }

    if(@threads) {
        $code = 200;
    } elsif($sth->rows == 0) {
        $code = 404;
        $error = 'Element not found.';
    } else {
        $code = 500;
    }

    # make the list of pages
    my @pages = map +{ page => $_ }, ( 1 .. $total );
    foreach my $p (@pages) {
        $$p{filename} = expand_filename( "api/threads?page=" . $$p{page} );
        if ( $$p{page} == $page ) { $$p{current} = 1 }   # current page, no link
    }

    my %boardinfo = (
        "board" => $$cfg{SELFPATH},
        "board_name" => $$cfg{BOARD_NAME},
        "board_desc" => $$cfg{BOARD_DESC}
    );

    my %status = (
        "error_code" => $code,
        "error_msg" => $error
    );

    my %json = (
        "boardinfo" => \%boardinfo,
        "pages" => \@pages,
        "status" => \%status,
        "data" => \@threads
    );

    # my $loc = get_geolocation(get_remote_addr());

    make_json_header();
    print $JSON->encode(\%json);
}

sub output_json_thread {
    my ($id) = @_;
    my ($sth, $row, $error, $code, %status, @data, %boardinfo, %json);
    $sth = $dbh->prepare("SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=? OR parent=? ORDER BY num ASC;");
    $sth->execute($id, $id);
    $error = decode(CHARSET, $sth->errstr);

    while ( $row=get_decoded_hashref($sth) ) {
        hide_row_els($row);
        $$row{comment} = resolve_reflinks($$row{comment});
        push(@data, $row);
    }
    add_images_to_thread(@data) if($data[0]);

    if(@data ne 0) {
        $code = 200;   
    } elsif($sth->rows == 0) {
        $code = 404;
        $error = 'Element not found.';
    } else {
        $code = 500;
    }
    $sth->finish;

    %boardinfo = (
        "board" => $$cfg{SELFPATH},
        "board_name" => $$cfg{BOARD_NAME},
        "board_desc" => $$cfg{BOARD_DESC},
    );

    %status = (
        "error_code" => $code,
        "error_msg" => $error,
    );

    %json = (
        "boardinfo" => \%boardinfo,
        "data" => \@data,
        "status" => \%status
    );

    make_json_header();
    print $JSON->encode(\%json);
}

sub output_json_post {
    my ($id) = @_;
    my ($sth, $row, $error, $code, %status, %data, %json);

    $sth = $dbh->prepare("SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=?;");
    $sth->execute($id);
    $error = $sth->errstr;
    $row = get_decoded_hashref($sth);
    if(defined $row) {
        $code = 200;
        add_images_to_row($row);
        hide_row_els($row);
        $$row{comment} = resolve_reflinks($$row{comment});
        $data{'post'} = $row;
    } elsif($sth->rows == 0) {
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
    $sth->finish;

    make_json_header();
    print $JSON->encode(\%json);
}

sub output_json_newposts {
    my ($after, $id) = @_;
    my ($sth, $row, $error, $code, %status, @data, %json);

    $sth = $dbh->prepare("SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE parent=? and num>? ORDER BY num ASC;");
    $sth->execute($id,$after);
    $error = $sth->errstr;
    if($sth->rows) {
        $code = 200;
        while($row=get_decoded_hashref($sth)) {
            add_images_to_row($row);
            hide_row_els($row);
            $$row{comment} = resolve_reflinks($$row{comment});
            push(@data, $row);
        }
    } elsif($sth->rows == 0) {
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
    $sth->finish;

    make_json_header();
    print $JSON->encode(\%json);
}

sub output_json_stats {
    my ($date_format) = @_;
    my (@data, $sth, $error, $code, %status, %data, %json);
    
    $sth = $dbh->prepare(
        "SELECT DATE_FORMAT(FROM_UNIXTIME(`timestamp`), ?) AS `datum`, COUNT(`num`) AS `posts` FROM "
        . $$cfg{SQL_TABLE} . " GROUP BY `datum`;");

    $sth->execute(clean_string(decode_string($date_format, CHARSET)));
    $error = $sth->errstr;
    @data = $sth->fetchall_arrayref;
    if(defined \@data) {
        $code = 200;
        $data{'stats'} = \@data;
    } elsif($sth->rows == 0) {
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
    $sth->finish;

    make_json_header();
    print $JSON->encode(\%json);
}

#
# Page rendering stuff
#

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
        if (check_password($admin,'','silent')) { $isAdmin = 1; }
    }

    $sth = $dbh->prepare(
            "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=?;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute( $id ) or make_error($$locale{S_SQLFAIL});
    $row = get_decoded_hashref($sth);

    if ($row) {
        make_http_header();
        add_images_to_row($row);
        $$row{comment} = resolve_reflinks($$row{comment});
        push(@thread, $row);
        my $output =
            $tpl->single_post({
                thread       => $id,
                posts        => \@thread,
                single       => 1,
                admin        => $isAdmin,
                locked       => $thread[0]{locked},
                stylesheets  => get_stylesheets(),
                cfg          => $cfg,
                locale       => $locale
            });
        $output =~ s/^\s+//; # remove whitespace at the beginning
        $output =~ s/^\s+\n//mg; # remove empty lines
        print($output);
    }
    else {
        make_json_header();
        print encode_json( { "error_code" => 400 } );
    }
    $sth->finish;
}

sub show_newposts {
    my ($after, $thread, $admin) = @_;
    my ($sth, $row, @thread);
    my $isAdmin = 0;
    if(defined($admin))
    {
        if (check_password($admin,'','silent')) { $isAdmin = 1; }
    }

    $sth = $dbh->prepare(
            "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE parent=? and num>? ORDER BY num ASC;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute( $thread, $after ) or make_error($$locale{S_SQLFAIL});

    if ($sth->rows) {
        make_http_header();
        while($row = get_decoded_hashref($sth))
        {
            add_images_to_row($row);
            $$row{comment} = resolve_reflinks($$row{comment});
            push(@thread, $row);
        }
        my $output =
            $tpl->single_post({
                thread       => $thread,
                posts        => \@thread,
                single       => 2,
                admin        => $isAdmin,
                locked       => $thread[0]{locked},
                stylesheets  => get_stylesheets(),
                cfg          => $cfg,
                locale       => $locale
            });
        $output =~ s/^\s+//; # remove whitespace at the beginning
        $output =~ s/^\s+\n//mg; # remove empty lines
        print($output);
    }
    else {
        make_json_header();
        print encode_json( { "error_code" => 400 } );
    }
    $sth->finish;
}

sub show_page {
    my ($pageToShow, $admin, $name) = @_;
    my ( $sth, $row, @threads, @thread, @session );
    my $page = $pageToShow <= 0 ? 1 : $pageToShow;

    # if we try to call show_page with admin parameter
    # the admin password will be checked and this
    # variable will be 1
    my $isAdmin = 0;
    if(defined($admin))
    {
        @session = check_password($admin, '', 'silent');
        if ($session[0]) { $isAdmin = 1; }
    }

    my $threadcount;
    my $totalThreadCount = count_threads();
    my $total = get_page_count($totalThreadCount);

    $sth = $dbh->prepare(
            "SELECT * FROM "
          . $$cfg{SQL_TABLE}
          . " WHERE parent=0 ORDER BY sticky DESC,lasthit DESC LIMIT ?,?"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute( ceil( $page * $$cfg{IMAGES_PER_PAGE} - $$cfg{IMAGES_PER_PAGE} ), $$cfg{IMAGES_PER_PAGE} )
      or make_error($$locale{S_SQLFAIL});

    $total = 1 if ($sth and !$sth->rows and !$total);

    my $posts =
      $dbh->prepare(
        "SELECT * FROM ".$$cfg{SQL_TABLE}." WHERE parent=? ORDER BY num DESC LIMIT ?;"
    ) or make_error($$locale{S_SQLFAIL});

    while ( $row = get_decoded_hashref($sth) )
    {
        $posts->execute($$row{num}, count_maxreplies($row));
        add_images_to_row($row);
        @thread = ($row);

        my @replies;
        while( my $post=get_decoded_hashref($posts) ) {
            add_images_to_row($post);
            push(@replies, $post) if defined($post);
        }
        push @thread, rev(@replies);
        push @threads, {posts=>[@thread]};
        $threadcount++;
    }

    # do abbrevations and such
    foreach my $thread (@threads) {

        # split off the parent post, and count the replies and images
        my ( $parent, @replies ) = @{ $$thread{posts} };
        my ($replies, $size, $images) = count_posts($$parent{num});

        # count files in replies - TODO: check for size == 0 for ignoring deleted files
        my $curr_images = 0;
        my $curr_replies = @replies;
        do { $curr_images +=  @{$$_{files}} if (exists $$_{files}) } for (@replies);

        # write the shortened list of replies back
        $$thread{posts}      = [ $parent, @replies ];
        $$thread{omitmsg}    = get_omit_message( ($replies-1) - $curr_replies, ($images-1) - $curr_images);
        $$thread{num}        = ${$$thread{posts}}[0]{num};

        # abbreviate the remaining posts
        foreach ( @{ $$thread{posts} } ) {
            # create ref-links
            $$_{comment} = resolve_reflinks($$_{comment});

            my $abbreviation =
             abbreviate_html( $$_{comment}, $$cfg{MAX_LINES_SHOWN}, $$cfg{APPROX_LINE_LENGTH} );
            if ($abbreviation) {
                $$_{abbrev} = get_abbrev_message(count_lines($$_{comment}) - count_lines($abbreviation));
                $$_{comment_full} = $$_{comment};
                $$_{comment} = $abbreviation;
            }
        }
    }

    # make the list of pages
    my @pages = map +{ page => $_ }, ( 1 .. $total );
    foreach my $p (@pages) {
        $$p{filename} = expand_filename( "page/" . $$p{page} );
        if ( $$p{page} == $page ) { $$p{current} = 1 }   # current page, no link
    }

    my ( $prevpage, $nextpage );
    # phutaba pages:    1 2 3
    # perl array index: 0 1 2
    # example for page 2: the prev page is at array pos 0, current page at array pos 1, next page at array pos 2
    $prevpage = $pages[ $page - 2 ]{filename} if ( $page != 1 );
    $nextpage = $pages[ $page     ]{filename} if ( $page != $total );

    my $loc = get_geolocation(get_remote_addr());

    if ( $page > ( $total ) ) {
        make_error($$locale{S_INVALID_PAGE});
    }

    make_http_header();
    my $output =
            $tpl->page({
                postform     => ( $$cfg{ALLOW_TEXTONLY} or $$cfg{ALLOW_IMAGES} or $isAdmin ),
                image_inp    => ( $$cfg{ALLOW_IMAGES} or $isAdmin),
                textonly_inp => ( $$cfg{ALLOW_IMAGES} and $$cfg{ALLOW_TEXTONLY} ),
                captcha_inp  => need_captcha($$cfg{CAPTCHA_MODE}, $$cfg{CAPTCHA_SKIP}, $loc),
                prevpage     => $prevpage,
                nextpage     => $nextpage,
                pages        => \@pages,
                loc          => $loc,
                threads      => \@threads,
                admin        => $isAdmin,
                modclass     => $session[1],
                leet         => is_leet($name),
                stylesheets  => get_stylesheets(),
                cfg          => $cfg,
                locale       => $locale
            });

    $output =~ s/^\s+\n//mg;
    print($output);
}

sub show_thread {
    my ($thread, $admin, $name) = @_;
    my ( $sth, $row, @thread );
    my ( $filename, $tmpname );
    my @session;

    # if we try to call show_thread with admin parameter
    # the admin password will be checked and this
    # variable will be 1
    my $isAdmin = 0;
    if(defined($admin))
    {
        @session = check_password($admin, '', 'silent');
        if ($session[0]) { $isAdmin = 1; }
    }

    $sth = $dbh->prepare(
            "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=? OR parent=? ORDER BY num ASC;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute( $thread, $thread ) or make_error($$locale{S_SQLFAIL});

    while ( $row = get_decoded_hashref($sth) ) {
        $$row{comment} = resolve_reflinks($$row{comment});
        push( @thread, $row );
    }
    $sth->finish;

    add_images_to_thread(@thread) if($thread[0]);

    make_error($$locale{S_NOTHREADERR}, 1) if ( !$thread[0] or $thread[0]{parent} );

    make_http_header();
    my $loc = get_geolocation(get_remote_addr());
    my $locked = $thread[0]{locked};
    my $output = 
            $tpl->page({
                thread       => $thread,
                title        => $thread[0]{subject},
                postform     => ( ($$cfg{ALLOW_TEXT_REPLIES} or $$cfg{ALLOW_IMAGE_REPLIES} ) and !$locked or $isAdmin),
                image_inp    => ( $$cfg{ALLOW_IMAGE_REPLIES} or $isAdmin ),
                captcha_inp  => need_captcha($$cfg{CAPTCHA_MODE}, $$cfg{CAPTCHA_SKIP}, $loc),
                textonly_inp => 0,
                dummy        => $thread[$#thread]{num},
                loc          => $loc,
                threads      => [ { posts => \@thread } ],
                admin        => $isAdmin, 
                modclass     => $session[1],
                locked       => $locked,
                leet         => is_leet($name),
                stylesheets  => get_stylesheets(),
                cfg          => $cfg,
                locale       => $locale
            });
    $output =~ s/^\s+\n//mg;
    print($output);
}

sub get_files {
    my ($threadid, $postid, $backup, $files) = @_;
    my ($sth, $res, $where, $uploadname);

    if ($threadid) {
        # get all files of a thread with one query
        $where = " WHERE thread=? OR post=? ORDER BY post ASC, num ASC;";
    } else {
        # get all files of one post only
        $where = " WHERE post=? ORDER BY num ASC;";
    }

    $sth = $dbh->prepare(
          "SELECT * FROM "
        . ( $backup ? $$cfg{SQL_BACKUP_IMG_TABLE} : $$cfg{SQL_TABLE_IMG} )
        . $where
    ) or make_error($$locale{S_SQLFAIL});

    if ($threadid) {
        $sth->execute($threadid, $threadid) or make_error($$locale{S_SQLFAIL});
    } else {
        $sth->execute($postid) or make_error($$locale{S_SQLFAIL});
    }

    while ($res = get_decoded_hashref($sth)) {
        $uploadname = remove_path($$res{uploadname});
        $$res{uploadname} = clean_string($uploadname);
        $$res{displayname} = clean_string(get_displayname($uploadname));

        # static thumbs are not used anymore (for old posts)
        $$res{thumbnail} = undef if ($$res{thumbnail} =~ m|^\.\./img/|);        

        # board path is added by expand_filename
        if($backup) {
            $$res{image} =~ s!^.*[\\/]!!;
            $$res{thumbnail} =~ s!^.*[\\/]!!;
            $$res{image} = '/' . $$cfg{SELFPATH} . '/' . $$cfg{ORPH_DIR} . $$cfg{BACKUP_DIR} . $$res{image};
            $$res{thumbnail} = '/' . $$cfg{SELFPATH} . '/' . $$cfg{ORPH_DIR} . $$cfg{BACKUP_DIR} . $$res{thumbnail};
        }

        push(@$files, $res);
    }
}

sub add_images_to_thread {
    my (@posts) = @_;
    my ($sthfiles, $res, @files, $uploadname, $post);

    @files = ();
    get_files($posts[0]{num}, 0, 0, \@files);
    return unless (@files);

    foreach $post (@posts) {
        while (@files and $$post{num} == $files[0]{post}) {
            push(@{$$post{files}}, shift(@files))
        }
    }
}

sub add_images_to_row {
    my ($row, $backup) = @_;
    my @files = (); # all files of one post for loop-processing in the template

    if ($backup) {
        get_files(0, $$row{postnum}, 1, \@files);
    } else {
        get_files(0, $$row{num}, 0, \@files);
    }
    $$row{files} = [@files] if (@files); # copy the array to an arrayref in the post
}

sub resolve_reflinks {
    my ($comment, $board) = @_;

    $comment =~ s|<!--reflink-->&gt;&gt;&gt;(.+?)/([0-9]+)|
        my $res = get_cb_post($2,$1);
        if ($res) { '<span class="backreflink"><a href="'.get_reply_link($$res{num},$$res{parent},0,$1).'">&gt;&gt;&gt;/'.$1.'/'.$2.'</a></span>' }
        else { '<span class="backreflink"><del>&gt;&gt;&gt;/'.$1.'/'.$2.'</del></span>'; }
    |ge;

    $comment =~ s|<!--reflink-->&gt;&gt;([0-9]+)|
        my $res;
        if($board) { $res = get_cb_post($1,$board) }
        else { $res = get_post($1) }
        if ($res) { '<span class="backreflink"><a href="'.get_reply_link($$res{num},$$res{parent},0,$board).'">&gt;&gt;'.$1.'</a></span>' }
        else { '<span class="backreflink"><del>&gt;&gt;'.$1.'</del></span>'; }
    |ge;

    return $comment;
}

sub get_omit_message {
    my ($posts, $files) = @_;
    return "" if !$posts;

    my $omitposts = $$locale{S_ABBR1};
    $omitposts = sprintf($$locale{S_ABBR2}, $posts) if ($posts > 1);

    my $omitfiles = "";
    $omitfiles = $$locale{S_ABBRIMG1} if ($files == 1);
    $omitfiles = sprintf($$locale{S_ABBRIMG2}, $files) if ($files > 1);

    return $omitposts . $omitfiles . $$locale{S_ABBR_END};
}

sub get_abbrev_message {
    my ($lines) = @_;
    return $$locale{S_ABBRTEXT1} if ($lines == 1);
    return sprintf($$locale{S_ABBRTEXT2}, $lines);
}

sub print_page {
    my ( $filename, $contents ) = @_;

    $contents = encode_string($contents);

    #       $PerlIO::encoding::fallback=0x0200 if($has_encode);
    #       binmode PAGE,':encoding('.CHARSET.')' if($has_encode);

    if (USE_TEMPFILES) {
        my $tmpname = $$cfg{RES_DIR} . 'tmp' . int( rand(1000000000) );

        open( PAGE, ">$tmpname" ) or make_error($$locale{S_NOTWRITE});
        print PAGE $contents;
        close PAGE;

        rename $tmpname, $filename;
    }
    else {
        open( PAGE, ">$filename" ) or make_error($$locale{S_NOTWRITE});
        print PAGE $contents;
        close PAGE;
    }
}

sub find_posts {
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
    my @results;

    if (length($lfind) >= 3) {
        # grab all posts, in thread order (ugh, ugly kludge)
        $sth = $dbh->prepare(
            "SELECT * FROM " . $$cfg{SQL_TABLE} . " ORDER BY sticky DESC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC"
        ) or make_error($$locale{S_SQLFAIL});
        $sth->execute() or make_error($$locale{S_SQLFAIL});

        while ((my $row = get_decoded_hashref($sth)) and ($count < ($$cfg{MAX_SEARCH_RESULTS})) and ($threads <= ($$cfg{MAX_SHOWN_THREADS}) )) {
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
                    # $$row{sticky_isnull} = 1; # hack, until this field is removed.
                    push @results, $row;
                } else { # reply post
                    push @results, $row unless ($op_only);
                }
                $count = @results;
            }
        }
        $sth->finish; # Clean up the record set
    }

    make_http_header();
    my $output =
            $tpl->search({
                title       => $$locale{S_SEARCHTITLE},
                posts       => \@results,
                find        => $find,
                oponly      => $op_only,
                insubject   => $in_subject,
                filenames   => $in_filenames,
                comment     => $in_comment,
                count       => $count,
                admin       => 0,
                stylesheets => get_stylesheets(),
                cfg         => $cfg,
                locale      => $locale
            });

    $output =~ s/^\s+\n//mg;
    print($output);
}

#
# Posting
#
sub post_stuff {
    my (
        $parent,  $spam1,   $spam2,     $name,      $email,
        $gb2,     $subject, $comment,   $password,  $nofile,
        $captcha, $admin,   $no_format, $postfix,   $as_staff,
        $no_pomf, $sticky,  $locked,    $autosage,  @files
    ) = @_;

    my $file = $files[0]; # file count

    # I HAVE AN OCD SO LEAVE IT AS IS
    my $admin_post = 0;
    my $original_comment = $comment;
    # get a timestamp for future use
    my $time = time();

    # sticky should never be NULL
    $sticky = 0 unless $sticky;

    # check that the request came in as a POST, or from the command line
    make_error($$locale{S_UNJUST})
      if ( $ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} ne "POST" );

    # clean up invalid admin cookie/session or posting would fail
    my @session = check_password( $admin, '', 'silent' );
    $admin = "" unless ($session[0]);

    if ($admin)  # check admin password
    {
        $admin_post = 1;
    }
    else {

        # forbid admin-only features
        make_error($$locale{S_WRONGPASS})
          if ( $no_format or $postfix or $as_staff or $sticky or $locked or $autosage );

        # forbid posting if enabled
        make_error($$locale{S_NOPOSTING}) if ($$cfg{DISABLE_POSTING});

        # check what kind of posting is allowed
        if ($parent) {
            make_error($$locale{S_NOTALLOWED}) if ( $file  and !($$cfg{ALLOW_IMAGE_REPLIES}) );
            make_error($$locale{S_NOTALLOWED}) if ( !$file and !($$cfg{ALLOW_TEXT_REPLIES}) );
        }
        else {
            make_error($$locale{S_NOTALLOWED}) if ( $file  and !($$cfg{ALLOW_IMAGES}) );
            make_error($$locale{S_NOTALLOWED}) if ( !$file and !($$cfg{ALLOW_TEXTONLY}) );
        }
    }

    if($sticky) {
        $sticky=get_max_sticky();
        if($parent) {
            my $stickyupdate=$dbh->prepare(
                "UPDATE "
                . $$cfg{SQL_TABLE} 
                . " SET sticky=? WHERE num=? OR parent=?;") or make_error($$locale{S_SQLFAIL});
            $stickyupdate->execute($sticky, $parent, $parent) or make_error($$locale{S_SQLFAIL});
            $stickyupdate->finish;
        }
    }
    
    if ($locked) {
        $locked=1;
        if ($parent) {
            my $lockupdate=$dbh->prepare(
                "UPDATE ".$$cfg{SQL_TABLE}
                . " SET locked=? WHERE num=? OR parent=?;")
                or make_error($$locale{S_SQLFAIL});
            $lockupdate->execute($locked, $parent, $parent) or make_error($$locale{S_SQLFAIL});
            $lockupdate->finish;
        }
    }

    if ($autosage) {
        $autosage=1;
        if ($parent) {
            my $lockupdate=$dbh->prepare(
                "UPDATE "
                . $$cfg{SQL_TABLE}
                . " SET autosage=? WHERE num=? OR parent=?;")
                or make_error($$locale{S_SQLFAIL});
            $lockupdate->execute($autosage, $parent, $parent)
                or make_error($$locale{S_SQLFAIL});
            $lockupdate->finish;
        }
    }

    # don't allow mods to post html
    make_error($$locale{S_NOPRIVILEGES}) if( $no_format and $session[1] ne 'admin' );

    # check for weird characters
    make_error($$locale{S_UNUSUAL}) if ( $parent  =~ /[^0-9]/ );
    make_error($$locale{S_UNUSUAL}) if ( length($parent) > 10 );
    make_error($$locale{S_UNUSUAL}) if ( $name    =~ /[\n\r]/ );
    make_error($$locale{S_UNUSUAL}) if ( $email   =~ /[\n\r]/ );
    make_error($$locale{S_UNUSUAL}) if ( $subject =~ /[\n\r]/ );

    # check for excessive amounts of text
    make_error($$locale{S_TOOLONG}) if ( length($name)    > $$cfg{MAX_FIELD_LENGTH} );
    make_error($$locale{S_TOOLONG}) if ( length($email)   > $$cfg{MAX_FIELD_LENGTH} );
    make_error($$locale{S_TOOLONG}) if ( length($subject) > $$cfg{MAX_FIELD_LENGTH} );
    make_error($$locale{S_TOOLONG}) if ( length($comment) > $$cfg{MAX_COMMENT_LENGTH} );

    # check to make sure the user selected a file, or clicked the checkbox
    make_error($$locale{S_NOPIC}) if ( !$parent and !$file and !$nofile and !$admin_post );

    # check for empty reply or empty text-only post
    make_error($$locale{S_NOTEXT}) if ( $comment =~ /^\s*$/ and !$file );

    # get file size, and check for limitations.
    my (@size, @file_errors);
    for (my $i = 0; $i < $$cfg{MAX_FILES}; $i++) {
        ($size[$i], @file_errors[$i]) = get_file_size($files[$i], $no_pomf) if ($files[$i]);
    }
    if( grep { defined($_) } @file_errors ) {
        my $errstr = "<span class=\"prewrap\">" . join "\n" . "</span>", @file_errors;
        make_error($errstr);
    }

    # find IP
    my $ip = get_remote_addr(); 
    my $ssl = ( $ENV{HTTP_X_ALUHUT} || $ENV{SSL_CIPHER} );
    undef($ssl) unless $ssl;

    #$host = gethostbyaddr($ip);
    my $numip = dot_to_dec($ip);

    # set up cookies
    my $c_name     = $name;
    my $c_email    = $email;
    my $c_password = $password;
    my $c_gb2      = $gb2;
    my $c_nopomf   = $no_pomf;

    # check if IP is whitelisted
    my $whitelisted = is_whitelisted($numip);
    dnsbl_check($ip) if ( !$whitelisted and $$cfg{ENABLE_DNSBL_CHECK} );

    # process the tripcode - maybe the string should be decoded later
    my ($trip, $spectrip);
    ( $name, $trip, $spectrip ) = process_leetcode( $name ); # process a l33t tripcode
    ( $name, $trip ) = process_tripcode( $name, $$cfg{TRIPKEY}, SECRET, CHARSET ) unless $trip;

    # get as number and owner
    my ($as_num, $as_info) = get_as_info($ip);
    $as_info = clean_string($as_info);

    # check for bans
    ban_check( $numip, $c_name, $subject, $comment, $as_num ) unless $whitelisted;

    # check for spam trap fields
    if ($spam1 or $spam2) {
        my ($banip, $banmask) = parse_range($numip, '');

        eval {
            $dbh->begin_work();

            my $banan = $dbh->prepare(
                "INSERT INTO " . $$cfg{SQL_ADMIN_TABLE} . " VALUES(null,?,?,?,?,?,?,?);")
              or make_error($$locale{S_SQLFAIL});
            $banan->execute('ipban', 'Spambot [Auto Ban]', $banip, $banmask, '', $time, $time + 259200)
              or make_error($$locale{S_SQLFAIL});

            $banan->finish;

            $dbh->commit();
        };
        if ($@) {
            eval { $dbh->rollback() };
            make_error($$locale{S_SQLFAIL});
        }
        make_error($$locale{S_SPAM});
    }

    # get geoip info
    my ($city, $region_name, $country_name, $loc) = get_geolocation($ip);
    $region_name = "" if ($region_name eq $city);
    $region_name = clean_string($region_name);
    $city = clean_string($city);

    # check captcha
    check_captcha( $dbh, $captcha, $ip, $parent, $$cfg{SELFPATH}, $locale, $cfg )
      if ( need_captcha($$cfg{CAPTCHA_MODE}, $$cfg{CAPTCHA_SKIP}, $loc) and !$admin_post and !is_trusted($trip) );

    $loc = join("<br />", $loc, $country_name, $region_name, $city, $as_info);

    # check if thread exists, and get lasthit value
    my ( $parent_res, $lasthit, $autosage );
    if ($parent) {
        $parent_res = get_parent_post($parent) or make_error($$locale{S_NOTHREADERR});

        $lasthit = $$parent_res{lasthit};
        $sticky = $$parent_res{sticky};
        $locked = $$parent_res{locked};
        $autosage = $$parent_res{autosage};

        make_error($$locale{S_LOCKED}) if ($locked and !$admin_post);
    }
    else {
        $lasthit = $time;
    }

    # kill the name if anonymous posting is being enforced
    # and we've not entered special tripcode...
    if ($$cfg{FORCED_ANON} && !$admin_post and !$spectrip) {
        $name = '';
        $trip = '';
        if($$cfg{ENABLE_RANDOM_NAMES}) {
            my $names = $$cfg{RANDOM_NAMES}; 
            $name = @$names[rand(@$names)];
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
    $subject = $$cfg{S_ANOTITLE}            unless $subject;
    $comment = $$cfg{S_ANOTEXT}             unless $comment;
    $original_comment = "empty"             unless $original_comment;
    # flood protection - must happen after inputs have been cleaned up
    flood_check( $numip, $time, $comment, $file, $parent );

    # Manager and deletion stuff - duuuuuh?

    # copy file, do checksums, make thumbnail, etc
    my (@filename, @md5, @width, @height, @thumbnail, @tn_width, @tn_height, @info, @info_all, @uploadname);
    foreach (my $i = 0; $i < $$cfg{MAX_FILES}; $i++) {
        if ($files[$i]) {
            # TODO: replace by $time when open_unique works
            my $file_ts = time() . sprintf("-%03d", int(rand(1000)));
            $file_ts = $time unless ($i);

            ($filename[$i], $md5[$i], $width[$i], $height[$i],
                $thumbnail[$i], $tn_width[$i], $tn_height[$i],
                $info[$i], $info_all[$i], $uploadname[$i])
                = process_file($files[$i], $files[$i], $file_ts, $c_nopomf);
        }
    }

    $numip = "0" if ($$cfg{ANONYMIZE_IP_ADDRESSES} and $admin_post);
    if ($as_staff) { $as_staff = 1; }
    else           { $as_staff = 0; }

    my $sth;

    # finally, write to the database
    eval {
        $dbh->begin_work();

        $sth = $dbh->prepare(
            "INSERT INTO " . $$cfg{SQL_TABLE} . "
            VALUES(null,?,?,?,?,?,?,?,?,?,?,null,?,?,?,?,?,?,?);"
        ) or make_error($$locale{S_SQLFAIL});

        $sth->execute(
            $parent,     $time,     $lasthit,      $numip,
            $name,       $trip,     $email,        $subject,
            $password,   $comment,  $autosage,     $as_staff,
            $admin_post, $locked,   $sticky,       $loc,
            $ssl
        ) or make_error($$locale{S_SQLFAIL});

        $dbh->commit();
    };
    if ($@) {
        eval { $dbh->rollback() };
        make_error($$locale{S_SQLFAIL});
    }

    # get the new post id
    $sth = $dbh->prepare("SELECT " . get_sql_lastinsertid() . ";") or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
    my $new_post_id = ($sth->fetchrow_array())[0];

    # log admin post
    log_action( 'adminpost', $new_post_id, '', $admin ) if($admin_post and $as_staff);

    # insert file information into database
    if ($file) {
        eval {
            $dbh->begin_work();

            $sth = $dbh->prepare("INSERT INTO " . $$cfg{SQL_TABLE_IMG} . " VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?);" )
                or make_error($$cfg{S_SQLFAIL});
    
            my $thread_id = $parent;
            $thread_id = $new_post_id if (!$parent);
    
            foreach (my $i = 0; $i < $$cfg{MAX_FILES}; $i++) {
                ($sth->execute(
                    $thread_id, $new_post_id, $filename[$i], $size[$i], $md5[$i], $width[$i], $height[$i],
                    $thumbnail[$i], $tn_width[$i], $tn_height[$i], $uploadname[$i], $info[$i], $info_all[$i]
                ) or make_error($$cfg{S_SQLFAIL})) if ($files[$i]);
            }
        };
        if ($@) {
            eval { $dbh->rollback() };
            make_error($$locale{S_SQLFAIL});
        }
    }

    if ($parent) { # bumping
        # if parent has autosage set, the sage_count SQL query does not need to be executed
        my $bumplimit = ($autosage or $$cfg{MAX_RES} and sage_count($parent_res) > $$cfg{MAX_RES});

        # check for sage, or too many replies
        unless ( $email =~ /sage/i or $bumplimit ) {
            $sth =
              $dbh->prepare(
                "UPDATE " . $$cfg{SQL_TABLE} . " SET lasthit=? WHERE num=? OR parent=?;"
              );
            $sth->execute( $time, $parent, $parent ) or make_error($$locale{S_SQLFAIL});
        }
        if ( $bumplimit and !$autosage ) {
            $sth =
              $dbh->prepare(
                  "UPDATE " . $$cfg{SQL_TABLE} . " SET autosage=1 WHERE num=? OR parent=?;"
              );
            $sth->execute( $parent, $parent ) or make_error($$locale{S_SQLFAIL});
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
        nopomf    => $c_nopomf,
        -charset  => CHARSET,
        -autopath => $$cfg{COOKIE_PATH},
        -expires  => time+14*24*3600
    );  # yum!
    $sth->finish;

    if ($c_gb2 =~ /thread/i) { # forward back to the page
        if ($parent) { make_http_forward( get_board_path() . "thread/" . $parent . ( $new_post_id ? "#${new_post_id}" : "" ) ); }
        elsif($new_post_id) { make_http_forward( get_board_path() . "thread/" . $new_post_id ); }
        else { make_http_forward( get_board_path() ); } # shouldn't happen
    }
    else {
        make_http_forward( get_board_path() );
    }
}

sub is_whitelisted {
    my ($numip) = @_;
    my ($sth, $where);

    if (length(pack('w', $numip)) > 5) { # IPv6 - no support for network masks yet, only single hosts
        $where = " WHERE type='whitelist' AND ival1=?;";
    } else { # IPv4
        $where = " WHERE type='whitelist' AND ? & ival2 = ival1 & ival2;";
    }
    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . $$cfg{SQL_ADMIN_TABLE}
          . $where)
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($numip) or make_error($$locale{S_SQLFAIL});
    my $ret = ( $sth->fetchrow_array() )[0];
    $sth->finish;

    return 1 if ( $ret );
    return 0;
}

sub is_trusted {
    my ($trip) = @_;
    my ($sth);
    $sth =
      $dbh->prepare( "SELECT count(*) FROM "
          . $$cfg{SQL_ADMIN_TABLE}
          . " WHERE type='trust' AND sval1 = ?;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($trip) or make_error($$locale{S_SQLFAIL});
    my $ret = ( $sth->fetchrow_array() )[0];
    $sth->finish;

    return 1 if ( $ret );
    return 0;
}


sub is_leet {
    my ($name) = @_;
    my $trip;

    my $trips   = get_settings('trips');
    my $tripkey = $$cfg{TRIPKEY} || "!";
    if ( $name =~ /(.*?)(?:#|$tripkey|nya:)(.+)$/ ) {
        $trip = $2;
    }

    return 1 if $$trips{$trip};
    return 0;
}

sub ban_check {
    my ($numip, $name, $subject, $comment, $as_num) = @_;
    my ($sth, $row);
    my $ip = dec_to_dot($numip);
    my @errors;

    # check for as num ban
    if ($as_num) {
        $sth =
          $dbh->prepare( "SELECT count(*) FROM "
              . $$cfg{SQL_ADMIN_TABLE}
              . " WHERE type='asban' AND sval1 = ?;" )
          or make_error($$locale{S_SQLFAIL});
        $sth->execute($as_num) or make_error($$locale{S_SQLFAIL});

        make_ban($$locale{S_BADHOST}, { ip => $ip, showmask => 0, reason => 'AS-Netz-Sperre' }) if (($sth->fetchrow_array())[0]);
    }

    # check if the IP (ival1) belongs to a banned IP range (ival2)
    # also checks expired (sval2) and fetches the ban reason(s) (comment)
    my @bans;

    if ($ip =~ /:/) { # IPv6
        my $client_ip = new Net::IP($ip) or make_error(Net::IP::Error());

        # fetch all active bans from the database, regardless of actual IP version and range
        $sth =
          $dbh->prepare( "SELECT comment,ival1,ival2,sval1,expires FROM "
              . $$cfg{SQL_ADMIN_TABLE}
              . " WHERE type='ipban'"
              . " AND (expires>? OR expires IS NULL OR expires=0)"
              . " ORDER BY num;" )
          or make_error($$locale{S_SQLFAIL});
        $sth->execute(time()) or make_error($$locale{S_SQLFAIL});

        while ($row = get_decoded_hashref($sth)) {
            # ignore IPv4 addresses
            if (length(pack('w', $$row{ival1})) > 5) {
                my $banned_ip   = new Net::IP(dec_to_dot($$row{ival1})) or push( @errors, Net::IP::Error() );
                my $mask_len = get_mask_len($$row{ival2});

                # compare binary strings of $banned_ip and $client_ip up to mask length
                my $client_bits = substr($client_ip->binip(), 0, $mask_len);
                my $banned_bits = substr($banned_ip->binip(), 0, $mask_len);
                if ($client_bits eq $banned_bits) {
                    # fill $banned_bits with 0 to get a valid 128 bit IPv6 address mask
                    $banned_bits .= ('0' x (128 - $mask_len));

                    my ($ban);
                    $$ban{ip}       = $ip;
                    $$ban{network}  = ip_compress_address(ip_bintoip($banned_bits, 6), 6);
                    $$ban{setbits}  = $mask_len;
                    $$ban{showmask} = $$ban{setbits} < 128 ? 1 : 0;
                    $$ban{reason}   = $$row{comment};
                    $$ban{expires}  = $$row{expires};
                    push @bans, $ban;
                }
            }
        }
        make_error(shift(@errors)) if @errors;
    } else { # IPv4 using MySQL 5 (64 bit BIGINT) bitwise logic
        $sth =
          $dbh->prepare( "SELECT comment,ival2,sval1,expires FROM "
              . $$cfg{SQL_ADMIN_TABLE}
              . " WHERE type='ipban' AND ? & ival2 = ival1 & ival2"
              . " AND (expires>? OR expires IS NULL OR expires=0)"
              . " ORDER BY num;" )
          or make_error($$locale{S_SQLFAIL});
        $sth->execute($numip, time()) or make_error($$locale{S_SQLFAIL});

        while ($row = get_decoded_hashref($sth)) {
            my ($ban);
            $$ban{ip}       = $ip;
            $$ban{network}  = dec_to_dot($numip & $$row{ival2});
            $$ban{setbits}  = unpack("%32b*", pack('N', $$row{ival2}));
            $$ban{showmask} = $$ban{setbits} < 32 ? 1 : 0;
            $$ban{reason}   = $$row{comment};
            $$ban{expires}  = $$row{expires};
            push @bans, $ban;
        }
    }

    # this will send the ban message(s) to the client
    make_ban($$locale{S_BADHOST}, @bans) if (@bans);

# fucking mysql...
#   $sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='wordban' AND ? LIKE '%' || sval1 || '%';") or make_error($$locale{S_SQLFAIL});
#   $sth->execute($comment) or make_error($$locale{S_SQLFAIL});
#
#   make_error($$locale{S_STRREF}) if(($sth->fetchrow_array())[0]);

    $sth =
      $dbh->prepare( "SELECT sval1,comment FROM "
          . $$cfg{SQL_ADMIN_TABLE}
          . " WHERE type='wordban';" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});

    while ( $row = get_decoded_arrayref($sth) ) { # TODO: use get_decoded_hashref()
        my $regexp = quotemeta $$row[0];
        make_error($$locale{S_STRREF}) if ( $comment =~ /$regexp/ );
        make_error($$locale{S_STRREF}) if ( $name    =~ /$regexp/ );
        make_error($$locale{S_STRREF}) if ( $subject =~ /$regexp/ );
    }

    # etc etc etc
    $sth->finish;

    return (0);
}

sub dnsbl_check {
    my ($ip) = @_;
    my @errors;

    return if ($ip =~ /:/); # IPv6

    foreach my $dnsbl_info ( @{$$cfg{DNSBL_INFOS}} ) {
        my $dnsbl_host   = @$dnsbl_info[0];
        my $dnsbl_answers = @$dnsbl_info[1];
        my ($result, $resolver);
        my $reverse_ip    = join( '.', reverse split /\./, $ip );
        my $dnsbl_request = join( '.', $reverse_ip,        $dnsbl_host );

        $resolver = Net::DNS::Resolver->new;
        my $bgsock = $resolver->bgsend($dnsbl_request);
        my $sel    = IO::Select->new($bgsock);

        my @ready = $sel->can_read($$cfg{DNSBL_TIMEOUT});
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
                    undef($bgsock);
                }
                $sel->remove($sock);
                undef($sock);
            }
        }

        foreach (@{$dnsbl_answers}) {
            if ( $result eq $_ ) {
                push @errors, sprintf($$locale{S_DNSBL}, $dnsbl_host);
            }
        }
    }
    make_ban( $$locale{S_BADHOSTPROXY}, { ip => $ip, showmask => 0, reason => shift(@errors) } ) if @errors;
}

sub flood_check {
    my ( $ip, $time, $comment, $file, $parent ) = @_;
    my ( $sth, $maxtime );

    unless($parent) {
        $maxtime = $time - ($$cfg{RENZOKU5});
        $sth =
          $dbh->prepare( "SELECT count(`num`) FROM "
              . $$cfg{SQL_TABLE}
              . " WHERE parent=0 AND ip=? AND timestamp>$maxtime;" )
          or make_error($$locale{S_SQLFAIL});
        $sth->execute($ip) or make_error($$locale{S_SQLFAIL});
        make_error($$locale{S_RENZOKU5}) if ( ( $sth->fetchrow_array() )[0] );
    }
    else {
        if ($file) {
            # check for to quick file posts
            $maxtime = $time - ($$cfg{RENZOKU2});
            $sth =
              $dbh->prepare( "SELECT count(`num`) FROM "
                  . $$cfg{SQL_TABLE}
                  . " WHERE ip=? AND timestamp>$maxtime;" )
              or make_error($$locale{S_SQLFAIL});
            $sth->execute($ip) or make_error($$locale{S_SQLFAIL});
            make_error($$locale{S_RENZOKU2}) if ( ( $sth->fetchrow_array() )[0] );
        }
        else {
            # check for too quick replies or text-only posts
            $maxtime = $time - ($$cfg{RENZOKU});
            $sth =
              $dbh->prepare( "SELECT count(`num`) FROM "
                  . $$cfg{SQL_TABLE}
                  . " WHERE ip=? AND timestamp>$maxtime;" )
              or make_error($$locale{S_SQLFAIL});
            $sth->execute($ip) or make_error($$locale{S_SQLFAIL});
            make_error($$locale{S_RENZOKU}) if ( ( $sth->fetchrow_array() )[0] );

            # check for repeated messages
            $maxtime = $time - ($$cfg{RENZOKU3});
            $sth =
              $dbh->prepare( "SELECT count(`num`) FROM "
                  . $$cfg{SQL_TABLE}
                  . " WHERE ip=? AND comment=? AND timestamp>$maxtime;" )
              or make_error($$locale{S_SQLFAIL});
            $sth->execute( $ip, $comment ) or make_error($$locale{S_SQLFAIL});
            make_error($$locale{S_RENZOKU3}) if ( ( $sth->fetchrow_array() )[0] );
        }
    }
    $sth->finish() if($sth);
}

sub format_comment {
    my ($comment) = @_;

    # hide >>/board/1 references from the quoting code
    $comment =~ s/&gt;&gt;&gt;(\/?)(.+)\/([0-9\-]+)/&gt&gt&gt;$1$2\/$3/g;
    # hide >>1 references from the quoting code
    $comment =~ s/&gt;&gt;([0-9\-]+)/&gtgt;$1/g;

    my $handler = sub    # mark >>1 references
    {
        my $line = shift;

        # ref-links will be resolved on every page creation to support links to deleted (and also future) posts.
        # ref-links are marked with a html-comment and checked/generated on every page output.
        $line =~ s/&gt&gt&gt;\/?(.+)\/([0-9]+)/<!--reflink-->&gt;&gt;&gt;$1\/$2/g;
        $line =~ s/&gtgt;([0-9]+)/<!--reflink-->&gt;&gt;$1/g;

        return $line;
    };

    if ($$cfg{ENABLE_WAKABAMARK}) {
        $comment = do_wakabamark($comment, $handler);
    } elsif ($$cfg{ENABLE_BBCODE}) {
        # do_bbcode() will always try to apply (at least some) wakabamark
        $comment = do_bbcode($comment, $handler);
    } else {
        $comment = "<p>" . simple_format($comment, $handler) . "</p>";
    }

    # fix <blockquote> styles for old stylesheets
    $comment =~ s/<blockquote>/<blockquote class="unkfunc">/g;

    # restore >>1 references hidden in code blocks
    $comment =~ s/&gtgt;/&gt;&gt;/g;
    $comment =~ s/&gt&gt&gt;/&gt;&gt;&gt;/g;

    return $comment;
}

sub simple_format {
    my ( $comment, $handler ) = @_;
    return join "<br />", map {
        my $line = $_;

        # make URLs into links
        $line =~
s{(https?://[^\s<>"]*?)((?:\s|<|>|"|\.|\)|\]|!|\?|,|&#44;|&quot;)*(?:[\s<>"]|$))}{\<a href="$1" target="_blank" rel="nofollow"\>$1\</a\>$2}sgi;

        # colour quoted sections if working in old-style mode.
        $line =~ s!^(&gt;.*)$!\<span class="unkfunc"\>$1\</span\>!g
          unless ($$cfg{ENABLE_WAKABAMARK});

        $line = $handler->($line) if ($handler);

        $line;
    } split /\n/, $comment;
}

sub encode_string {
    my ($str) = @_;

    # return $str unless ($has_encode);
    return encode( CHARSET, $str, 0x0400 );
}

sub make_anonymous {
    my ( $ip, $time ) = @_;

    return $$cfg{S_ANONAME} unless ($$cfg{SILLY_ANONYMOUS});

    my $string = $ip;
    $string .= "," . int( $time / 86400 ) if ( $$cfg{SILLY_ANONYMOUS} =~ /day/i );
    $string .= "," . $$cfg{SELFPATH} if ( $$cfg{SILLY_ANONYMOUS} =~ /board/i );

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
        ]
    );
}

sub make_id_code {
    my ( $ip, $time, $link ) = @_;

    return $$cfg{EMAIL_ID} if ( $link and $$cfg{DISPLAY_ID} =~ /link/i );
    return $$cfg{EMAIL_ID} if ( $link =~ /sage/i and $$cfg{DISPLAY_ID} =~ /sage/i );

    # replaced $ENV{REMOTE_ADDR} by get_remote_addr()
    return resolve_host( get_remote_addr() ) if ( $$cfg{DISPLAY_ID} =~ /host/i );
    return get_remote_addr() if ( $$cfg{DISPLAY_ID} =~ /ip/i );

    my $string = "";
    $string .= "," . int( $time / 86400 ) if ( $$cfg{DISPLAY_ID} =~ /day/i );
    $string .= "," . $$cfg{SELFPATH} if ( $$cfg{DISPLAY_ID} =~ /board/i );

    return mask_ip( get_remote_addr(), make_key( "mask", SECRET, 32 ) . $string )
      if ( $$cfg{DISPLAY_ID} =~ /mask/i );

    return hide_data( $ip . $string, 6, "id", SECRET, 1 );
}

sub process_leetcode {
    my ($name, $nonamedecoding) = @_;
    my ($namepart, $trip);

    my $trips = get_settings('trips');
    my $tripkey = $$cfg{TRIPKEY} || "!";
    if ( $name =~ /(.*?)(?:#|$tripkey|nya:)(.+)$/ ) {
        ($namepart, $trip) = ($1, $2);
        $namepart = clean_string($namepart);
    }

    if ($$trips{$trip}) {
        $trip = $$cfg{TRIPKEY} . $$trips{$trip};
    } else {
        return ( $name, undef, undef );
    }

    return ( $namepart, $trip, 1 ) if $nonamedecoding;
    return ( decode_string( $namepart, CHARSET ), $trip, 1 );
}

sub get_cb_post {
    my ($thread, $board) = @_;
    my ($sth,$ret);

    return unless( $board && grep { $_ eq $board } @{$$cfg{BOARDS}} );
    $$cfg{SQL_TABLE} = $board . '_comments';

    $sth = $dbh->prepare(
        "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=? LIMIT 1;"
    ) or '';
    $sth->execute($thread) or '';
    $ret = $sth->fetchrow_hashref();
    $sth->finish;

    return $ret;
}

sub get_post {
    my ($thread) = @_;
    my ($sth,$ret);

    $sth = $dbh->prepare(
        "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=? LIMIT 1;"
    ) or '';
    $sth->execute($thread) or '';
    $ret = $sth->fetchrow_hashref();
    $sth->finish;

    return $ret;
}

sub get_parent_post {
    my ($thread) = @_;
    my ($sth,$ret);

    $sth = $dbh->prepare(
        "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=? and parent=0 LIMIT 1;"
    ) or '';
    $sth->execute($thread) or '';
    $ret = $sth->fetchrow_hashref();
    $sth->finish;

    return $ret;
}

sub sage_count {
    my ($parent) = @_;
    my ($sth);

    $sth =
      $dbh->prepare( "SELECT count(`num`) FROM "
          . $$cfg{SQL_TABLE}
          . " WHERE parent=? AND NOT ( timestamp<? AND ip=? ) LIMIT 1;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute( $$parent{num}, $$parent{timestamp} + ($$cfg{NOSAGE_WINDOW}),
        $$parent{ip} )
      or make_error($$locale{S_SQLFAIL});

    my $ret = ( $sth->fetchrow_array() )[0];
    $sth->finish;
    return $ret;
}

sub get_file_size {
    my ($file, $nopomf) = @_;
    my (@filestats, $errfname, $errfsize, $max_size);
    my $size = 0;
    my $err = undef;
    my $ext = $file =~ /\.([^\.]+)$/;
    my $sizehash = $$cfg{FILESIZES};

    @filestats = stat($file);
    $size = $filestats[7];
    $max_size = $$cfg{MAX_KB};
    $max_size = $$sizehash{$ext} if ($$sizehash{$ext});
    $errfname = get_displayname(clean_string(decode_string($file, CHARSET)));
    # or round using: int($size / 1024 + 0.5)
    $errfsize = sprintf("%.2f", $size / 1024) . " kB &gt; " . $max_size . " kB";

    $err = $$locale{S_TOOBIG} . " ($errfname: $errfsize)" 
      if ( $nopomf eq 'on' && !grep {$_ eq $ext} @{$$cfg{POMF_EXTENSIONS}} and $size > $max_size * 1024 );
    $err = $$locale{S_TOOBIGORNONE} . " ($errfname)" if ($size == 0);  # check for small files, too?

    return ($size, $err);
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
    my ( $file, $uploadname, $time, $nopomf ) = @_;
    my $filetypes = $$cfg{FILETYPES};

    # make sure to read file in binary mode on platforms that care about such things
    binmode $file;

    # analyze file and check that it's in a supported format
    my ( $ext, $width, $height ) = analyze_image( $file, $uploadname );

    #my ($known,$ext,$width,$height) = analyze_file($file, $uploadname);

    my $known = ( $width or $$filetypes{$ext} );
    my $errfname = clean_string(decode_string($uploadname, CHARSET));
    $errfname = ' ('.$errfname.')';

    make_error($$locale{S_BADFORMAT} . $errfname)
      unless ( $$cfg{ALLOW_UNKNOWN} or $known );
    make_error($$locale{S_BADFORMAT} . $errfname)
      if ( grep { $_ eq $ext } @{$$cfg{FORBIDDEN_EXTENSIONS}} );
    make_error($$locale{S_TOOBIG} . $errfname)
      if ( $$cfg{MAX_IMAGE_WIDTH}  and $width > $$cfg{MAX_IMAGE_WIDTH} );
    make_error($$locale{S_TOOBIG} . $errfname)
      if ( $$cfg{MAX_IMAGE_HEIGHT} and $height > $$cfg{MAX_IMAGE_HEIGHT} );
    make_error($$locale{S_TOOBIG} . $errfname)
      if ( $$cfg{MAX_IMAGE_PIXELS} and $width * $height > $$cfg{MAX_IMAGE_PIXELS} );

    # jpeg -> jpg
    $uploadname =~ s/\.jpeg$/\.jpg/i;

    # make sure $uploadname file extension matches detected extension (for internal formats)
    my ($uploadext) = $uploadname =~ /\.([^\.]+)$/;
    $uploadname .= "." . $ext if (lc($uploadext) ne $ext);

    # generate random filename - fudges the microseconds
    my $filebase  = $time . sprintf( "%03d", int( rand(1000) ) );
    my $filename  = $$cfg{SELFPATH} . '/' . $$cfg{IMG_DIR} . $filebase . '.' . $ext;
    my $thumbnail = $$cfg{SELFPATH} . '/' . $$cfg{THUMB_DIR} . $filebase;
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

    $filename .= $$cfg{MUNGE_UNKNOWN} unless ($known);

    # do copying and MD5 checksum
    my ( $md5, $md5ctx, $buffer );

    # prepare MD5 checksum if the Digest::MD5 module is available
    eval 'use Digest::MD5 qw(md5_hex)';
    $md5ctx = Digest::MD5->new unless ($@);

    # copy file
    open( OUTFILE, ">>$filename" ) or make_error($$locale{S_NOTWRITE});
    binmode OUTFILE;
    while ( read( $file, $buffer, 1024 ) )    # should the buffer be larger?
    {
        print OUTFILE $buffer;
        $md5ctx->add($buffer) if ($md5ctx);
    }
    close $file;
    close OUTFILE;

    # do thumbnail
    my ( $tn_width, $tn_height, $tn_ext );

    if ( !$width or !$filename =~ /\.svg$/ )    # unsupported file
    {
        undef $thumbnail;
    }
    elsif ($width > $$cfg{MAX_W}
        or $height > $$cfg{MAX_H}
        or $$cfg{THUMBNAIL_SMALL}
        or $filename =~ /\.svg$/ # why not check $ext?
        or $ext eq 'pdf'
        or $ext eq 'webm' or $ext eq 'mp4')
    {
        if ( $width <= ($$cfg{MAX_W}) and $height <= ($$cfg{MAX_H}) ) {
            $tn_width  = $width;
            $tn_height = $height;
        }
        else {
            $tn_width = $$cfg{MAX_W};
            $tn_height = int( ( $height * ($$cfg{MAX_W}) ) / $width );

            if ( $tn_height > $$cfg{MAX_H} ) {
                $tn_width = int( ( $width * ($$cfg{MAX_H}) ) / $height );
                $tn_height = $$cfg{MAX_H};
            }
        }

        if ($ext eq 'pdf' or $ext eq 'svg') { # cannot determine dimensions for these files
            undef($width);
            undef($height);
            $tn_width = $$cfg{MAX_W};
            $tn_height = $$cfg{MAX_H};
        }

        if ($$cfg{STUPID_THUMBNAILING}) {
            $thumbnail = $filename;
            undef($thumbnail) if($ext eq 'pdf' or $ext eq 'svg' or $ext eq 'webm' or $ext eq 'mp4');
        }
        else {
            if ($ext eq 'webm' or $ext eq 'mp4') {
                undef($thumbnail)
                  unless (
                    make_video_thumbnail(
                        $filename,         $thumbnail,
                        $tn_width,         $tn_height,
                        $$cfg{MAX_W},     $$cfg{MAX_H},
                        $$cfg{VIDEO_CONVERT_COMMAND}
                    )
                  );
            }
            else {
                undef($thumbnail)
                  unless (
                    make_thumbnail(
                        $filename,         $thumbnail,
                        $tn_width,         $tn_height,
                        $$cfg{ENABLE_AFMOD},
                        $$cfg{THUMBNAIL_QUALITY},
                        $$cfg{CONVERT_COMMAND}
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

    my ($info, $info_all) = get_meta_markup($filename, &CHARSET);

    chmod 0644, $filename; # Make file world-readable
    chmod 0644, $thumbnail if defined($thumbnail); # Make thumbnail (if any) world-readable

    if ( $nopomf ne 'on' && grep {$_ eq $ext} @{$$cfg{POMF_EXTENSIONS}} )
    {
        my $pomf = pomf_upload($filename);
        unlink $filename; # remove file from the disk

        if ( $pomf =~/^id: (.+?)$/ ) {
            $filename = "//$pomf_domain/$1";
        }
        else {
            unlink $thumbnail if defined($thumbnail);
            make_error( clean_string($pomf) );
        }
    }

    my $board_path = $$cfg{SELFPATH}; # Clear out the board path name.
    $filename  =~ s/^${board_path}\///;
    $thumbnail =~ s/^${board_path}\///;

    return ($filename, $md5, $width, $height, $thumbnail, $tn_width, $tn_height, $info, $info_all, $uploadname);
}

#
# Sticky/Lock etc
#

sub get_max_sticky {
    my $max = 0;

    # grab all posts from DB
    my $sth=$dbh->prepare("SELECT sticky FROM ".$$cfg{SQL_TABLE}." ORDER BY sticky DESC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC;")
         or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});   
    
    if ( !$sth->rows ) { return 0; }
    
    # Calculate maximum `sticky` value
    while ( my $row = $sth->fetchrow_arrayref() ) {
        $max = $$row[0] if ($$row[0] > $max);
    }

    $sth->finish;    
    return ( $max + 1 );
}

sub thread_control {
    my ( $admin, $threadid, $action ) = @_;
    my ( $sth, $row );
    check_password( $admin, '' );

    $sth = $dbh->prepare( "SELECT sticky,locked,autosage FROM " . $$cfg{SQL_TABLE} . " WHERE num=?;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($threadid) or make_error($$locale{S_SQLFAIL});

    if ( $row = $sth->fetchrow_hashref() ) {
        my $check;
        if($action eq "sticky") {
            $check = $$row{sticky} ? 0 : get_max_sticky();
            $sth = $dbh->prepare( "UPDATE " . $$cfg{SQL_TABLE} . " SET sticky=? WHERE num=? OR parent=?;" )
              or make_error($$locale{S_SQLFAIL});
        }
        elsif($action eq "locked") {
            $check = $$row{locked} eq 1 ? 0 : 1;
            $sth = $dbh->prepare( "UPDATE " . $$cfg{SQL_TABLE} . " SET locked=? WHERE num=? OR parent=?;" )
              or make_error($$locale{S_SQLFAIL});
        }
        elsif($action eq "autosage") {
            $check = $$row{autosage} eq 1 ? 0 : 1;
            $sth = $dbh->prepare( "UPDATE " . $$cfg{SQL_TABLE} . " SET autosage=? WHERE num=? OR parent=?;" )
              or make_error($$locale{S_SQLFAIL});
        }
        else {
            make_error("dildo dodo");
        }
        $sth->execute( $check, $threadid, $threadid ) or make_error($$locale{S_SQLFAIL});
        $sth->finish;
    }
    log_action( $action, $threadid, '', $admin );

    make_http_forward( $ENV{HTTP_REFERER} || get_board_path() . "thread/" . $threadid );
}

#
# Deleting
#

sub delete_all {
    my ($admin, $ip, $mask, $go) = @_;
    my ($sth, $row, @posts);
    my @session = check_password( $admin, '' );

    unless($go and $ip) { # do not allow empty IP (as it would delete anonymized (staff) posts)
        my ($pcount, $tcount);

        $sth = $dbh->prepare("SELECT count(`num`) FROM ".$$cfg{SQL_TABLE}." WHERE ip=? OR ip & ? = ? & ?;") or make_error($$locale{S_SQLFAIL});
        $sth->execute($ip, $mask, $ip, $mask) or make_error($$locale{S_SQLFAIL});
        $pcount = ($sth->fetchrow_array())[0];
        $sth->finish;

        $sth = $dbh->prepare("SELECT count(`num`) FROM ".$$cfg{SQL_TABLE}." WHERE parent=0 AND (ip=? OR ip & ? = ? & ?);") or make_error($$locale{S_SQLFAIL});
        $sth->execute($ip, $mask, $ip, $mask) or make_error($$locale{S_SQLFAIL});
        $tcount = ($sth->fetchrow_array())[0];
        $sth->finish;

        make_http_header();
        print $tpl->delete_panel({
            admin => $admin,
            modclass => $session[1],
            ip => $ip,
            mask => $mask,
            posts => $pcount,
            threads => $tcount,
            cfg => $cfg,
            locale => $locale,
            stylesheets => get_stylesheets()
        });
    }
    else {
        $sth =
          $dbh->prepare( "SELECT num FROM " . $$cfg{SQL_TABLE} . " WHERE ip<>0 AND ip IS NOT NULL AND (ip & ? = ? & ? OR ip=?);" )
          or make_error($$locale{S_SQLFAIL});
        $sth->execute( $mask, $ip, $mask, $ip ) or make_error($$locale{S_SQLFAIL});
        while ( $row = $sth->fetchrow_hashref() ) { push( @posts, $$row{num} ); }
        $sth->finish;

        log_action( 'delall', $ip, '', $admin );
        delete_stuff('', 0, $admin, 1, 0, @posts);
    }
}

sub delete_stuff {
    my ( $password, $fileonly, $admin, $admin_del, $parent, @posts ) = @_;
    my ($post, $ip);
    my ($adminDel, $deletebyip) = (0, 0);
    my $noko = 1; # try to stay in thread after deletion by default 

    if ($admin_del) {
        check_password( $admin, '' );
        $adminDel = 1;
    }

    if ( !$password and !$adminDel ) { $deletebyip = 1; }
    make_error($$locale{S_BADDELPASS})
      unless (
        ( !$password and $deletebyip )
        or ( $password and !$deletebyip )
        or $adminDel
      );    # allow deletion by ip with empty password
            # no password means delete always

    $password = "" if ($adminDel);

    my @errors;
    foreach $post (@posts) {
        $ip = delete_post( $post, $password, $fileonly, $deletebyip, $admin_del, $admin );
        # (:){2,}
        if ($ip !~ /:/ && $ip !~ /\d+\.\d+\.\d+\.\d+/) # Function returned with error string
        {
            push (@errors,"Post $post: ".$ip);
            next;
        }
        $noko = 0 if ( $parent and $post eq $parent ); # the thread is deleted and cannot be redirected to      
    }

    unless (@errors) {
        if ( $noko == 1 and $parent ) {
            make_http_forward( get_board_path() . "thread/" . $parent );
        } else {
            make_http_forward( get_board_path() );
        }
    }
    else {
        my $errstring = "<span class=\"prewrap\">" . join("\n", @errors) . "</span>";
        make_error($errstring);
    }
}

sub delete_post {
    my ( $post, $password, $fileonly, $deletebyip, $admin_del, $admin ) = @_;
    my ( $sth, $row, $res, $reply, $postinfo );

    if(defined($admin_del))
    {
        check_password($admin, '');
    }

    my $thumb   = $$cfg{THUMB_DIR};
    my $src     = $$cfg{IMG_DIR};
    my $numip   = dot_to_dec(get_remote_addr()); # do not use $ENV{REMOTE_ADDR}

    $sth = $dbh->prepare( "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=?;" )
      or return $$locale{S_SQLFAIL};
    $sth->execute($post) or return $$locale{S_SQLFAIL};

    if ( $row = $sth->fetchrow_hashref() ) {
        my $parent_post = get_post($$row{parent});
        my @geoinfo = get_geo_array($$cfg{SELFPATH}, $$row{location}, 1);

        return $$locale{S_BADDELPASS} 
          if ( $password and $$row{password} ne $password );
        return $$locale{S_BADDELIP}
          if ( $deletebyip and ( $numip and $$row{ip} ne $numip ) );
        return $$locale{S_RENZOKU4}
          if ( $$row{timestamp} + $$cfg{RENZOKU4} >= time() and !$admin_del );
        return $$locale{S_LOCKED}
          if ( $parent_post && $$parent_post{locked} and !$admin_del );
        return decode_string("Заебал удалять посты.", CHARSET)
          if (!$admin_del and $geoinfo[4] && $geoinfo[4] == 42610);
        return "This was posted by a moderator or admin and cannot be deleted this way."
          if (!$admin_del and $$row{admin_post} eq 1);

        backup_stuff($row) if ($$cfg{ENABLE_POST_BACKUP});

        unless ($fileonly) {

            if( defined($admin_del) and $password eq "" ) {
                log_action( 'deletepost', $post, '', $admin );
            }

            # remove files from comment and possible replies
            $sth = $dbh->prepare(
                    "SELECT image,thumbnail FROM " . $$cfg{SQL_TABLE_IMG} . " WHERE post=? OR thread=?" )
              or return $$locale{S_SQLFAIL};
            $sth->execute( $post, $post ) or return $$locale{S_SQLFAIL};

            while ( $res = $sth->fetchrow_hashref() ) {
                # delete images if they exist
                unlink $$cfg{SELFPATH}.'/'.$$res{image};
                unlink $$cfg{SELFPATH}.'/'.$$res{thumbnail} if ( $$res{thumbnail} =~ /^$thumb/ );
            }

            # remove post and possible replies
            $sth = $dbh->prepare(
                "DELETE FROM " . $$cfg{SQL_TABLE} . " WHERE num=? OR parent=?;" )
              or return $$locale{S_SQLFAIL};
            $sth->execute( $post, $post ) or return $$locale{S_SQLFAIL};

            $sth = $dbh->prepare(
                "DELETE FROM " . $$cfg{SQL_TABLE_IMG} . " WHERE post=? OR thread=?;" )
              or return $$locale{S_SQLFAIL};
            $sth->execute( $post, $post ) or return $$locale{S_SQLFAIL};

            # prevent GHOST BUMPING by hanging a thread where it belongs: at the time of the last non sage post
            if ($$cfg{PREVENT_GHOST_BUMPING}) {
                # get parent of the deleted post
                # if a thread was deleted, nothing needs to be done
                my $parent = $$row{parent};
                if ($parent) {
                    # its actually a post in a thread, not a thread itself
                    # find the thread to check for autosage
                    $sth = $dbh->prepare(
                        "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=?;" )
                      or return $$locale{S_SQLFAIL};
                    $sth->execute($parent) or return $$locale{S_SQLFAIL};
                    my $threadRow = $sth->fetchrow_hashref();
                    if ( $threadRow and $$threadRow{autosage} != 1 ) {
                        # store the thread OP timestamp value
                        # will be used if no non-sage reply is found
                        my $lasthit = $$threadRow{timestamp};
                        my $sth2;
                        $sth2 =
                          $dbh->prepare( "SELECT * FROM "
                              . $$cfg{SQL_TABLE}
                              . " WHERE parent=? ORDER BY timestamp DESC;"
                          ) or return $$locale{S_SQLFAIL};
                        $sth2->execute($parent) or return $$locale{S_SQLFAIL};
                        my $postRow;
                        my $foundLastNonSage = 0;
                        while ( ( $postRow = $sth2->fetchrow_hashref() )
                            and $foundLastNonSage == 0 )
                        {
                            $foundLastNonSage = $$postRow{timestamp}
                                if ($$postRow{email} !~ /sage/i);
                        }

                        # var now contains the timestamp we have to update lasthit to
                        $lasthit = $foundLastNonSage if ($foundLastNonSage);

                        my $upd =
                          $dbh->prepare( "UPDATE "
                              . $$cfg{SQL_TABLE}
                              . " SET lasthit=? WHERE parent=? OR num=?;" )
                          or return $$locale{S_SQLFAIL};
                        $upd->execute( $lasthit, $parent, $parent )
                          or return $$locale{S_SQLFAIL} . " " . $dbh->errstr();
                    }
                }
            }
        }
        else    # remove just the image(s) and update the database
        {
            if( defined($admin_del) and $password eq "" ) {
                log_action( 'deletefile', $post, '', $admin );
            }
            $sth = $dbh->prepare(
                    "SELECT image,thumbnail FROM " . $$cfg{SQL_TABLE_IMG} . " WHERE post=?" )
              or return $$locale{S_SQLFAIL};
            $sth->execute( $post ) or return $$locale{S_SQLFAIL};

            while ( $res = $sth->fetchrow_hashref() ) {
                # delete images if they exist
                unlink $$cfg{SELFPATH}.'/'.$$res{image};
                unlink $$cfg{SELFPATH}.'/'.$$res{thumbnail} if ( $$res{thumbnail} =~ /^$thumb/ );
            }

            $sth = $dbh->prepare( "UPDATE "
                  . $$cfg{SQL_TABLE_IMG}
                  . " SET size=0,md5=null,thumbnail=null,info=null,info_all=null WHERE post=?;" )
                or return $$locale{S_SQLFAIL};
            $sth->execute($post) or return $$locale{S_SQLFAIL};
        }
        $postinfo = dec_to_dot($$row{ip});
    }
    $sth->finish;

    $postinfo = "Post not found" unless $postinfo;
    return $postinfo;
}

#
# RSS Management
#

sub make_rss { # hater ktory droczit na perenosy skobok sosi xD
    my ($sth, $row);
    my (@items);

    # Retrieve records to be inserted into RSS.
    $sth=$dbh->prepare("SELECT * FROM ".$$cfg{SQL_TABLE}." ORDER BY timestamp DESC LIMIT ".$$cfg{RSS_LENGTH}.";") or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});

    while ($row = get_decoded_hashref($sth))
    {
        $$row{comment} = resolve_reflinks($$row{comment});
        push(@items, $row);
    }

    # Construct the RSS out of post data, using the usual template approach.
    $sth->finish;
    make_rss_header();
    my $out = $tpl->rss({
        items => \@items,
        pub_date => make_date(time, "http"), # Date RSS was generated.
        cfg => $cfg,
        locale => $locale
    });
    $out =~ s/^\n//mg;
    print($out);
}

#
# Editing/Deletion Undoing
#

# Present backup posts to admin
sub make_backup_posts_panel {
    my ($admin, $page)=@_;
    my ($sth,$row,@threads);

    my @session = check_password($admin, '');
    make_error($$cfg{S_NOPRIVILEGES}) if ($session[1] ne 'admin');

    my $isAdmin = 0;
    if (@session) { $isAdmin = 1; }

    # Grab board posts
    if ($page =~ /^t\d+$/)
    {
        $page =~ s/^t//g;
        $sth=$dbh->prepare(
              "SELECT * FROM "
              . $$cfg{SQL_BACKUP_TABLE}
              . " WHERE (postnum=? OR parent=?) AND board_name = ? ORDER BY postnum ASC;"
            ) or make_error($$locale{S_SQLFAIL});
        $sth->execute($page,$page,$$cfg{SELFPATH}) or make_error($$locale{S_SQLFAIL});
        
        $row = get_decoded_hashref($sth);
        add_images_to_row($row, 1);
        make_error("Thread not found in backup.") if !$row;
        my @thread;
        push @thread, $row;
        while ($row=get_decoded_hashref($sth))
        {
            add_images_to_row($row, 1);
            push @thread, $row;
        }
        push @threads,{posts => [@thread]};
        
        make_http_header();
        my $output = $tpl->backup_panel({
            admin => $isAdmin,
            threads => \@threads,
            thread => $page,
            locked => $thread[0]{locked},
            parent => $page,
            modclass => $session[1],
            stylesheets => get_stylesheets(),
            cfg => $cfg,
            locale => $locale
        });
        $output =~ s/^\s+//; # remove whitespace at the beginning
        $output =~ s/^\s+\n//mg; # remove empty lines

        print($output);
    }
    else
    {
        # Grab count of threads and orphaned posts.
        $sth=$dbh->prepare(
            "SELECT COUNT(1) FROM "
            . $$cfg{SQL_BACKUP_TABLE}
            . " A  WHERE (parent=0 OR (parent>0 AND NOT EXISTS (SELECT * FROM "
            . $$cfg{SQL_BACKUP_TABLE}
            . " B WHERE A.parent = B.postnum LIMIT 1))) AND board_name=?;"
        ) or make_error($$locale{S_SQLFAIL});
        $sth->execute($$cfg{SELFPATH}) or make_error($$locale{S_SQLFAIL});

        my $threadcount = ($sth->fetchrow_array)[0];
        $sth->finish();
        
        # Handle page variable
        my $total = get_page_count($threadcount); 
        $total = 1 unless $total;
        $page = $total if ( $page > $total );
        $page = 1 if ( $page !~ /^\d+$/ or $page <= 0 or !$page );
        my $thread_offset = ceil($page*$$cfg{IMAGES_PER_PAGE}-$$cfg{IMAGES_PER_PAGE});

        # Grab the parent posts and posts without parent threads
        $sth=$dbh->prepare(
            "SELECT * FROM "
            . $$cfg{SQL_BACKUP_TABLE}
            . " A WHERE (parent=0 OR (parent>0 AND NOT EXISTS (SELECT * FROM "
            . $$cfg{SQL_BACKUP_TABLE}
            . " B WHERE A.parent = B.postnum LIMIT 1))) AND board_name=? ORDER BY timestampofarchival DESC, num ASC LIMIT ?,?;"
        ) or make_error($$locale{S_SQLFAIL});
        $sth->execute($$cfg{SELFPATH}, $thread_offset, $$cfg{IMAGES_PER_PAGE}) or make_error($$locale{S_SQLFAIL});

        my $threadquery=$dbh->prepare(
            "SELECT * FROM "
            . $$cfg{SQL_BACKUP_TABLE}
            . " WHERE parent=? ORDER BY timestampofarchival DESC, num ASC LIMIT ?,?;"
        ) or make_error($$locale{S_SQLFAIL});

        # Grab the thread posts in each thread
        while ($row=get_decoded_hashref($sth))
        {
            add_images_to_row($row, 1);
            $$row{comment} = resolve_reflinks($$row{comment});
            my @thread = ($row);

            my ($curr_replies, $curr_images);
            my $max_replies = count_maxreplies($row);
            my $threadnumber = $$row{postnum};
            my ($imgcount, $postcount) = ( 0, 0 );
            $$row{standalone} = 1; # Indicates extracted post is orphaned in the database (i.e., without a parent thread)

            unless ($$row{parent}) # We are grabbing both threads and orphaned posts, here.
            {
                $$row{standalone} = 0;

                # Grab thread replies
                my $postcountquery = $dbh->prepare(
                    "SELECT (SELECT COUNT(*) FROM "
                     . $$cfg{SQL_BACKUP_TABLE}
                     . " WHERE parent=?) AS postcount, (SELECT count(*) FROM "
                     . $$cfg{SQL_BACKUP_IMG_TABLE}
                     ." WHERE thread=?) AS imgcount FROM dual;"
                ) or make_error($$locale{S_SQLFAIL});
                $postcountquery->execute($threadnumber, $threadnumber)
                  or make_error($$locale{S_SQLFAIL});
                my $pc = $postcountquery->fetchrow_hashref();
                $postcount = $$pc{postcount};
                $imgcount = $$pc{imgcount};
                $postcountquery->finish();
            
                # Grab limits for SQL query
                my $offset = ( $postcount > $max_replies ) ? $postcount - $max_replies : 0;
                $threadquery->execute($threadnumber, $offset, $max_replies) or make_error($$locale{S_SQLFAIL});

                while (my $inner_row=get_decoded_hashref($threadquery))
                {
                    add_images_to_row($inner_row, 1);
                    $$inner_row{comment} = resolve_reflinks($$inner_row{comment});
                    $curr_images +=  @{$$inner_row{files}} if (exists $$inner_row{files});
                    ++$curr_replies;
                    push @thread, $inner_row;
                }
                $threadquery->finish();
            }

            push @threads, { 
                posts => [@thread],
                omitmsg => get_omit_message( $postcount - $curr_replies, ($imgcount-1) - $curr_images ),
                postnum => $$row{postnum}
            };
        }
        $sth->finish();

        # make the list of pages
        my @pages = map +{ page => $_ }, (1..$total);
        foreach my $p (@pages)
        {
            $$p{filename} = get_script_name() . '?task=postbackups&amp;section=' . $$cfg{SELFPATH} . '&amp;page='.$$p{page};
            if($$p{page} == $page) { $$p{current}=1 } # current page, no link
        }
        
        my ($prevpage, $nextpage);
        $prevpage = $pages[ $page - 2 ]{filename} if ( $page != 1 );
        $nextpage = $pages[ $page     ]{filename} if ( $page != $total );
    
        make_http_header();

        my $output = $tpl->backup_panel({
            admin => $isAdmin,
            nextpage => $nextpage,
            prevpage => $prevpage,
            threads => \@threads,
            modclass => $session[1],
            pages => \@pages,
            stylesheets => get_stylesheets(),
            cfg => $cfg,
            locale => $locale
        });
        $output =~ s/^\s+//; # remove whitespace at the beginning
        $output =~ s/^\s+\n//mg; # remove empty lines

        print($output);
    }
}

# Backup post to backup table.
sub backup_stuff # Delete post or thread.
{
    my $row = $_[0]; # First argument is post drug from database.
    my $affected_board = $_[1] || $$cfg{SELFPATH}; # Second (optional) argument is name of board.
    
    my $timestamp = time();

    backup_post($row,$affected_board, $timestamp);
    
    if (!$$row{parent})
    {
        # Bring up comment table for requested board.
        my $this_board;
        if ($affected_board ne $$cfg{SELFPATH})
        {
            $this_board = fetch_config($affected_board)
                or make_error("Post ".$affected_board.",".$$row{num}." backed up, but board resolution failed.");
        }
        else
        {
            $this_board = $cfg;
        }
        
        # Grab all responses.
        my $sth = $dbh->prepare("SELECT * FROM ".$$this_board{SQL_TABLE}." WHERE parent=? ORDER BY num ASC;") 
            or make_error($$locale{S_SQLFAIL});
        $sth->execute($$row{num}) or make_error($$locale{S_SQLFAIL});

        my $res;
        my $error;
        while ($res=$sth->fetchrow_hashref())
        {
            $error = backup_post($res,$$this_board{SELFPATH},$timestamp);
        }
        make_error($error) if $error;
    }
}

sub backup_post # Delete single post.
{
    my $row = $_[0]; # First argument is post drug from database.
    my $affected_board = $_[1] || $$cfg{SELFPATH}; # Second (optional) argument is name of board.
    my $timestamp = $_[2] || time(); # Time the post was archived, for interface sorting and thread deletion.

    my $sth; # Database variable.
    
    # If post has already been backed up, delete any extraneous copies.
    $sth=$dbh->prepare("DELETE FROM ".$$cfg{SQL_BACKUP_TABLE}." WHERE board_name=? AND postnum=?;") or return $$locale{S_SQLFAIL};
    $sth->execute($affected_board,$$row{num}) or return $$locale{S_SQLFAIL};

    # If images have already been backed up, delete any extraneous copies.
    $sth=$dbh->prepare("DELETE FROM ".$$cfg{SQL_BACKUP_IMG_TABLE}." WHERE board_name=? AND post=?;") or return $$locale{S_SQLFAIL};
    $sth->execute($affected_board,$$row{num}) or return $$locale{S_SQLFAIL};

    # Backup post.
    $sth=$dbh->prepare(
          "INSERT INTO "
          . $$cfg{SQL_BACKUP_TABLE}
          . " VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        ) or return $$locale{S_SQLFAIL};
    $sth->execute(
            $$row{num},
            $affected_board,  $$row{parent},    $$row{timestamp},  $$row{lasthit},
            $$row{ip},        $$row{name},      $$row{trip},       $$row{email},
            $$row{subject},   $$row{password},  $$row{comment},    $$row{banned},
            $$row{autosage},  $$row{adminpost}, $$row{admin_post}, $$row{locked},
            $$row{sticky},    $$row{location},  $$row{secure},     $timestamp
        ) or return $$locale{S_SQLFAIL};
    $sth->finish();

    $sth = $dbh->prepare(
          "SELECT * FROM "
          . $$cfg{SQL_TABLE_IMG}
          . " WHERE post=? or thread=? ORDER BY num ASC;"
        ) or return $$locale{S_SQLFAIL};
    $sth->execute($$row{num}, $$row{num});

    my $sth2 = $dbh->prepare(
        "INSERT INTO "
          . $$cfg{SQL_BACKUP_IMG_TABLE}
          . " VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        ) or return $$locale{S_SQLFAIL};

    my $this_board;
    if ($affected_board ne $$cfg{SELFPATH})
    {
        $this_board = fetch_config($affected_board)
            or return "Post ".$affected_board.",".$$row{num}." backed up, but board resolution failed.";
    }
    else
    {
        $this_board = $cfg;
    }

    while (my $res = get_decoded_hashref($sth))
    {
        $sth2->execute(
            $$res{num},       $affected_board,
            $$res{thread},    $$res{post},      $$res{image},      $$res{size},       $$res{md5},  $$res{width},    $$res{height},
            $$res{thumbnail}, $$res{tn_width},  $$res{tn_height},  $$res{uploadname}, $$res{info}, $$res{info_all}, $timestamp
        ) or return $$locale{S_SQLFAIL};

        my $base_filename = $$res{image};
        $base_filename =~ s!^.*[\\/]!!;           # cut off any directory in filename

        my $base_thumbnail = $$res{thumbnail};
        $base_thumbnail =~ s!^.*[\\/]!!;    # Do the same for the thumbnail.
        
        # Move image.
        copy(
              $$this_board{SELFPATH} . '/' . $$res{image},
              $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_filename
            )  and chmod 0644, $$this_board{SELFPATH} . '/' . $$this_board{BACKUP_DIR} . $base_filename
            if ( -e $$this_board{SELFPATH} . '/' . $$res{image} );

        # Move thumbnail.
        my $thumb_dir = $$this_board{THUMB_DIR};
        if (  $$res{thumbnail} =~ /^$thumb_dir/ )
        {
            copy(
                $$this_board{SELFPATH} . '/' . $$res{thumbnail},
                $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_thumbnail
            ) and chmod 0644, $$this_board{BACKUP_DIR} . $base_thumbnail
            if ( -e $$this_board{SELFPATH} . '/' . $$res{thumbnail} );
        }
    }

    $sth2->finish() if $sth2;
    $sth->finish();

    return 0;
}

sub restore_stuff {
    my ($admin, $board_name, @num) = @_;

    # Confirm administrative rights.
    my @session = check_password($admin,'');
    make_error($$locale{S_NOPRIVILEGES}) if($session[1] ne 'admin');

    my $error;
    foreach my $id (@num)
    {
        $error = restore_post_or_thread($id, $board_name);
        log_action( 'backup_restore', $id, '', $admin );
    }
    make_error($error) if $error;

    make_http_forward($ENV{HTTP_REFERER});
}

sub restore_post_or_thread {
    my ($num,$board_name,$recursive_instance) = @_;

    my ($sth, $res);                    # Database handler.
    my $updated_lasthit = 0;    # Update for the lasthit field when recovering replies to an OP.
    my $stickied_thread = 0;    # Update for stickied field based on whether thread is stickied.
    my $this_board;             # Object for affected board.
    my $locked_thread = 0;      # Update for locked field based on whether thread is locked.
    my $autosage_on = 0;        # ?

    # Resolve board name and set to current board
    if ($board_name ne $$cfg{SELFPATH})
    {
        $this_board=fetch_config($board_name) or return "Failed to resolve board $board_name.";
    }
    else
    {
        $this_board=$cfg;
    }
    
    # Grab post contents
    $sth=$dbh->prepare("SELECT * FROM ".$$cfg{SQL_BACKUP_TABLE}." WHERE board_name=? AND postnum=?;") or return $$locale{S_SQLFAIL};
    $sth->execute($board_name,$num) or return $$locale{S_SQLFAIL};
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    
    return "Post restoration failed: Backup of post in $board_name with original ID $num not found." if (!$row);

    # Delete original post, if applicable.
    $sth=$dbh->prepare("DELETE FROM ".$$this_board{SQL_TABLE}." WHERE num=?;") or return $$locale{S_SQLFAIL};
    $sth->execute($num) or return $$locale{S_SQLFAIL};
    $sth->finish();

    # Check if post belongs to thread and thread is deleted. We cannot bring back a single post from a neutered thread.
    if ($$row{parent})
    {
        my $parent_row = get_post($$row{parent});

        ($updated_lasthit, $stickied_thread, $locked_thread, $autosage_on) =
            ($$parent_row{lasthit}, $$parent_row{stickied}, $$parent_row{locked}, $$parent_row{autosage});

        $sth->finish();

        if (!$updated_lasthit)
        {
            return "Post restoration failed: Post $board_name,$num is a member of a deleted thread.";
        }

        # ...Otherwise, use the updated lasthit field, as it must be in common with the rest of the thread for proper display.
        # Also match the stickied field.
    }
    
    # Restore post.
    $sth=$dbh->prepare(
          "INSERT INTO "
          . $$this_board{SQL_TABLE}
          . " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        ) or return $$locale{S_SQLFAIL};
    $sth->execute(
            $$row{postnum},  $$row{parent},    $$row{timestamp},  $updated_lasthit || time(),
            $$row{ip},       $$row{name},      $$row{trip},       $$row{email},
            $$row{subject},  $$row{password},  $$row{comment},    $$row{banned},
            $$row{autosage}, $$row{adminpost}, $$row{admin_post}, $$row{locked},
            $$row{sticky},   $$row{location},  $$row{secure}
        ) or return $$locale{S_SQLFAIL};

    # Restore images.
    $sth = $dbh->prepare(
          "SELECT * FROM "
          . $$cfg{SQL_BACKUP_IMG_TABLE}
          . " WHERE post=? AND board_name=?;"
        ) or return $$locale{S_SQLFAIL};
    $sth->execute($$row{postnum}, $board_name) or return $$locale{S_SQLFAIL};

    # Restore images.
    my $sth2 = $dbh->prepare(
        "INSERT INTO " . $$cfg{SQL_TABLE_IMG} . " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        ) or return $$locale{S_SQLFAIL};

    while ($res = get_decoded_hashref($sth))
    {
        $sth2->execute(
            $$res{imgnum},    $$res{thread},    $$res{post},       $$res{image},      $$res{size},      $$res{md5},
            $$res{width},     $$res{height},    $$res{thumbnail},  $$res{tn_width},   $$res{tn_height}, $$res{uploadname},
            $$res{info},      $$res{info_all}
        ) or return $$locale{S_SQLFAIL};

        my $base_filename = $$res{image};
        $base_filename =~ s!^.*[\\/]!!; # cut off any directory in filename
        rename (
                  $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_filename, 
                  $$this_board{SELFPATH} . '/' . $$res{image}
               ) and chmod 0644, $$this_board{SELFPATH}.'/'.$$res{image}
            if ( -e $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_filename );

        # Move thumbnail, if applicable.
        my $thumb_dir = $$this_board{THUMB_DIR};
        if ($$res{thumbnail} =~ /^$thumb_dir/)
        {
            $base_filename = $$res{thumbnail};
            $base_filename =~ s!^.*[\\/]!!; # cut off any directory in filename
            rename (
                    $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_filename,
                    $$this_board{SELFPATH} . '/' . $$res{thumbnail}
                   ) and chmod 0644, $$this_board{SELFPATH} . '/' . $$res{thumbnail}
              if ( -e $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_filename );
        }
    }
    $sth2->finish() if $sth2;

    # Delete backup.
    $sth=$dbh->prepare("DELETE FROM ".$$cfg{SQL_BACKUP_TABLE}." WHERE postnum=? AND board_name=?");
    $sth->execute($$row{postnum},$board_name);
    $sth->finish();

    # Delete images
    $sth=$dbh->prepare("DELETE FROM ".$$cfg{SQL_BACKUP_IMG_TABLE}." WHERE post=? AND board_name=?");
    $sth->execute($$row{postnum}, $board_name);
    $sth->finish();

    # If thread is being restored, make sure that all posts backed up *prior* to thread backup is restored. We can base this decision on lasthit. The thread is to be restored as it was prior to deletion.
    if (!$$row{parent})
    {
        $sth=$dbh->prepare("SELECT * FROM ".$$cfg{SQL_BACKUP_TABLE}." WHERE num>? AND parent=? ORDER BY num ASC;");
        $sth->execute($$row{num},$$row{postnum});
        
        # Add recursive instance code variable to prevent excessive caching/redirects.
        while (my $res=$sth->fetchrow_hashref())
        {
            restore_post_or_thread($$res{postnum}, $$this_board{SELFPATH}, 1);
        }
        
        $sth->finish();
    }

    # Rebuild relevant caches.
    if (!$recursive_instance)
    {
        repair_database();
    }
}

sub cleanup_backups_database()
{
    my $sth = $dbh->prepare(
          "SELECT postnum, board_name FROM "
          . $$cfg{SQL_BACKUP_TABLE}
          . " WHERE timestampofarchival < ?;"
        );
    $sth->execute(time - $$cfg{POST_BACKUP_EXPIRE});

    while (my $expired_backup_row = $sth->fetchrow_hashref())
    {
        remove_backup( $$expired_backup_row{postnum}, $$expired_backup_row{board_name} );
    }
}

sub remove_post_from_backup($$@)
{
    my ($admin, $board_name, @id) = @_;
    my @session = check_password( $admin, '' );
    make_error($$locale{S_NOPRIVILEGES}) if($session[1] ne 'admin');

    foreach my $post (@id)
    {
        remove_backup( $post, $board_name );
        log_action( 'backup_remove', $post, '', $admin );
    }

    make_http_forward( $ENV{HTTP_REFERER} );
}

sub remove_backup {
    my ($id, $board_name) = @_;

    my $sth = $dbh->prepare(
          "SELECT post,image,thumbnail FROM "
          . $$cfg{SQL_BACKUP_IMG_TABLE}
          . " WHERE post=? AND board_name=?;"
        );
    $sth->execute($id, $board_name);

    my $delete = $dbh->prepare(
        "DELETE FROM " . $$cfg{SQL_BACKUP_IMG_TABLE} . " WHERE post=?;" )
      or return $$locale{S_SQLFAIL};

    if ( my $this_board = fetch_config($board_name) ) {
        my $thumb = $$this_board{THUMB_DIR};
        while ( my $res = $sth->fetchrow_hashref() ) {
            # delete images if they exist
            my $base_filename = $$res{image};
            my $base_thumbnail = $$res{thumbnail};
            $base_filename =~ s!^.*[\\/]!!;
            $base_thumbnail =~ s!^.*[\\/]!!;

            unlink $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_filename;
            unlink $$this_board{SELFPATH} . '/' . $$this_board{ORPH_DIR} . $$this_board{BACKUP_DIR} . $base_thumbnail
              if ($$res{thumbnail} =~ /^$thumb/);

            # Delete entries from table
            $delete->execute( $$res{post} ) or return $$locale{S_SQLFAIL};
        }
    }

    # Delete post data.
    $sth = $dbh->prepare(
          "DELETE FROM "
          . $$cfg{SQL_BACKUP_TABLE}
          . " WHERE postnum=? AND board_name=?;"
        ) or return $$locale{S_SQLFAIL};
    $sth->execute($id, $board_name) or return $$locale{S_SQLFAIL};

    # Close handles.
    $sth->finish();
    $delete->finish() if $delete;
}

#
# Admin interface
#

sub make_admin_login {
    make_http_header();
    print $tpl->admin_login({
        cfg => $cfg,
        locale => $locale,
        stylesheets  => get_stylesheets()
    });
}

sub make_admin_post_panel {
    my ($admin) = @_;
    my @session = check_password( $admin, '' );

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
        "SELECT count(*) FROM " . $$cfg{SQL_TABLE_IMG} . " WHERE image IS NOT NULL AND size>0;"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});

    my $files = ($sth->fetchrow_array())[0];
    $sth->finish;

    make_http_header();
    print $tpl->post_panel({
        admin         => $admin,
        modclass      => $session[1],
        posts         => $posts,
        threads       => $threads,
        files         => $files,
        size          => $size,
        geoip_api     => $api,
        geoip_results => \@results,
        stylesheets   => get_stylesheets(),
        cfg           => $cfg,
        locale        => $locale
    });
}

sub make_admin_ban_edit # generating ban editing window
{
    my ($admin, $num) = @_;
    my @session = check_password( $admin, '' );
    
    my (@hash, $time);
    my $sth = $dbh->prepare("SELECT * FROM ".$$cfg{SQL_ADMIN_TABLE}." WHERE num=?") or make_error($$locale{S_SQLFAIL});
    $sth->execute($num) or make_error($$locale{S_SQLFAIL});
    my @utctime;
    while (my $row=get_decoded_hashref($sth)) {
        if ($$row{expires} != 0) {
            @utctime = gmtime($$row{expires}); #($sec, $min, $hour, $day,$month,$year)
        } else {
            @utctime = gmtime(time);
        }
        $$row{sec}=$utctime[0];
        $$row{min}=$utctime[1];
        $$row{hour}=$utctime[2];
        $$row{day}=$utctime[3];
        $$row{month}=$utctime[4]++;
        $$row{year}=$utctime[5] + 1900;
        push (@hash, $row);
    }
    $sth->finish;
    make_http_header();
    print $tpl->edit_window({
        admin => $admin,
        modclass => $session[1],
        hash => \@hash,
        stylesheets => get_stylesheets(),
        cfg => $cfg,
        locale => $locale
    });
}

sub make_admin_ban_panel {
    my ($admin, $filter) = @_;
    my ( $sth, $row, @bans, $prevtype );
    my @session = check_password( $admin, '' );

    my $expired = "";
    $expired = " AND (expires IS NULL OR expires=0 OR expires>?)" if ($filter ne "off");

    $sth =
      $dbh->prepare( "SELECT * FROM "
          . $$cfg{SQL_ADMIN_TABLE}
          . " WHERE type='ipban'" . $expired. " OR type='wordban' OR type='whitelist' OR type='trust' OR type='asban'"
          . " ORDER BY type ASC, date DESC, num DESC;"
      ) or make_error($$locale{S_SQLFAIL});

    if ($expired) {
        $sth->execute(time()) or make_error($$locale{S_SQLFAIL});
    } else {
        $sth->execute() or make_error($$locale{S_SQLFAIL});
    }

    while ( $row = get_decoded_hashref($sth) ) {
        $$row{divider} = 1 if ( $prevtype ne $$row{type} );
        $prevtype      = $$row{type};
        $$row{rowtype} = @bans % 2 + 1;
        if ($$row{type} eq 'ipban' or $$row{type} eq 'whitelist') {
            my $flag = get_geolocation(dec_to_dot($$row{ival1}));
            $flag = 'UNKNOWN' if ($flag eq 'unk' or $flag eq 'A1' or $flag eq 'A2');
            $$row{flag} = $flag;
        }
        push @bans, $row;
    }
    $sth->finish;

    make_http_header();
    print $tpl->admin_ban_panel({
        admin => $admin,
        modclass => $session[1],
        filter => $filter,
        cfg => $cfg,
        locale => $locale,
        bans => \@bans,
        stylesheets => get_stylesheets()
    });
}

sub make_admin_orphans {
    my ($admin) = @_;
    my ($sth, $row, @results, @dbfiles, @dbthumbs);

    my @session = check_password($admin,'');
    make_error($$locale{S_NOPRIVILEGES}) if($session[1] ne 'admin');

    my $img_dir = $$cfg{SELFPATH} . '/' . $$cfg{IMG_DIR};
    my $thumb_dir = $$cfg{SELFPATH} . '/' . $$cfg{THUMB_DIR};

    # gather all files/thumbs on disk
    my @files = glob $img_dir . '*';
    my @thumbs = glob $thumb_dir . '*';

    my $board_path = $$cfg{SELFPATH}; # Clear out the board path name.
    $_ =~ s/^${board_path}\/// for @files;
    $_ =~ s/^${board_path}\/// for @thumbs;

    # gather all files/thumbs from database
    $sth = $dbh->prepare("SELECT image, thumbnail FROM " . $$cfg{SQL_TABLE_IMG} . " WHERE size > 0 ORDER by num ASC;")
      or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
    while ($row = get_decoded_arrayref($sth)) {
        push(@dbfiles, $$row[0]);
        push(@dbthumbs, $$row[1]) if $$row[1];
    }
    $sth->finish;

    # copy all entries from the disk arrays that are not found in the database arrays to new arrays
    my %dbfiles_hash = map { $_ => 1 } @dbfiles;
    my %dbthumbs_hash = map { $_ => 1 } @dbthumbs;
    my @orph_files = grep { !$dbfiles_hash{$_} } @files;
    my @orph_thumbs = grep { !$dbthumbs_hash{$_} } @thumbs;

    my $file_count = @orph_files;
    my $thumb_count = @orph_thumbs;
    my @f_orph;
    my @t_orph;

    foreach my $file (@orph_files) {
        my @result = stat($$cfg{SELFPATH}.'/'.$file);
        my $entry = {};
        $$entry{rowtype} = @f_orph % 2 + 1;
        $$entry{name} = $file;
        $$entry{modified} = $result[9];
        $$entry{size} = $result[7];
        push(@f_orph, $entry);
    }

    foreach my $thumb (@orph_thumbs) {
        my @result = stat($$cfg{SELFPATH}.'/'.$thumb);
        my $entry = {};
        $$entry{name} = $thumb;
        $$entry{modified} = $result[9];
        $$entry{size} = $result[7];
        push(@t_orph, $entry);
    }

    make_http_header();
    print $tpl->admin_orphans({
        admin => $admin,
        modclass => $session[1],
        files => \@f_orph,
        thumbs => \@t_orph,
        file_count => $file_count,
        thumb_count => $thumb_count,
        stylesheets => get_stylesheets(),
        cfg => $cfg,
        locale => $locale
    });
}

sub move_files{
    my ($admin, @files) = @_;

    my @session = check_password($admin,'');
    make_error($$locale{S_NOPRIVILEGES}) if($session[1] ne 'admin');

    my $orph_dir = $$cfg{SELFPATH} . '/' . $$cfg{ORPH_DIR};
    my @errors;

    foreach my $file (@files) {
        $file = clean_string($file);
        if ($file =~ m!^[a-zA-Z0-9]+/[a-zA-Z0-9-]+\.[a-zA-Z0-9]+$!) {
            rename($$cfg{SELFPATH}.'/'.$file, $orph_dir . $file) or push(@errors, $$locale{S_NOTWRITE} . ' (' . decode_string($orph_dir . $file, CHARSET) . ')');
        }
    }
    unless (@errors) {
        make_http_forward(get_script_name() . "?task=orphans&section=" . $$cfg{SELFPATH});
    }
    else{
        make_error(join("<br />", @errors));
    }
}

sub do_login {
    my ( $password, $nexttask, $savelogin, $admincookie ) = @_;
    my $crypt;

    if ($password) {
        $crypt = crypt_password($password);
        check_password($crypt, '');
    }
    elsif ( ( check_moder($admincookie) )[0] ne 0 ) {
        $crypt    = $admincookie;
        $nexttask = "show";
    }

    if ($crypt) {
        my $expires = $savelogin ? time+365*24*3600 : time+1800;

        make_cookies(
            wakaadmin => $crypt,
            -charset  => CHARSET,
            -autopath => $$cfg{COOKIE_PATH},
            -expires  => $expires,
            -httponly => 1
        );

        make_http_forward( get_script_name() . "?task=$nexttask&section=".$$cfg{SELFPATH});
    }
    else { make_admin_login() }
}

sub do_logout {
    make_cookies( wakaadmin => "", -expires => 1 );
    make_http_forward( get_script_name() . "?task=loginpanel&section=".$$cfg{SELFPATH});
}

#
# Ban utils
#

sub add_admin_entry {
    my ($admin, $type, $comment, $ival1, $ival2, $sval1, $postid, $expires, $ban_sign, $ajax) = @_;
    my ($sth, $utf8_encoded_json_text, $authorized);
    my ($time) = time();

    check_password( $admin, '' ) if (!$ajax);

    # checks password a second time on non-ajax call to make sure $authorized is always correct.
    $authorized = check_password( $admin, '', 'silent' );

    $expires = make_expiration_date( $expires, $time );

    if (!$authorized) {
        $utf8_encoded_json_text = encode_json({
            "error_code" => 401,
            "error_msg" => 'Unauthorized'
        });
    }
    else {
        $comment = clean_string( decode_string( $comment, CHARSET ) );

        eval {
            $dbh->begin_work();

            $sth = $dbh->prepare(
                "INSERT INTO " . $$cfg{SQL_ADMIN_TABLE} . " VALUES(null,?,?,?,?,?,?,?);" )
              or make_error($$locale{S_SQLFAIL});
            $sth->execute( $type, $comment, $ival1, $ival2, $sval1, $time, $expires )
              or make_error($$locale{S_SQLFAIL});
            if ($postid and $ban_sign) {
                $sth = $dbh->prepare( "UPDATE " . $$cfg{SQL_TABLE} . " SET banned=? WHERE num=? LIMIT 1;" )
                  or make_error($$locale{S_SQLFAIL});
                $sth->execute($time, $postid) or make_error($$locale{S_SQLFAIL});
            }

            $sth->finish;
            $dbh->commit();
        };
        if ($@) {
            eval { $dbh->rollback() };
            make_error($$locale{S_SQLFAIL});
        }

        $utf8_encoded_json_text = encode_json(
            {
                "error_code" => 200,
                "banned_ip" => dec_to_dot($ival1),
                "banned_mask" => dec_to_dot($ival2),
                "reason" => $comment,
                "postid" => $postid,
                "expires" => make_date($expires, '2ch'),
            }
        );
        if($type eq 'ipban'){
            my $obj = dec_to_dot($ival1)." /".get_mask_len($ival2);
            log_action( 'ipban', $obj, '', $admin );
        }
    }
    if ($ajax) {
        make_json_header();
        print $utf8_encoded_json_text;
    } else {
        make_http_forward(get_script_name() . "?task=bans&section=" . $$cfg{SELFPATH});
    }
}

sub check_admin_entry {
    my ($admin, $ival1) = @_;
    my ($sth, $utf8_encoded_json_text, $results);
    if (!check_password( $admin, '', 'silent' )) {
        $utf8_encoded_json_text = encode_json({"error_code" => 401, "error_msg" => 'Unauthorized'});
    }
    else {
        if (!$ival1) {
            $utf8_encoded_json_text = encode_json({"error_code" => 500, "error_msg" => 'Invalid parameter'});
        }
        else {
            $sth = $dbh->prepare("SELECT count(*) FROM "
                . $$cfg{SQL_ADMIN_TABLE}
                . " WHERE type='ipban' AND ival1=? AND (expires IS NULL OR expires=0 OR expires>?);");
            $sth->execute(dot_to_dec($ival1), time());
            $results = ($sth->fetchrow_array())[0];

            $utf8_encoded_json_text = encode_json({"error_code" => 200, "results" => $results});

            $sth->finish;
        }
    }
    make_json_header();
    print $utf8_encoded_json_text;
}

sub edit_admin_entry # subroutine for editing entries in the admin table
{
    my ( $admin, $num, $comment, 
         $sec,   $min, $hour, $day, $month, $year,
         $noexpire
    )=@_;
    my ($sth, $expiration, $changes);
    my @session = check_password( $admin, '' );
    
    make_error("no comment") unless $comment;

    # Sanity check
    my $verify=$dbh->prepare(
          "SELECT * FROM "
          . $$cfg{SQL_ADMIN_TABLE}
          . " WHERE num=?;"
        ) or make_error($$locale{S_SQLFAIL});
    $verify->execute($num) or make_error($$locale{S_SQLFAIL});
    my $row = get_decoded_hashref($verify);
    make_error("Entry has not created or was removed.") if !$row;
    $comment = clean_string( decode_string( $comment, CHARSET ) );

    # New expiration Date   
    $expiration = (!$noexpire) ? (timegm($sec, $min, $hour, $day,$month-1,$year) or make_error("date problem")) : 0;

    # Close old handler
    $verify->finish;

    # Revise database entry
    $sth=$dbh->prepare(
          "UPDATE "
          . $$cfg{SQL_ADMIN_TABLE}
          . " SET comment=?, expires=? WHERE num=?"
          ) or make_error($$locale{S_SQLFAIL});
    $sth->execute($comment, $expiration, $num) or make_error($$locale{S_SQLFAIL});
    $sth->finish;
    
    # Add log entry
    my $obj;
    $obj = dec_to_dot($$row{ival1}) . " /" . get_mask_len($$row{ival2})
              . "<br /> " . $$row{comment} if($$row{type} eq 'ipban');
    log_action( 'editadminentry', $num, $obj, $admin );
    
    make_http_forward( get_script_name() . "?task=bans&section=".$$cfg{SELFPATH});
}

sub remove_admin_entry {
    my ( $admin, $num ) = @_;
    my ($sth);

    check_password( $admin, '' );

    $sth = $dbh->prepare( "SELECT * FROM " . $$cfg{SQL_ADMIN_TABLE} . " WHERE num=?;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($num) or make_error($$locale{S_SQLFAIL});
    my $row = get_decoded_hashref($sth);
    $sth->finish();

    my $obj;
    $obj = dec_to_dot($$row{ival1}) . " /" . get_mask_len($$row{ival2})
              . "<br /> " . $$row{comment} if($$row{type} eq 'ipban');
    log_action( 'removeadminentry', $num, $obj, $admin );

    $sth = $dbh->prepare( "DELETE FROM " . $$cfg{SQL_ADMIN_TABLE} . " WHERE num=?;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($num) or make_error($$locale{S_SQLFAIL});
    $sth->finish;

    make_http_forward( get_script_name() . "?task=bans&section=".$$cfg{SELFPATH});
}

sub make_expiration_date {
    my ($expires,$time)=@_;

    my ($date) = grep { $$_{label} eq $expires } @{$$cfg{BAN_DATES}};

    if(defined $date->{time}) {
        if( $date->{time}!=0 ) { $expires = $time+$date->{time}; } # Use a predefined expiration time
        else { $expires=0 } # Never expire
    }
    elsif( $expires != 0 ) { $expires = $time+$expires } # Expire in X seconds
    else { $expires = 0 } # Never expire

    return $expires;
}

#
# Password check
#

sub crypt_password {
    my $crypt = hide_data( (shift) . get_remote_addr(), 18, "admin", SECRET, 1 ); # do not use $ENV{REMOTE_ADDR}
    # $crypt =~ tr/+/./;    # for web shit
    return $crypt;
}

sub check_password {
    my ( $admin, $password, $mode ) = @_;
    my @moder = check_moder( $admin, $mode );

    if ($password ne "") {
        return ('Admin', 'admin')
          if ( $admin eq crypt_password($password) );
    }
    else {
        return @moder if ( $moder[0] ne 0 );
    }

    make_error($$locale{S_WRONGPASS}) if($mode ne 'silent');
    return 0;
}

sub check_moder {
    my ($pass, $mode) = @_;
    my $nick = get_moder_nick($pass);
    my @info = ( $nick, $$moders{$nick}{class}, $$moders{$nick}{boards} );

    return 0     unless( defined $nick );
    return @info unless( @{$info[2]} ); # No board restriction

    unless ( defined (first { $_ eq $$cfg{SELFPATH} } @{$info[2]} ) )
    {
        make_error(
            sprintf( $$locale{S_NOBOARDACC}, join( ', ', @{$info[2]} ), get_script_name() )
        ) if($mode ne 'silent');
        return 0;
    }
    return @info;
}

sub get_moder_nick {
    my ($pass) = @_;
    first { crypt_password( $$moders{$_}{password} ) eq $pass } keys $moders;
}

#
# Post Editing
#

sub tag_killa { # subroutine for stripping HTML tags and supplanting them with corresponding wakabamark
    my $tag_killa = $_[0];
    study $tag_killa; # Prepare string for some extensive regexp.

    $tag_killa =~ s%<br\s?/?>%\n%g;
    while ($tag_killa =~ m%<ul>(.*?)</ul>%s)
    {
        my $replace = $1 || $2;
        my $replace2 = $replace;
        $replace2  =~ s/<li>/\* /g;
        $replace2  =~ s%</li>%\n%g;
        $tag_killa =~ s%<ul>.*?</ul>%${replace2}\n%s;
    }
    while ($tag_killa =~ m%<ol>(.*?)</ol>%s)
    {
        my $replace = $1;
        my $replace2 = $replace;
        my @strings = split (/<\/li>/, $replace2);
        my @new_strings;
        my $count = 1;
        foreach my $entry (@strings)
        {
            $entry =~ s/<li>/$count\. /;
            push (@new_strings, $entry);
            ++$count;
        }
        $replace2 = join ("\n", @new_strings);
        $tag_killa =~ s%<ol>.*?</ol>%${replace2}\n\n%s;
    }

    # bbcode, etc
    $tag_killa =~ s%<a .*?href="(.+?)".*?</a>%$1%g;
    $tag_killa =~ s%<span class="spoiler">(.*?)</span>%\[spoiler\]$1\[/spoiler\]%g;
    $tag_killa =~ s%<em>(.*?)</em>%\[i\]$1\[/i\]%g;
    $tag_killa =~ s%<span class="underline">(.*?)</span>%\[s\]$1\[/s\]%g;
    $tag_killa =~ s%<span class="strike">(.*?)</span>%\[s\]$1\[/s\]%g;
    $tag_killa =~ s%<strong>(.*?)</strong>%\[b\]$1\[/b\]%g;
    $tag_killa =~ s%<sup>(.*?)</sup>%\[sup\]$1\[/sup\]%g;
    $tag_killa =~ s%<sub>(.*?)</sub>%\[sub\]$1\[/sub\]%g;
    $tag_killa =~ s%<span class="redtext">(.*?)</span>%\[buttsex\]$1\[/buttsex\]%g;
    $tag_killa =~ s%<span class="unkfunc">(.*?)</span>%\[quote\]$1\[/quote\]%g;
    $tag_killa =~ s%<img src="(?:.*?)/([^/\.]+)(\.[^\.]+)?" alt="" style="vertical-align: bottom;" />%:$1:%g;

    $tag_killa =~ s%<pre><code>([\s\S]+?)</code></pre>%\[code\]$1\[/code\]%mg; # shit
    $tag_killa =~ s/<.*?>//g;

    $tag_killa;
}

sub make_edit_post_panel {
    my ($admin,$num,$noformat)=@_;
    my @session = check_password($admin,'');
    my @loop;

    my $sth = $dbh->prepare( "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE num=?;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($num) or make_error($$locale{S_SQLFAIL});

    if ( my $row=get_decoded_hashref($sth) ) {
        $$row{noformat} = $noformat ? 1 : undef;
        push @loop, $row;
    }
    $sth->finish() if $sth;

    make_error("Something happened") unless @loop;

    make_http_header();
    print $tpl->edit_post_panel({
        admin    => $admin,
        modclass => $session[1],
        num      => $num,
        loop     => \@loop,
        stylesheets => get_stylesheets(),
        cfg => $cfg,
        locale => $locale
    });
}

sub edit_post {
    my ( $admin,   $num,      $name,    $email,
         $subject, $comment,  $capcode, $killtrip,
         $byadmin, $no_format
    ) = @_;
    my ($sth, $postfix);

    my @session = check_password($admin,'');
    make_error($$locale{S_NOPRIVILEGES}) if( $no_format and $session[1] ne 'admin' );

    my $post=get_post($num) or make_error(sprintf "Post %d doesn't exist",$num);
    my $adminpost  = $capcode ? 1 : undef;
    my $admin_post = $byadmin ? 1 : 0;
    my $ip = get_remote_addr();

    backup_stuff($post) if ($$cfg{ENABLE_POST_BACKUP});

    make_error($$locale{S_UNUSUAL}) if( $name =~/[\n\r]/ );
    make_error($$locale{S_UNUSUAL}) if( $email =~/[\n\r]/ );
    make_error($$locale{S_UNUSUAL}) if( $subject =~/[\n\r]/ );
    make_error($$locale{S_TOOLONG}) if( length($name) > $$cfg{MAX_FIELD_LENGTH} );
    make_error($$locale{S_TOOLONG}) if( length($email) > $$cfg{MAX_FIELD_LENGTH} );
    make_error($$locale{S_TOOLONG}) if( length($subject) > $$cfg{MAX_FIELD_LENGTH} );
    make_error($$locale{S_TOOLONG}) if( length($comment) > $$cfg{MAX_COMMENT_LENGTH} );

    # clean inputs
    $email   = clean_string( decode_string( $email, CHARSET ) );
    $subject = clean_string( decode_string( $subject, CHARSET ) );

    if ( $email =~/sage/i ) { $email = 'sage'; }
    else                     { $email = ''; }

    # process tripcode
    my $trip;
    ( $name, $trip ) = process_leetcode( $name ); # process a l33t tripcode
    ( $name, $trip ) = process_tripcode( $name, $$cfg{TRIPKEY}, SECRET, CHARSET ) unless $trip;

    if (!$killtrip) {
        $trip = $$post{trip} if !$trip;
    } else {
        $trip = '';
    }

    # fix up the email/link
    $email = "mailto:$email" if $email and $email !~ /^$protocol_re:/;

    # fix comment
    $comment =
      format_comment( clean_string( decode_string( $comment, CHARSET) ) )
        unless $no_format;
    $comment.=$postfix;

    $name = make_anonymous( $ip, time() ) unless $name or $trip;

    # finally, update
    $sth = $dbh->prepare(
      "UPDATE "
      . $$cfg{SQL_TABLE}
      . " SET name=?,email=?,trip=?,subject=?,comment=?,adminpost=?,admin_post=? WHERE num=?;")
      or make_error($$locale{S_SQLFAIL}
    );

    $sth->execute(
        $name,$email,$trip,$subject,$comment,$adminpost,$admin_post,$num
    ) or make_error($$locale{S_SQLFAIL});
    $sth->finish;

    log_action( 'editpost', $num, '', $admin );

    # Go to thread
    if( $$post{parent} ) { make_http_forward( get_board_path() . "thread/" . $$post{parent} . ($num?"#$num":"")); }
    elsif( $num )        { make_http_forward( get_board_path() . "thread/" . $num ); }
    else                 { make_http_forward( get_board_path() ); } # shouldn't happen
}

#
# Admin logging
#

sub log_action {
    my ($action,$object,$object2,$admin)=@_;
    my ($time,$sth);

    my @session = check_password($admin, '', 'silent');
    return 0 unless @session;

    $time=time();
    eval {
        $dbh->begin_work();

        $sth=$dbh->prepare("INSERT INTO ".$$cfg{SQL_LOG_TABLE}." VALUES(null,?,?,?,?,?,?,?);") or return $dbh->errstr;
        $sth->execute($session[0],$action,$object,$object2,($$cfg{SELFPATH}),$time,dot_to_dec(get_remote_addr())) or return $dbh->errstr;
        $sth->finish;

        $dbh->commit();
    };
    if ($@) {
        eval { $dbh->rollback() };
        return $$locale{S_SQLFAIL};
    }
}

sub make_view_log_panel {
    my ($admin, $page) = @_;
    my ($row, $sth, @log);

    my @session = check_password($admin, '');
    make_error($$locale{S_NOPRIVILEGES}) if $session[1] ne 'admin';

    $sth = $dbh->prepare(
          "SELECT * FROM "
          . $$cfg{SQL_LOG_TABLE}
          . " ORDER BY num DESC;"
        ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});

    my $emin = ( $page - 1 ) * $$cfg{ENTRIES_PER_LOGPAGE};
    my $emax = $emin + $$cfg{ENTRIES_PER_LOGPAGE};
    my $entcount = 0;

    while($row = get_decoded_hashref($sth)) {
        $entcount++;
        if( $entcount>$emin and $entcount<=$emax ) {
            $$row{rowtype} = @log % 2 + 1;
            $$row{object2} = resolve_reflinks($$row{object2}, $$row{board});
            push @log,$row;
        }
    }

    # make the list of pages
    my $totalCount = int( ( $entcount + ($$cfg{ENTRIES_PER_LOGPAGE} - 1) ) / $$cfg{ENTRIES_PER_LOGPAGE} );
    $totalCount = 1 if ($sth and !$sth->rows);

    my @pages = map +{ page => $_ }, ( 1 .. $totalCount );
    foreach my $p (@pages) {
        $$p{filename} = 
          get_script_name(). "?task=viewlog&amp;section=".$$cfg{SELFPATH}."&amp;page=" . $$p{page};
        if ( $$p{page} == $page ) { $$p{current} = 1 }   # current page, no link
    }

    if( $page <= 0 or $page > $totalCount ) {
        make_error($$locale{S_INVALID_PAGE});
    }

    my ($prevpage,$nextpage);
    $prevpage = $pages[$page-2]{filename} if( $page != 1);
    $nextpage = $pages[$page  ]{filename} if( $page != $totalCount);

    $sth->finish;

    make_http_header();
    print $tpl->staff_log({
        admin => $admin,
        modclass => $session[1],
        log => \@log,
        pages => \@pages,
        prevpage => $prevpage,
        nextpage => $nextpage,
        stylesheets => get_stylesheets(),
        cfg => $cfg,
        locale => $locale
    });
}

sub clear_log {
    my ($admin,$all)=@_;
    my @session = check_password($admin, '');
    my $sth;
    make_error($$locale{S_NOPRIVILEGES}) if $session[1] ne 'admin';

    my $board_path = $$cfg{SELFPATH};
    if (!$all) {
        $sth=$dbh->prepare("DELETE FROM ".$$cfg{SQL_LOG_TABLE}." WHERE board=?;") or make_error($$locale{S_SQLFAIL});
        $sth->bind_param(1, $board_path);
    }
    else {
        $sth=$dbh->prepare("DELETE FROM ".$$cfg{SQL_LOG_TABLE}.";") or make_error($$locale{S_SQLFAIL});
    }
    $sth->execute() or '';
    $sth->finish;
    
    make_http_forward( get_script_name(). "?task=viewlog&amp;section=".$$cfg{SELFPATH} );
}

sub cleanup_log_database()
{
    return unless $$cfg{LOG_EXPIRE};
    my $sth = $dbh->prepare("DELETE FROM " . $$cfg{SQL_LOG_TABLE} . " WHERE time < ?;");
    $sth->execute(time - $$cfg{LOG_EXPIRE});
    $sth->finish();
}

#
# Page creation utils
#

sub expand_filename {
    my ($filename, $force_http) = @_;

    return $filename if ( $filename =~ m!^/! );
    return $filename if ( $filename =~ m!^\w+:! );

    my ($self_path) = $ENV{SCRIPT_NAME} =~ m!^(.*/)[^/]+$!;
    $self_path = 'https://'.$ENV{SERVER_NAME}.$self_path if ($force_http);
    return decode(CHARSET, $self_path) . $$cfg{SELFPATH} . '/' . $filename;
}

sub expand_image_filename {
    my $filename = shift;

    if ( $filename =~ m%^//${pomf_domain}% ) { return $filename; } # is file on an external server?
    else { return expand_filename( clean_path($filename) ); }
}

sub make_http_header {
    my ($not_found) = @_;
    print $query->header(-type=>'text/html', -expires => '-1d',  -status=>'404 Not found', -charset => CHARSET) if ($not_found);
    print $query->header(-type=>'text/html', -expires => '-1d', -charset => CHARSET) if (!$not_found);
}

sub make_rss_header {
    print $query->header(-type=>'application/rss+xml', -charset => CHARSET);
}

sub make_json_header {
    print "Cache-Control: no-cache, no-store, must-revalidate\n";
    print "Expires: Mon, 12 Apr 1997 05:00:00 GMT\n";
    print "Content-Type: application/json\n";
    print "Access-Control-Allow-Origin: *\n";
    print "\n";
}

sub make_error {
    my ($error, $not_found) = @_;

    make_http_header(defined $not_found ? $not_found : undef);

    print $tpl->error({
        error          => $error,
        error_page     => 'Error occurred',
        error_title    => 'Error occurred',
        stylesheets    => get_stylesheets(),
        cfg            => $cfg,
        locale         => $locale
    });

    if (ERRORLOG)    # could print even more data, really.
    {
        open ERRORFILE, '>>' . ERRORLOG;
        print ERRORFILE $error . "\n";
        print ERRORFILE $ENV{HTTP_USER_AGENT} . "\n";
        print ERRORFILE "**\n";
        close ERRORFILE;
    }

    # delete temp files
    eval { next; };
    if ($@) {
        exit(0);
    }
}

sub make_ban {
    my ($title, @bans) = @_;

    make_http_header();
    print $tpl->error({
            bans           => \@bans,
            error_page     => $title,
            error_title    => $title,
            banned         => 1,
            stylesheets    => get_stylesheets(),
            cfg            => $cfg,
            locale         => $locale
    });

    eval { next; };
    if ($@) {
        exit(0);
    }
}

sub get_board_path {
    return "/" . urlenc($$cfg{SELFPATH}) . "/";
}

sub get_script_name {
    # return urlenc($ENV{SCRIPT_NAME});
    return $ENV{SCRIPT_NAME};
}

sub get_secure_script_name {
    return 'https://' . $ENV{SERVER_NAME} . $ENV{SCRIPT_NAME}
      if ($$cfg{USE_SECURE_ADMIN});
    return $ENV{SCRIPT_NAME};
}

sub get_reply_link {
    my ( $reply, $parent, $force_http, $board ) = @_;

    $board =
      ( $board and grep { $_ eq $board } @{$$cfg{BOARDS}} ) ? "/$board/" : "";

    return expand_filename( $board . "thread/" . $parent, $force_http ) . '#' . $reply if ($parent);
    return expand_filename( $board . "thread/" . $reply, $force_http );
}

sub get_page_count {
    my ($total) = @_;
    return int( ( $total + ($$cfg{IMAGES_PER_PAGE}) - 1 ) / $$cfg{IMAGES_PER_PAGE} );
}

sub get_filetypes_hash {
    my $filetypes = $$cfg{FILETYPES};
    $$filetypes{gif} = $$filetypes{jpg} = $$filetypes{jpeg} = $$filetypes{png} = $$filetypes{svg} = $$filetypes{bmp} = 'image';
    $$filetypes{pdf} = 'doc';
    $$filetypes{webm} = $$filetypes{mp4} = 'video';
    return $filetypes;
}

sub get_filetypes {
    my $filetypes = get_filetypes_hash();
    return join ", ", map { uc } sort keys %$filetypes;
}

sub get_filetypes_table {
    my $filetypes = get_filetypes_hash();
    my $filegroups = $$cfg{FILEGROUPS};
    my $filesizes = $$cfg{FILESIZES};
    my @groups = split(' ', $$cfg{GROUPORDER});
    my @rows;
    my $blocks = 0;
    my $output = '<table style="margin:0px;border-collapse:collapse;display:inline-table;">' . "\n<tr>\n\t" . '<td colspan="4">'
        . sprintf($$locale{S_ALLOWED}, get_displaysize(($$cfg{MAX_KB})*1024, $$cfg{DECIMAL_MARK}, 0)) . "</td>\n</tr><tr>\n";
    delete $$filetypes{'jpeg'}; # show only jpg

    foreach my $group (@groups) {
        my @extensions;
        foreach my $ext (keys %$filetypes) {
            if ($$filetypes{$ext} eq $group or $group eq 'other') {
                my $ext_desc = uc($ext);
                $ext_desc .= ' (' . get_displaysize($$filesizes{$ext}*1024, $$cfg{DECIMAL_MARK}, 0) . ')' if ($$filesizes{$ext});
                push(@extensions, $ext_desc);
                delete $$filetypes{$ext};
            }
        }
        if (@extensions) {
            $output .= "\t<td><strong>" . $$filegroups{$group} . ":</strong>&nbsp;</td>\n\t<td>"
                . join(", ", sort(@extensions)) . "&nbsp;&nbsp;</td>\n";
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

sub get_stylesheets {
    my $found=0;
    my @stylesheets=map
    {
        my %sheet;

        $_=lc($_.".css");
        $sheet{filename}=$_;

        ($sheet{title})=m!([^/]+)\.css$!i;
        $sheet{title}=ucfirst $sheet{title};
        $sheet{title}=~s/_/ /g;
        $sheet{title}=~s/ ([a-z])/ \u$1/g;
        $sheet{title}=~s/([a-z])([A-Z])/$1 $2/g;

        \%sheet;
    } ( @{$$cfg{STYLESHEETS}} );

    $stylesheets[0]{default}=1 if(@stylesheets and !$found);

    return \@stylesheets;
}

#
# IP Utils
#

sub get_remote_addr {
    return ($ENV{HTTP_CF_CONNECTING_IP} || $ENV{HTTP_X_REAL_IP} || $ENV{REMOTE_ADDR});
}

sub parse_range {
    my ( $ip, $mask ) = @_;

    if ($ip =~ /:/ or length(pack('w', $ip)) > 5) # IPv6
    {
        if ($mask =~ /:/) { $mask = dot_to_dec($mask); }
        else { $mask = "340282366920938463463374607431768211455"; }
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

#
# Config loaders
#

sub fetch_config
{
    my ($board) = @_;
    my $settings = get_settings('settings');

    unless ($$settings{$board}) {
        $$settings{$board}{NOTFOUND} = 1;
    }

    $$settings{$board}{BOARDS} = [ keys %$settings ];
    $$settings{$board}{SELFPATH} = $board;

    return $$settings{$board};
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
    elsif ( $config =~ /locale_(ru|en|de)/ ) {
        my $lc = $1 ? $1 : 'en'; # fall back to english if shit happens
        $file = "./lib/strings/strings_$lc.pl";
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

#
# Database utils
#

sub init_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . $$cfg{SQL_TABLE} . ";" )
      if ( table_exists($$cfg{SQL_TABLE}) );
    $sth = $dbh->prepare(
        "CREATE TABLE " . $$cfg{SQL_TABLE} . " (" .

        "num " . get_sql_autoincrement() . "," . # Post number, auto-increments
        "parent INTEGER," .     # Parent post for replies in threads. For original posts, must be set to 0 (and not null)
        "timestamp INTEGER," .  # Timestamp in seconds for when the post was created
        "lasthit INTEGER," .    # Last activity in thread. Must be set to the same value for BOTH the original post and all replies!

        "ip TEXT," .            # IP number of poster, in integer form! Stored as text because IPv6 128 bit integers are not always supported.
        "name TEXT," .          # Name of the poster
        "trip TEXT," .          # Tripcode (encoded)
        "email TEXT," .         # Email address
        "subject TEXT," .       # Subject
        "password TEXT," .      # Deletion password (in plaintext)
        "comment TEXT," .       # Comment text, HTML encoded.

        "banned INTEGER," .     # Timestamp when the post was banned
        "autosage INTEGER," .   # Flag to indicate that thread is on bump limit
        "adminpost INTEGER," .  # Post was made by a staff member
        "admin_post INTEGER," . # Post was made by a staff member...
        "locked INTEGER," .     # Thread is locked (applied to parent post only)
        "sticky INTEGER," .     # Thread is sticky (applied to all posts of a thread)
        "location TEXT," .      # Geo::IP information for the IP address if available
        "secure TEXT," .        # Cipher information if posted using SSL connection
        "INDEX parent(parent)" . # table index

        ");"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
}

sub init_files_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . $$cfg{SQL_TABLE_IMG} . ";" )
      if ( table_exists($$cfg{SQL_TABLE_IMG}) );
    $sth = $dbh->prepare(
        "CREATE TABLE " . $$cfg{SQL_TABLE_IMG} . " (" .

        "num " . get_sql_autoincrement() . "," . # Primary key
        "thread INTEGER," .    # Thread ID / parent (num in comments table) of file's post
                               # Reduces queries needed for thread output and thread deletion
        "post INTEGER," .      # Post ID (num in comments table) where file belongs to
        "image TEXT," .        # Image filename with path and extension (IE, src/1081231233721.jpg)
        "size INTEGER," .      # File size in bytes
        "md5 TEXT," .          # md5 sum in hex
        "width INTEGER," .     # Width of image in pixels
        "height INTEGER," .    # Height of image in pixels
        "thumbnail TEXT," .    # Thumbnail filename with path and extension
        "tn_width INTEGER," .  # Thumbnail width in pixels
        "tn_height INTEGER," . # Thumbnail height in pixels
        "uploadname TEXT," .   # Original filename supplied by the user agent
        "info TEXT," .         # Short file information displayed in the post
        "info_all TEXT," .      # Full file information displayed in the tooltip
        "INDEX post(post)," .
        "INDEX thread(thread)" .

        ");"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
}

sub init_admin_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . $$cfg{SQL_ADMIN_TABLE} . ";" )
      if ( table_exists($$cfg{SQL_ADMIN_TABLE}) );
    $sth = $dbh->prepare(
            "CREATE TABLE "
          . $$cfg{SQL_ADMIN_TABLE} . " ("
          .

          "num "
          . get_sql_autoincrement() . ","
          .                    # Entry number, auto-increments
          "type TEXT," .       # Type of entry (ipban, wordban, etc)
          "comment TEXT," .    # Comment for the entry
          "ival1 TEXT," .      # Integer value 1 (usually IP)
          "ival2 TEXT," .      # Integer value 2 (usually netmask)
          "sval1 TEXT," .       # String value 1
          "date INTEGER," .        # Human-readable form of date         
          "expires INTEGER" .         

          ");"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
}

sub init_backup_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . $$cfg{SQL_BACKUP_TABLE} . ";" )
      if ( table_exists($$cfg{SQL_BACKUP_TABLE}) );
    $sth = $dbh->prepare(
        "CREATE TABLE " . $$cfg{SQL_BACKUP_TABLE} . " (" .

        "num " . get_sql_autoincrement() . "," . # Auto-increment
        "postnum INTEGER," .    # Post num
        "board_name VARCHAR(25) NOT NULL,". # Board name
        "parent INTEGER," .     # Parent post for replies in threads. For original posts, must be set to 0 (and not null)
        "timestamp INTEGER," .  # Timestamp in seconds for when the post was created
        "lasthit INTEGER," .    # Last activity in thread. Must be set to the same value for BOTH the original post and all replies!

        "ip TEXT," .            # IP number of poster, in integer form! Stored as text because IPv6 128 bit integers are not always supported.
        "name TEXT," .          # Name of the poster
        "trip TEXT," .          # Tripcode (encoded)
        "email TEXT," .         # Email address
        "subject TEXT," .       # Subject
        "password TEXT," .      # Deletion password (in plaintext)
        "comment TEXT," .       # Comment text, HTML encoded.

        "banned INTEGER," .     # Timestamp when the post was banned
        "autosage INTEGER," .   # Flag to indicate that thread is on bump limit
        "adminpost INTEGER," .  # Post was made by a staff member
        "admin_post INTEGER," . # Post was made by a staff member...
        "locked INTEGER," .     # Thread is locked (applied to parent post only)
        "sticky INTEGER," .     # Thread is sticky (applied to all posts of a thread)
        "location TEXT," .      # Geo::IP information for the IP address if available
        "secure TEXT," .        # Cipher information if posted using SSL connection
        "timestampofarchival INTEGER,". # When was this backed up?
        "INDEX parent(parent)" . # table index

        ");"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
}

sub init_backup_files_database {
    my ($sth);

    $sth = $dbh->do( "DROP TABLE " . $$cfg{SQL_BACKUP_IMG_TABLE} . ";" )
      if ( table_exists($$cfg{SQL_BACKUP_IMG_TABLE}) );
    $sth = $dbh->prepare(
        "CREATE TABLE " . $$cfg{SQL_BACKUP_IMG_TABLE} . " (" .

        "num " . get_sql_autoincrement() . "," . # Primary key
        "imgnum INTEGER," .
        "board_name VARCHAR(25) NOT NULL,". # Board name
        "thread INTEGER," .    # Thread ID / parent (num in comments table) of file's post
                               # Reduces queries needed for thread output and thread deletion
        "post INTEGER," .      # Post ID (num in comments table) where file belongs to
        "image TEXT," .        # Image filename with path and extension (IE, src/1081231233721.jpg)
        "size INTEGER," .      # File size in bytes
        "md5 TEXT," .          # md5 sum in hex
        "width INTEGER," .     # Width of image in pixels
        "height INTEGER," .    # Height of image in pixels
        "thumbnail TEXT," .    # Thumbnail filename with path and extension
        "tn_width INTEGER," .  # Thumbnail width in pixels
        "tn_height INTEGER," . # Thumbnail height in pixels
        "uploadname TEXT," .   # Original filename supplied by the user agent
        "info TEXT," .         # Short file information displayed in the post
        "info_all TEXT," .      # Full file information displayed in the tooltip
        "timestampofarchival INTEGER,". # When was this backed up?
        "INDEX post(post)," .
        "INDEX thread(thread)" .

        ");"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
}

sub init_log_database {
    my ($sth);
    
    $sth = $dbh->do("DROP TABLE ".$$cfg{SQL_LOG_TABLE}.";") if(table_exists($$cfg{SQL_LOG_TABLE}));
    $sth = $dbh->prepare(
        "CREATE TABLE ".$$cfg{SQL_LOG_TABLE}." (".
        "num ".get_sql_autoincrement().",".
        "user TEXT,".
        "action TEXT,".
        "object TEXT,".
        "object2 TEXT,".
        "board TEXT,".
        "time INTEGER,".
        "ip TEXT".  
    ");"
    ) or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
}

sub repair_database {
    my ( $sth, $row, @threads, $thread );

    $sth = $dbh->prepare( "SELECT * FROM " . $$cfg{SQL_TABLE} . " WHERE parent=0;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});

    while ( $row = $sth->fetchrow_hashref() ) { push( @threads, $row ); }

    # fix lasthit
    my ($upd);

    $upd = $dbh->prepare(
        "UPDATE " . $$cfg{SQL_TABLE} . " SET lasthit=? WHERE parent=?;" )
      or make_error($$locale{S_SQLFAIL});
    $upd->execute( $$_{lasthit}, $$_{num} )
        or make_error( $$locale{S_SQLFAIL} . " " . $dbh->errstr()) for (@threads);
}

sub get_sql_autoincrement {
    return 'INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT'
      if ( SQL_DBI_SOURCE =~ /^DBI:mysql:/i );
    return 'INTEGER PRIMARY KEY' if ( SQL_DBI_SOURCE =~ /^DBI:SQLite:/i );
    return 'INTEGER PRIMARY KEY' if ( SQL_DBI_SOURCE =~ /^DBI:SQLite2:/i );

    make_error($$locale{S_SQLCONF});  # maybe there should be a sane default case instead?
}

sub get_sql_lastinsertid {
    return 'LAST_INSERT_ID()' if(SQL_DBI_SOURCE=~/^DBI:mysql:/i);
    return 'last_insert_rowid()' if(SQL_DBI_SOURCE=~/^DBI:SQLite:/i);
    return 'last_insert_rowid()' if(SQL_DBI_SOURCE=~/^DBI:SQLite2:/i);

    make_error($$locale{S_SQLCONF});
}

sub count_maxreplies {
    my ($row, $images)=@_;

    my $max_replies = $$cfg{REPLIES_PER_THREAD};
    # in case of a locked thread use custom number of replies
    if ( $$row{locked} ) {
        $max_replies = $$cfg{REPLIES_PER_LOCKED_THREAD};
    }

    # in case of a sticky thread, use custom number of replies
    # NOTE: has priority over locked thread
    if ( $$row{sticky} ) {
        $max_replies = $$cfg{REPLIES_PER_STICKY_THREAD};
    }

    return $max_replies;
}

sub count_threads {
    my ($sth);

    $sth = $dbh->prepare(
          "SELECT count(`num`) FROM "
          . $$cfg{SQL_TABLE}
          . " WHERE parent=0;"
        )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute() or make_error($$locale{S_SQLFAIL});
    my $return = ($sth->fetchrow_array())[0];
    $sth->finish;

    return $return;
}

sub count_posts {
    my ($parent) = @_;
    my ($sth, $count, $size, $files, $row);

    if ($parent) {
        $sth = $dbh->prepare(
              "SELECT count(`num`) FROM "
              . $$cfg{SQL_TABLE}
              . " WHERE parent=? or num=?;"
            ) or make_error($$locale{S_SQLFAIL});
        $sth->bind_param(1, $parent);
        $sth->bind_param(2, $parent);
    } else {
        $sth = $dbh->prepare(
              "SELECT count(`num`) FROM "
              . $$cfg{SQL_TABLE} . ";"
            ) or make_error($$locale{S_SQLFAIL});
    }
    $sth->execute() or '';
    $count = ($sth->fetchrow_array())[0];

    if ($parent) {
        $sth = $dbh->prepare(
              "SELECT size, image FROM "
              . $$cfg{SQL_TABLE_IMG}
              . " WHERE thread=?;"
            ) or make_error($$locale{S_SQLFAIL});
        $sth->bind_param( 1, $parent );
    } else {
        $sth = $dbh->prepare(
              "SELECT size, image FROM "
              . $$cfg{SQL_TABLE_IMG} . ";"
            ) or make_error($$locale{S_SQLFAIL});        
    }
    $sth->execute() or '';
    while ( $row = $sth->fetchrow_arrayref() )
    {
        unless ( $$row[1] =~ m%^//${pomf_domain}% ) # file is on an external server
        {
            $size += $$row[0];
        }
        $files += 1;
    }
    $sth->finish;

    return ($count, $size, $files);
}

sub trim_database {
    my ( $sth, $row, $order );

    if   ( $$cfg{TRIM_METHOD} == 0 ) { $order = 'num ASC'; }
    else                             { $order = 'lasthit ASC'; }

    if ($$cfg{MAX_AGE})            # needs testing
    {
        my $mintime = time() - ($$cfg{MAX_AGE}) * 3600;

        $sth =
          $dbh->prepare( "SELECT * FROM "
              . $$cfg{SQL_TABLE}
              . " WHERE parent=0 AND timestamp<=? AND (sticky=0 OR sticky IS NULL);"
          ) or make_error($$locale{S_SQLFAIL});
        $sth->execute($mintime) or make_error($$locale{S_SQLFAIL});

        while ( $row = $sth->fetchrow_hashref() ) {
            delete_post( $$row{num}, "", 0, 0 );
        }
    }

    my $threads = count_threads();
    my ( $posts, $size ) = count_posts();
    my $max_threads = ( $$cfg{MAX_THREADS}         or $threads );
    my $max_posts   = ( $$cfg{MAX_POSTS}           or $posts );
    my $max_size    = ( $$cfg{MAX_MEGABYTES} * 1024 * 1024 or $size );

    while ($threads > $max_threads
        or $posts > $max_posts
        or $size > $max_size )
    {
        $sth =
          $dbh->prepare( "SELECT * FROM "
              . $$cfg{SQL_TABLE}
              . " WHERE parent=0 AND (sticky=0 OR sticky IS NULL) ORDER BY $order LIMIT 1;"
          ) or make_error($$locale{S_SQLFAIL});
        $sth->execute() or make_error($$locale{S_SQLFAIL});

        if ( $row = $sth->fetchrow_hashref() ) {
            my ( $threadposts, $threadsize ) = count_posts( $$row{num} );

            delete_post( $$row{num}, "", 0, 0 );

            $threads--;
            $posts -= $threadposts;
            $size  -= $threadsize;
        }
        else { last; }    # shouldn't happen
    }
    $sth->finish() if($sth);
}

sub table_exists {
    my ($table)=@_;
    my ($sth);

    return 0 unless($sth=$dbh->prepare("SELECT * FROM ".$table." LIMIT 1;"));
    return 0 unless($sth->execute());
    $sth->finish;
    return 1;
}

sub thread_exists {
    my ($thread) = @_;
    my ($sth);

    $sth = $dbh->prepare(
        "SELECT count(`num`) FROM " . $$cfg{SQL_TABLE} . " WHERE num=? AND parent=0;" )
      or make_error($$locale{S_SQLFAIL});
    $sth->execute($thread) or make_error($$locale{S_SQLFAIL});
    my $ret = ( $sth->fetchrow_array() )[0];
    $sth->finish;

    return $ret;
}

sub get_decoded_hashref {
    my ($sth) = @_;

    my $row = $sth->fetchrow_hashref();

    if ( $row and $has_encode ) {
            # don't blame me for this shit, I got this from perlunicode.
        do { defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$_} } for ( keys %$row );
    }

    return $row;
}

sub get_decoded_arrayref {
    my ($sth) = @_;

    my $row = $sth->fetchrow_arrayref();

    if ( $row and $has_encode ) {
        # don't blame me for this shit, I got this from perlunicode.
        defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;
    }

    return $row;
}

sub get_fcgicounter {
    return $fcgi_counter;
}

"sprölö bölö";
