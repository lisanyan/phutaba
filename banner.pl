#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;
use CGI;

my $query=new CGI;
my $board=($query->param("board") or 'default');
my $etc = $query->param("qb");

my ($bannerdir, @files);

$bannerdir = 'img/ufoporno/';
$board = 'oe' if ($board eq 'ö'); #hurr

$bannerdir = 'qb/img2/' if($etc eq 'nya');

# check for board-specific subdirectory. files will be read from that directory instead.
if ($etc ne 'nya') {
	while (glob "${bannerdir}*") # dotfiles are ignored by default
	{
		if (-d $_)
		{
			$_ =~ m!([^/\\]+)$!;
			$bannerdir .= $1 . '/' if ($1 eq $board);
		}
	}
}

# now add all files from that directory
while (glob "${bannerdir}*")
{
	push(@files, $_) if (!-d $_);
}

if (@files)
{
	make_redirect('/' . $files[rand @files]);
}
else
{
	make_notfound();
}



sub make_redirect($)
{
	my ($location) = @_;
	print "Status: 302 Found\n";
	print "Location: $location\n";
	print "Content-Type: text/html\n";
	print "\n";
	print '<html><body><a href="' . $location . '">' . $location . '</a></body></html>';
}

sub make_notfound()
{
	print "Status: 404 Not Found\n";
	print "Content-Type: text/html\n";
	print "\n";
	print "<html><body><p>Not Found</p></body></html>";
}
