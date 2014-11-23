# wakautils.pl v8.12

use strict;

use Time::Local;
use Socket;
#use Locale::Country;
#use Locale::Codes::Country;
use DateTime;
use Image::ExifTool;
use Geo::IP;
use Net::IP qw(:PROC); # IPv6 conversions

#use Net::Abuse::Utils qw( :all ); #TODO: remove (get_rdns get_ipwi_contacts get_as_description get_asn_info)


# add EU to the country code list
#Locale::Codes::Country::add_country("EU", "European Union");
my $has_md5 = 0;
eval 'use Digest::MD5 qw(md5)';
$has_md5 = 1 unless $@;

my $has_encode = 0;
eval 'use Encode qw(decode)';
$has_encode = 1 unless $@;

use constant MAX_UNICODE => 1114111;

#
# HTML utilities
#

my $protocol_re = qr{(?:http://|https://|ftp://|mailto:|news:|irc:)};
my $url_re =
qr{(${protocol_re}[^\s<>()"]*?(?:\([^\s<>()"]*?\)[^\s<>()"]*?)*)((?:\s|<|>|"|\.||\]|!|\?|,|&#44;|&quot;)*(?:[\s<>()"]|$))};

sub get_meta {
	my ($file, @tagList) = @_;
	my (%data, $exifData);
	my $exifTool = new Image::ExifTool;
	@tagList = qw(-FilePermissions -ExifToolVersion -Directory -FileName -Warning -FileModifyDate) unless @tagList;	
	$exifData = $exifTool->ImageInfo($file, @tagList) if $file;
	foreach (keys %$exifData) {
		my $val = $$exifData{$_};
			if (ref $val eq 'ARRAY') {
				$val = join(', ', @$val);
			} elsif (ref $val eq 'SCALAR') {
				my $len = length($$val);
				$val = "(Binary data; $len bytes)";
			}
			#$data{$_} = encode_entities(decode('utf8', $val));
			$data{$_} = clean_string(decode_string($val, CHARSET));
	}

	return \%data;
}

sub get_meta_markup {
	my ($file) = @_;
	my ($markup, $info, $exifData, @metaOptions);
	my %options = (	"FileSize" => "Dateigr&ouml;&szlig;e",
			"FileType" => "Dateityp",
			"ImageSize" => "Aufl&ouml;sung", 
			"ModifyDate" => "&Auml;nderungdatum", 
			"Comment" => "Kommentar", 
			"Comment-xxx" => "Kommentar", 
			"CreatorTool" => "Erstellungstool", 
			"Software" => "Software", 
			"MIMEType" => "MIME", 
			"Producer" => "Software", 
			"Creator" => "Generator", 
			"Author" => "Autor", 
			"Subject" => "Betreff", 
			"PDFVersion" => "PDF-Version", 
			"PageCount" => "Seiten", 
			"Title" => "Titel", 
			"Duration" => "L&auml;nge", 
			"Artist" => "Interpret", 
			"AudioBitrate" => "Bitrate", 
			"ChannelMode" => "Kanalmodus", 
			"Compression" => "Kompressionsverfahren", 
			"EncodingProcess" => "Encoding-Verfahren",
			"FrameCount" => "Frames",
			"Vendor" => "Library-Hersteller",
			"Album" => "Album",
			"Genre" => "Genre",
			"Composer" => "Komponist",
			"Model" => "Modell",
			"Maker" => "Hersteller",
			"OwnerName" => "Besitzer",
			"CanonModelID" => "Canon-eigene Modellnummer",
			"UserComment" => "Kommentar",
			"GPSPosition" => "Position",
	);
	foreach (keys %options) {
		push(@metaOptions, $_);
	}
	$exifData = get_meta($file, @metaOptions);
	foreach (keys %$exifData) {
		if (defined($options{$_}) and $$exifData{$_} ne "") {
			$markup = $markup . "<strong>$options{$_}</strong>: $$exifData{$_}<br />";
			if ($_ eq "PageCount") {
				if ($$exifData{$_} eq 1) {
					$info = "1 Seite";
				} else {
					$info = $$exifData{$_} . " Seiten";
				}
			}
			if ($_ eq "Duration") {
				$info = $$exifData{$_};
				$info =~ s/ \(approx\)$//;
				$info =~ s/^0:0?//; # 0:01:45 -> 1:45 / 0:12:37 -> 12:37

				# round and format seconds to mm:ss if only seconds are returned
				if ($info =~ /(\d+)\.(\d\d) s/) {
					my $sec = $1;
					if ($2 >= 50) { $sec++ }
					my $min = int($sec / 60);
					$sec = $sec - $min * 60;
					$sec = sprintf("%02d", $sec);
					$info = $min . ':' . $sec;
				}
			}
		}
	}

	return ($info, $markup);
}	

sub protocol_regexp { return $protocol_re }

sub url_regexp { return $url_re }

sub get_geolocation($) {
	my ($ip) = @_;
	my $loc = "unk";

	my ($country_code, $country_name, $region_name, $city);
	my ($gi, $city_record);
	my $path = "/usr/local/share/GeoIP/";

	# IPv6 only works with CAPI
	if ($ip =~ /:/ and Geo::IP->api eq 'CAPI') {
		eval '$gi = Geo::IP->open($path . "GeoLiteCityv6.dat")';
		unless ($@ or !$gi) {
			$gi->set_charset(&GEOIP_CHARSET_UTF8);
			$city_record = $gi->record_by_addr_v6($ip);
		} else { # fall back to country if city is not installed
			eval '$gi = Geo::IP->open($path . "GeoIPv6.dat")';
			$loc = $gi->country_code_by_addr_v6($ip) unless ($@ or !$gi);
		}
	}

	# IPv4
	if ($ip !~ /:/ and $ip =~ /\./) {
		eval '$gi = Geo::IP->open($path . "GeoLiteCity.dat")';
		unless ($@ or !$gi) {
			$gi->set_charset(&GEOIP_CHARSET_UTF8);
			$city_record = $gi->record_by_addr($ip);
		} else { # fall back to country if city is not installed
			eval '$gi = Geo::IP->open($path . "GeoIP.dat")';
			$loc = $gi->country_code_by_addr($ip) unless ($@ or !$gi);
		}
	}

	if ($city_record) {
		$loc          = $city_record->country_code;
		$country_name = $city_record->country_name;
		$region_name  = $city_record->region_name;
		$city         = $city_record->city;
	}

	return ($city, $region_name, $country_name, $loc);
}

sub use_captcha($$) {
	my ($always_on, $location) = @_;
	my @allowed = qw(DE NO CH AT LI BE LU DK NL);

	return 1 if ($always_on eq 1);

	foreach my $country (@allowed) {
		return 0 if ($country eq $location);
	}

	return 1;
}

sub get_as_info($) {
	my ($ip) = @_;
	my ($gi, $as_num, $as_info);
	my $path = "/usr/local/share/GeoIP/";

	# IPv6 only works with CAPI
	if ($ip =~ /:/ and Geo::IP->api eq 'CAPI') {
		eval '$gi = Geo::IP->open($path . "GeoIPASNumv6.dat");';
		$as_info = $gi->name_by_addr_v6($ip) unless ($@ or !$gi);
	}

	# IPv4
	if ($ip !~ /:/ and $ip =~ /\./) {
		eval '$gi = Geo::IP->open($path . "GeoIPASNum.dat");';
		$as_info = $gi->name_by_addr($ip) unless ($@ or !$gi);
	}

	$as_info =~ /^AS(\d+) /;
	$as_num = $1;
	return ($as_num, $as_info);
}

sub count_lines($) {
	my ($str) = @_;
	my $count = () = $str =~ m!<br />!g;
	return $count;
}

sub abbreviate_html {
    my ( $html, $max_lines, $approx_len ) = @_;
    my ( $lines, $chars, @stack, $visible, $done, $abbrev );
    $lines = 0;
	$visible = 0;
	$done = 0;
	$abbrev = undef;
    return undef unless ($max_lines);

    while ( $html =~ m!(?:([^<]+)|<(/?)(\w+).*?(/?)>)!g ) {
        my ( $text, $closing, $tag, $implicit ) = ( $1, $2, $3, $4 );
        $tag = lc($tag) if defined;
        if ($text) { $chars += length $text; }
        else {
            push @stack, $tag if ( !$closing and !$implicit );
            pop @stack if ($closing);

            if (
                ( $closing or $implicit )
                and (  $tag eq "p"
                    or $tag eq "blockquote"
                    or $tag eq "pre"
                    or $tag eq "li"
                    or $tag eq "ol"
                    or $tag eq "ul"
                    or $tag eq "br" )
              )
            {
                $lines += int( $chars / $approx_len ) + 1;
                $lines++ if ( $tag eq "p" or $tag eq "blockquote" );
                $chars = 0;
            }

            if ( $lines >= $max_lines and !$done ) {
				$done = 1;
				$visible = $lines;

                # check if there's anything left other than end-tags
                unless (( substr $html, pos $html ) =~ m!^(?:\s*</\w+>)*\s*$!s) {
					$abbrev = substr $html, 0, pos $html;
					while ( my $tag = pop @stack ) { $abbrev .= "</$tag>" }
				}
            }
        }
    }

    return ($abbrev, $lines-$visible);
}

sub sanitize_html {
    my ( $html, %tags ) = @_;
    my ( @stack, $clean );
    my $entity_re = qr/&(?!\#[0-9]+;|\#x[0-9a-fA-F]+;|amp;|lt;|gt;)/;

    while ( $html =~ /(?:([^<]+)|<([^<>]*)>|(<))/sg ) {
        my ( $text, $tag, $lt ) = ( $1, $2, $3 );

        if ($lt) {
            $clean .= "&lt;";
        }
        elsif ($text) {
            $text =~ s/$entity_re/&amp;/g;
            $text =~ s/>/&gt;/g;
            $clean .= $text;
        }
        else {
            if ( $tag =~
                m!^\s*(/?)\s*([a-z0-9_:\-\.]+)(?:\s+(.*?)|)\s*(/?)\s*$!si )
            {
                my ( $closing, $name, $args, $implicit ) =
                  ( $1, lc($2), $3, $4 );

                if ( $tags{$name} ) {
                    if ($closing) {
                        if ( grep { $_ eq $name } @stack ) {
                            my $entry;

                            do {
                                $entry = pop @stack;
                                $clean .= "</$entry>";
                            } until $entry eq $name;
                        }
                    }
                    else {
                        my %args;

                        $args =~ s/\s/ /sg;

                        while ( $args =~
/([a-z0-9_:\-\.]+)(?:\s*=\s*(?:'([^']*?)'|"([^"]*?)"|['"]?([^'" ]*))|)/gi
                          )
                        {
                            my ( $arg, $value ) = (
                                lc($1), defined($2) ? $2 : defined($3) ? $3 : $4
                            );
                            $value = $arg unless defined($value);

                            my $type = $tags{$name}{args}{$arg};

                            if ($type) {
                                my $passes = 1;

                                if ( $type =~ /url/i ) {
                                    $passes = 0
                                      unless $value =~
                                          /(?:^${protocol_re}|^[^:]+$)/;
                                }
                                if ( $type =~ /number/i ) {
                                    $passes = 0 unless $value =~ /^[0-9]+$/;
                                }

                                if ($passes) {
                                    $value =~ s/$entity_re/&amp;/g;
                                    $args{$arg} = $value;
                                }
                            }
                        }

                        $args{$_} = $tags{$name}{forced}{$_}
                          for ( keys %{ $tags{$name}{forced} } )
                          ;    # override forced arguments

                        my $cleanargs = join " ", map {
                            my $value = $args{$_};
                            $value =~ s/'/%27/g;
                            "$_='$value'";
                        } keys %args;

                        $implicit = "/" if ( $tags{$name}{empty} );

                        push @stack, $name unless $implicit;

                        $clean .= "<$name";
                        $clean .= " $cleanargs" if $cleanargs;

                        #$clean.=" $implicit" if $implicit;
                        $clean .= ">";
                        $clean .= "</$name>" if $implicit;
                    }
                }
            }
        }
    }

    my $entry;
    while ( $entry = pop @stack ) { $clean .= "</$entry>" }

    return $clean;
}

sub describe_allowed {
    my (%tags) = @_;

    return join ", ", map {
        $_
          . ( $tags{$_}{args}
            ? " (" . ( join ", ", sort keys %{ $tags{$_}{args} } ) . ")"
            : "" )
    } sort keys %tags;
}

sub do_bbcode {
	my ($text, $handler) = @_;
	my ($output, @opentags);

	my %html = (
		'i'         => ['<em>', '</em>'],
		'b'         => ['<strong>', '</strong>'],
		'u'         => ['<u>', '</u>'],
		's'         => ['<s>', '</s>'],
		'code'      => ['<pre>', '</pre>'],
		'spoiler'   => ['<span class="spoiler">', '</span>'],
		'quote'     => ['<blockquote class="unkfunc">', '</blockquote>']
	);

	my @bbtags = keys %html;

	# what if wakabamark was disabled in the config?
	return do_wakabamark($text, $handler) if (!detect_bbcode($text, @bbtags));

	my @lines = split /(?:\r\n|\n|\r)/,$text;
	my $findtags = join '|',@bbtags;

	while (@lines)
	{

		# do not allow more than one consecutive empty line
		while ( $lines[0] =~ m/^\s*$/ and $lines[1] =~ m/^\s*$/ ) { shift @lines; }

		# check if the line begins with a quote (>) and we are not already in a quote or code section
		if ( $lines[0] =~ m/^&gt;/ and !grep {$_ eq 'quote' or $_ eq 'code'} @opentags )
		{
			$output .= @{$html{'quote'}}[0];
			push( @opentags, 'quote' );
		}

		# match bb-tags in the current line
		while ( $lines[0] =~ m!(.*?)\[(/?)($findtags)\]|(.+)$!sgi )
		{
			# $1 matches the text before a []-tag
			# $4 matches the text after the last []-tag in one line
			my ( $textpart, $closing, $tag, $textend ) = ( $1, $2, $3, $4 );
			my $insert;    # contains [bbtag] which will be replaced by <html-equiv>
			my $closetags; # used to close all open tags when a [code]-section begins

			# convert links and simple wakaba markup if not inside [code]
			if ( $opentags[$#opentags] ne 'code' )
			{
				$textpart = do_spans( $handler, $textpart );
			}

			# if the tag is unknown or not properly nested, it will be added back to the output
			$insert = '[' . $closing . $tag . ']' if ( $tag );
			$closetags = '';

			if ( grep {$_ eq $tag} @bbtags ) # check for a known tag
			{
				if ( $closing )
				{ # close the tag and pop it from the stack if it was opened last
					if ( $opentags[$#opentags] eq $tag )
					{
						pop( @opentags );
						$insert = @{$html{$tag}}[1];
					}
				}
				else
				{ # open the tag if it is not already open and put it on the stack
					if ( !grep {$_ eq $tag} @opentags )
					{
						# close all open tags on [code] and open <code>
						if ( $tag eq 'code' )
						{
							while ( my $otag = pop @opentags ) { $closetags .= @{$html{$otag}}[1]; }
						}

						# ignore any other tag if [code] is open
						if ( $opentags[$#opentags] ne 'code' )
						{
							push( @opentags, $tag );
							$insert = @{$html{$tag}}[0];
						}
					}
				}
			}

			# convert links and simple wakaba markup if not inside [code]
			if ( $opentags[$#opentags] ne 'code' )
			{
				$textend = do_spans( $handler, $textend );
			}

			$output .= $textpart . $closetags . $insert . $textend;
		}

		shift @lines;

		# peek into the next line and if it does not start with a quote anymore:
		# close everything that was opened inside the quote and finally close the quote itself
		if ( $lines[0] !~ m/^&gt;/ and grep {$_ eq 'quote'} @opentags )
		{
			while ( my $otag = pop @opentags )
			{
				$output .= @{$html{$otag}}[1];
				last if ( $otag eq 'quote' );
			}
		}

		# processing of the current line is done. insert a break if not at the beginning or end of the comment.
		# and if not at the end of a </blockquote> because it already breaks the line.
		$output .= '<br />' if ($output and @lines and $output !~ /<\/blockquote>$/);
		$output .= ' ' if ($output =~ /<\/blockquote>$/);
	}

	# close any open tags
	while ( my $otag = pop @opentags )
	{
		$output .= @{$html{$otag}}[1];
	}

	return $output;
}

sub detect_bbcode($@)
{
	my ( $text, @bbtags ) = @_;
	my $findtags = join '|',@bbtags;
	return 1 if ( $text =~ m/\[($findtags)\]/ );
	return 0;
}

sub do_wakabamark($;$$) {
    my ($text, $handler, $simplify) = @_;
    my $res;

    my @lines = split /(?:\r\n|\n|\r)/, $text;

    while ( defined( $_ = $lines[0] ) ) {
        if (/^\s*$/) {		# handle empty lines
			$res .= "<br />" if ($res); # skip empty lines at the beginning of the comment

			# do not allow more than one consecutive empty line
			while (@lines and $lines[0] =~ /^\s*$/ and $lines[1] =~ /^\s*$/) { shift @lines; }

			shift @lines;
		}
        elsif (/^(1\.|[\*\+\-]) /)        # lists
        {
            my ( $tag, $re, $skip, $html );

            if   ( $1 eq "1." ) { $tag = "ol"; $re = qr/[0-9]+\./; $skip = 1; }
            else                { $tag = "ul"; $re = qr/\Q$1\E/;   $skip = 0; }

            while ( $lines[0] =~ /^($re)(?: |\t)(.*)/ ) {
                my $spaces = ( length $1 ) + 1;
                my $item   = "$2\n";
                shift @lines;

                while ( $lines[0] =~ /^(?: {1,$spaces}|\t)(.*)/ ) {
                    $item .= "$1\n";
                    shift @lines;
                }
                $html .= "<li>" . do_wakabamark( $item, $handler, 1 ) . "</li>";

                if ($skip) {
                    while ( @lines and $lines[0] =~ /^\s*$/ ) { shift @lines; }
                }    # skip empty lines
            }
            $res .= "<$tag>$html</$tag>";
        }
        elsif (/^(?:    |\t)/)    # code sections
        {
            my @code;
            while ( $lines[0] =~ /^(?:    |\t)(.*)/ ) {
                push @code, $1;
                shift @lines;
            }
            $res .= "<pre><code>" . ( join "<br />", @code ) . "</code></pre>";
        }
        elsif (/^&gt;/)           # quoted sections
        {
            my @quote;
            while ( $lines[0] =~ /^(&gt;.*)/ ) {
                push @quote, $1;
                shift @lines;
            }
            $res .=
              '<blockquote class="unkfunc">' . do_spans( $handler, @quote ) . "</blockquote>";

            #while($lines[0]=~/^&gt;(.*)/) { push @quote,$1; shift @lines; }
            #$res.="<blockquote>".do_blocks($handler,@quote)."</blockquote>";
        }
        else    # normal paragraph
        {
            my @text;
            while ( $lines[0] !~ /^(?:\s*$|1\. |[\*\+\-] |&gt;|    |\t)/ ) {
                push @text, shift @lines;
            }
            if ( !defined( $lines[0] ) and $simplify ) {
                $res .= do_spans( $handler, @text );
            }
            else { $res .= do_spans( $handler, @text ) . "<br />" }
        }
        $simplify = 0;
    }

    return $res;
}

sub do_spans {
    my $handler = shift;
    return join "<br />", map {
        my $line = $_;
        my @hidden;
		my %smilies = (
			'trollface'   => '/img/trollface.png',
			'zahngrinsen' => '/img/zahngrinsen.png',
			'eisfee'      => '/img/eisfee.gif',
			'fffuuuuu'    => '/img/fu.png',
			'fu'          => '/img/fu.png',
			'awesome'     => '/img/awesome.png',
			'\153\165\150\154\147\145\163\151\143\150\164' => '/img/schreikopf.png',
			'\120\105\116\111\123'     => '/img/blau.png',
			'\126\101\107\111\116\101' => '/img/rot.png',			
			'\150\145\170\145'         => '/img/marisa.png'
		);

        # do h1
        $line =~
s{ (?<![0-9a-zA-Z\*_\x80-\x9f\xe0-\xfc]) (--) (?![<>\s\*_]) ([^<>]+?) (?<![<>\s\*_\x80-\x9f\xe0-\xfc]) \1 (?![0-9a-zA-Z\*_]) }{<h1>$2</h1>}gx;

        # hide <code> sections
        $line =~
s{ (?<![\x80-\x9f\xe0-\xfc]) (`+) ([^<>]+?) (?<![\x80-\x9f\xe0-\xfc]) \1}{push @hidden,"<code>$2</code>"; "<!--$#hidden-->"}sgex;

        # make URLs into links and hide them
        $line =~
s{$url_re}{push @hidden,"<a href=\"$1\" rel=\"nofollow\">$1\</a>"; "<!--$#hidden-->$2"}sge;

        # do <strong>
        $line =~
s{ (?<![0-9a-zA-Z\*_\x80-\x9f\xe0-\xfc]) (\*\*|__) (?![<>\s\*_]) ([^<>]+?) (?<![<>\s\*_\x80-\x9f\xe0-\xfc]) \1 (?![0-9a-zA-Z\*_]) }{<strong>$2</strong>}gx;

        # do <em>
        $line =~
s{ (?<![0-9a-zA-Z\*_\x80-\x9f\xe0-\xfc]) (\*|_) (?![<>\s\*_]) ([^<>]+?) (?<![<>\s\*_\x80-\x9f\xe0-\xfc]) \1 (?![0-9a-zA-Z\*_]) }{<em>$2</em>}gx;

        # do <span class="spoiler">
        $line =~
s{ (?<![0-9a-zA-Z\*_\x80-\x9f\xe0-\xfc]) (~~) (?![<>\s\*_]) ([^<>]+?) (?<![<>\s\*_\x80-\x9f\xe0-\xfc]) \1 (?![0-9a-zA-Z\*_]) }{<span class="spoiler">$2</span>}gx;

        # do the smilies
		foreach my $smiley (keys %smilies) {
			$line =~
s{ (?<![0-9a-zA-Z\*_\x80-\x9f\xe0-\xfc]) (\:$smiley\:) (?![0-9a-zA-Z\*_]) }{<img src="$smilies{$smiley}" alt="" style="vertical-align: bottom;" />}gx;
		}

   # do ^H
   #if($]>5.007)
   #{
   #	my $regexp;
   #	$regexp = sub { qr/(?:&#?[0-9a-zA-Z]+;|[^&<>])(?<!\^H)(??{$regexp})?\^H/ };
   #	$line=~s{($regexp)}{"<del>".(substr $1,0,(length $1)/3)."</del>"}gex;
   #}

        $line = $handler->($line) if ($handler);

        # fix up hidden sections
        $line =~ s{<!--([0-9]+)-->}{$hidden[$1]}ge;

        $line;
    } @_;
}

sub compile_template {
    my ( $str, $nostrip ) = @_;
    my $code;

    while ( $str =~ m!(.*?)(<(/?)(var|const|if|loop)(?:|\s+(.*?[^\\]))>|$)!sg )
    {
        my ( $html, $tag, $closing, $name, $args ) = ( $1, $2, $3, $4, $5 );

        $html =~ s/(['\\])/\\$1/g;
        $code .= "\$res.='$html';" if ( length $html );
        $args =~ s/\\>/>/g if defined;

        if ($tag) {
            if ($closing) {
                if ( $name eq 'if' ) { $code .= '}' }
                elsif ( $name eq 'loop' ) {
                    $code .= '$$_=$__ov{$_} for(keys %__ov);}}';
                }
            }
            else {
                if ( $name eq 'var' ) { $code .= '$res.=eval{' . $args . '};' }
                elsif ( $name eq 'const' ) {
                    my $const = eval $args;
                    $const =~ s/(['\\])/\\$1/g;
                    $code .= '$res.=\'' . $const . '\';';
                }
                elsif ( $name eq 'if' ) { $code .= 'if(eval{' . $args . '}){' }
                elsif ( $name eq 'loop' ) {
                    $code .=
                        'my $__a=eval{' 
                      . $args
                      . '};if($__a){for(@$__a){my %__v=%{$_};my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}';
                }
            }
        }
    }

    my $sub =
        eval 'no strict; sub { '
      . 'my $port=$ENV{SERVER_PORT}==80?"":":$ENV{SERVER_PORT}";'
      . 'my $self=decode("utf-8", $ENV{SCRIPT_NAME});'
      . 'my $absolute_self="http://$ENV{SERVER_NAME}$port$ENV{SCRIPT_NAME}";'
      . 'my ($path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;'
      . 'my $absolute_path="http://$ENV{SERVER_NAME}$port$path";'
      . 'my %__v=@_;my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}'
      . 'my $res;'
      . $code
      . '$$_=$__ov{$_} for(keys %__ov);'
      . 'return $res; }';

    die "Template format error" unless $sub;

    return $sub;
}

sub template_for {
    my ( $var, $start, $end ) = @_;
    return [ map +{ $var => $_ }, ( $start .. $end ) ];
}

sub include {
    my ($filename) = @_;

    open FILE, $filename or return '';
    my $file = do { local $/; <FILE> };

    return $file;
}

sub forbidden_unicode {
    my ( $dec, $hex ) = @_;
    return 1 if length($dec) > 7 or length($hex) > 7;    # too long numbers
    my $ord = ( $dec or hex $hex );

    return 1 if $ord > MAX_UNICODE;                      # outside unicode range
    return 1 if $ord < 32;                               # control chars
    return 1 if $ord >= 0x7f and $ord <= 0x84;           # control chars
    return 1 if $ord >= 0xd800 and $ord <= 0xdfff;       # surrogate code points
    return 1 if $ord >= 0x202a and $ord <= 0x202e;       # text direction
    return 1 if $ord >= 0xfdd0 and $ord <= 0xfdef;       # non-characters
    return 1 if $ord % 0x10000 >= 0xfffe;                # non-characters
    return 0;
}

sub clean_string {
    my ( $str, $cleanentities ) = @_;

    if ($cleanentities) { $str =~ s/&/&amp;/g }          # clean up &
    else {
        $str =~ s/&(#([0-9]+);|#x([0-9a-fA-F]+);|)/
			if($1 eq "") { '&amp;' } # change simple ampersands
			elsif(forbidden_unicode($2,$3))  { "" } # strip forbidden unicode chars
			else { "&$1" } # and leave the rest as-is.
		/ge    # clean up &, excluding numerical entities
    }

    $str =~ s/\</&lt;/g;     # clean up brackets for HTML tags
    $str =~ s/\>/&gt;/g;
    $str =~ s/"/&quot;/g;    # clean up quotes for HTML attributes
    $str =~ s/'/&#39;/g;
    $str =~ s/,/&#44;/g;     # clean up commas for some reason I forgot

#	$str =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g;    # remove control chars

    return $str;
}

sub decode_string {
    my ( $str, $charset, $noentities ) = @_;
    my $use_unicode = $has_encode && $charset;

    $str = decode( $charset, $str ) if $use_unicode;

    $str =~ s{(&#([0-9]*)([;&])|&#([x&])([0-9a-f]*)([;&]))}{
		my $ord=($2 or hex $5);
		if($3 eq '&' or $4 eq '&' or $5 eq '&') { $1 } # nested entities, leave as-is.
		elsif(forbidden_unicode($2,$5))  { "" } # strip forbidden unicode chars
		elsif($ord==35 or $ord==38) { $1 } # don't convert & or #
		elsif($use_unicode) { chr $ord } # if we have unicode support, convert all entities
		elsif($ord<128) { chr $ord } # otherwise just convert ASCII-range entities
		else { $1 } # and leave the rest as-is.
	}gei unless $noentities;

    $str =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g;    # remove control chars

    return $str;
}

sub escamp {
    my ($str) = @_;
    $str =~ s/&/&amp;/g;
    return $str;
}

sub urlenc {
    my ($str) = @_;
    $str =~ s/([^\w ])/"%".sprintf("%02x",ord $1)/sge;
    $str =~ s/ /+/sg;
    return $str;
}

sub clean_path {
    my ($str) = @_;
    $str =~ s!([^\w/._\-])!"%".sprintf("%02x",ord $1)!sge;
    return $str;
}

#
# Javascript utilities
#

sub clean_to_js {
    my $str = shift;

    $str =~ s/&amp;/\\x26/g;
    $str =~ s/&lt;/\\x3c/g;
    $str =~ s/&gt;/\\x3e/g;
    $str =~ s/&quot;/\\x22/g;                                #"
    $str =~ s/(&#39;|')/\\x27/g;
    $str =~ s/&#44;/,/g;
    $str =~ s/&#[0-9]+;/sprintf "\\u%04x",$1/ge;
    $str =~ s/&#x[0-9a-f]+;/sprintf "\\u%04x",hex($1)/gie;
    $str =~ s/(\r\n|\r|\n)/\\n/g;

    return "'$str'";
}

sub js_string {
    my $str = shift;

    $str =~ s/\\/\\\\/g;
    $str =~ s/'/\\'/g;
    $str =~ s/([\x00-\x1f\x80-\xff<>&])/sprintf "\\x%02x",ord($1)/ge;
    eval '$str=~s/([\x{100}-\x{ffff}])/sprintf "\\u%04x",ord($1)/ge';
    $str =~ s/(\r\n|\r|\n)/\\n/g;

    return "'$str'";
}

sub js_array {
    return "[" . ( join ",", @_ ) . "]";
}

sub js_hash {
    my %hash = @_;
    return "{" . ( join ",", map "'$_':$hash{$_}", keys %hash ) . "}";
}

#
# HTTP utilities
#

# LIGHTWEIGHT HTTP/1.1 CLIENT
# by fatalM4/coda, modified by WAHa.06x36

use constant CACHEFILE_PREFIX => 'cache-'
  ;    # you can make this a directory (e.g. 'cachedir/cache-' ) if you'd like
use constant FORCETIME => '0.04'
  ; # If the cache is less than (FORCETIME) days old, don't even attempt to refresh.
    # Saves everyone some bandwidth. 0.04 days is ~ 1 hour. 0.0007 days is ~ 1 min.
eval 'use IO::Socket::INET';    # Will fail on old Perl versions!

sub get_http {
    my ( $url, $maxsize, $referer, $cacheprefix ) = @_;
    my ( $host, $port, $doc ) = $url =~ m!^(?:http://|)([^/]+)(:[0-9]+|)(.*)$!;
    $port = 80 unless ($port);

    my $hash = encode_base64( rc4( null_string(6), "$host:$port$doc", 0 ), "" );
    $hash =~ tr!/+!_-!;         # remove / and +
    my $cachefile =
        ( $cacheprefix or CACHEFILE_PREFIX )
      . ( $doc =~ m!([^/]{0,15})$! )[0]
      . "-$hash";               # up to 15 chars of filename
    my ( $modified, $cache );

    if ( open CACHE, "<", $cachefile )    # get modified date and cache contents
    {
        $modified = <CACHE>;
        $cache = join "", <CACHE>;
        chomp $modified;
        close CACHE;

        return $cache if ( ( -M $cachefile ) < FORCETIME );
    }

    my $sock = IO::Socket::INET->new("$host:$port") or return $cache;
    print $sock "GET $doc HTTP/1.1\r\nHost: $host\r\nConnection: close\r\n";
    print $sock "If-Modified-Since: $modified\r\n" if $modified;
    print $sock "Referer: $referer\r\n"            if $referer;
    print $sock "\r\n";    #finished!

    # header
    my ( $line, $statuscode, $lastmod );
    do {
        $line       = <$sock>;
        $statuscode = $1 if ( $line =~ /^HTTP\/1\.1 (\d+)/ );
        $lastmod    = $1 if ( $line =~ /^Last-Modified: (.*)/ );
    } until ( $line =~ /^\r?\n/ );

    # body
    my $output;
    while ( $line = <$sock> ) {
        $output .= $line;
        last if $maxsize and $output >= $maxsize;
    }
    undef $sock;

    if ( $statuscode == "200" ) {

        #navbar changed, update cache
        if ( open CACHE, ">$cachefile" ) {
            print CACHE "$lastmod\n";
            print CACHE $output;
            close CACHE or die "close cache: $!";
        }
        return $output;
    }
    else    # touch and return cache, or nothing if no cache
    {
        utime( time, time, $cachefile );
        return $cache;
    }
}

sub make_http_forward {
    my ($location) = @_;

        print "Status: 303 Go West\n";
        print "Location: $location\n";
        print "Content-Type: text/html\n";
        print "\n";
        print '<html><body><a href="'
          . $location . '">'
          . $location
          . '</a></body></html>';
}

sub make_cookies {
    my (%cookies) = @_;

    my $charset  = $cookies{'-charset'};
    my $expires  = $cookies{'-expires'};
    my $autopath = $cookies{'-autopath'};
    my $path     = $cookies{'-path'};
    my $httponly = $cookies{'-httponly'};

	if ($expires) {
		my $date = make_date( $expires, "cookie" );
		$expires = " expires=$date;";
	}
	else
	{
		$expires = "";
	}

    unless ($path) {
        if ( $autopath eq 'current' ) {
            ($path) = $ENV{SCRIPT_NAME} =~ m!^(.*/)[^/]+$!;
        }
        elsif ( $autopath eq 'parent' ) {
            ($path) = $ENV{SCRIPT_NAME} =~ m!^(.*?/)(?:[^/]+/)?[^/]+$!;
        }
        else { $path = '/'; }
    }

	if ($httponly) {
		$httponly = " HttpOnly";
	}
	else
	{
		$httponly = "";
	}

    foreach my $name ( keys %cookies ) {
        next if ( $name =~ /^-/ );    # skip entries that start with a dash

        my $value = $cookies{$name};
        $value = "" unless ( defined $value );

        $value = cookie_encode( $value, $charset );

        print "Set-Cookie: $name=$value; path=$path;$expires$httponly\n";
    }
}

sub cookie_encode {
    my ( $str, $charset ) = @_;

    if ( $] > 5.007 )    # new perl, use Encode.pm
    {
        if ($charset) {
            require Encode;
            $str = Encode::decode( $charset, $str );
            $str =~ s/&\#([0-9]+);/chr $1/ge;
            $str =~ s/&\#x([0-9a-f]+);/chr hex $1/gei;
        }

        $str =~ s/([^0-9a-zA-Z])/
			my $c=ord $1;
			sprintf($c>255?'%%u%04x':'%%%02x',$c);
		/sge;
    }
    else    # do the hard work ourselves
    {
        if ( $charset =~ /\butf-?8$/i ) {
            $str =~
s{([\xe0-\xef][\x80-\xBF][\x80-\xBF]|[\xc0-\xdf][\x80-\xBF]|&#([0-9]+);|&#[xX]([0-9a-fA-F]+);|[^0-9a-zA-Z])}{ # convert UTF-8 to URL encoding - only handles up to U-FFFF
				my $c;
				if($2) { $c=$2 }
				elsif($3) { $c=hex $3 }
				elsif(length $1==1) { $c=ord $1 }
				elsif(length $1==2)
				{
					my @b=map { ord $_ } split //,$1;
					$c=(($b[0]-0xc0)<<6)+($b[1]-0x80);
				}
				elsif(length $1==3)
				{
					my @b=map { ord $_ } split //,$1;
					$c=(($b[0]-0xe0)<<12)+(($b[1]-0x80)<<6)+($b[2]-0x80);
				}
				sprintf($c>255?'%%u%04x':'%%%02x',$c);
			}sge;
        }
        elsif (
            $charset =~ /\b(?:shift.*jis|sjis)$/i )  # old perl, using shift_jis
        {
            require 'sjis.pl';
            my $sjis_table = get_sjis_table();

            $str =~
s{([\x80-\x9f\xe0-\xfc].|&#([0-9]+);|&#[xX]([0-9a-fA-F]+);|[^0-9a-zA-Z])}{ # convert Shift_JIS to URL encoding
				my $c=($2 or ($3 and hex $3) or $$sjis_table{$1});
				sprintf($c>255?'%%u%04x':'%%%02x',$c);
			}sge;
        }
        else {
            $str =~ s/([^0-9a-zA-Z])/sprintf('%%%02x',ord $1)/sge;
        }
    }

    return $str;
}

sub get_xhtml_content_type {
    my ( $charset, $usexhtml ) = @_;
    my $type;

    if ( $usexhtml and $ENV{HTTP_ACCEPT} =~ /application\/xhtml\+xml/ ) {
        $type = "application/xhtml+xml";
    }
    else { $type = "text/html"; }

    $type .= "; charset=$charset" if ($charset);

    return $type;
}

sub expand_filename {
    my ($filename) = @_;

    return $filename if ( $filename =~ m!^/! );
    return $filename if ( $filename =~ m!^\w+:! );

    my ($self_path) = $ENV{SCRIPT_NAME} =~ m!^(.*/)[^/]+$!;
    return decode('utf-8', $self_path) . $filename;
}

#
# Network utilities
#

sub resolve_host {
    my $ip = shift;
    return ( gethostbyaddr inet_aton($ip), AF_INET or $ip );
}

#
# Data utilities
#

sub process_tripcode {
    my ( $name, $tripkey, $secret, $charset, $nonamedecoding ) = @_;
    $tripkey = "!" unless ($tripkey);

    if ( $name =~ /^(.*?)((?<!&)#|\Q$tripkey\E)(.*)$/ ) {
        my ( $namepart, $marker, $trippart ) = ( $1, $2, $3 );
        my $trip;

        $namepart = decode_string( $namepart, $charset ) unless $nonamedecoding;
        $namepart = clean_string($namepart);

        if (    $secret
            and $trippart =~ s/(?:\Q$marker\E)(?<!&#)(?:\Q$marker\E)*(.*)$//
          )    # do we want secure trips, and is there one?
        {
            my $str    = $1;
            my $maxlen = 255 - length($secret);
            $str = substr $str, 0, $maxlen if ( length($str) > $maxlen );

#			$trip=$tripkey.$tripkey.encode_base64(rc4(null_string(6),"t".$str.$secret),"");
            $trip =
              $tripkey . $tripkey . hide_data( $1, 6, "trip", $secret, 1 );
            return ( $namepart, $trip )
              unless ($trippart)
              ;    # return directly if there's no normal tripcode
        }

        # 2ch trips are processed as Shift_JIS whenever possible
        eval 'use Encode qw(decode encode)';
        unless ($@) {
            $trippart = decode_string( $trippart, $charset );
            $trippart = encode( "Shift_JIS", $trippart, 0x0200 );
        }

        $trippart = clean_string($trippart);
        my $salt = substr $trippart . "H..", 1, 2;
        $salt =~ s/[^\.-z]/./g;
        $salt =~ tr/:;<=>?@[\\]^_`/ABCDEFGabcdef/;
        $trip = $tripkey . ( substr crypt( $trippart, $salt ), -10 ) . $trip;

        return ( $namepart, $trip );
    }

    return clean_string($name) if $nonamedecoding;
    return ( clean_string( decode_string( $name, $charset ) ), "" );
}

sub make_date {
    my ( $time, $style, @locdays ) = @_;
    my @days   = qw(So Mo Di Mi Do Fr Sa);
    my @months = qw(Jan Feb Mrz Apr Mai Jun Jul Aug Sep Okt Nov Dez);
    my @fullmonths =
      qw(Januar Februar M&auml;rz April Mai Juni Juli August September Oktober November Dezember);
    @locdays = @days unless (@locdays);

    if ( $style eq "2ch" ) {
        my @ltime = localtime($time);

        return sprintf(
            "%04d-%02d-%02d %02d:%02d",
            $ltime[5] + 1900,
            $ltime[4] + 1,
            $ltime[3], $ltime[2], $ltime[1]
        );
    }
    elsif ( $style eq "futaba" or $style eq "0" ) {
		my @ltime=localtime($time);

		return sprintf("%02d.%02d.%02d (%s) %02d:%02d",
		$ltime[3],$ltime[4]+1,$ltime[5]-100,$locdays[$ltime[6]],$ltime[2],$ltime[1]);
    }
    elsif ( $style eq "localtime" ) {
        return scalar( localtime($time) );
    }
    elsif ( $style eq "tiny" ) {
        my @ltime = localtime($time);

        return sprintf(
            "%02d/%02d %02d:%02d",
            $ltime[4] + 1,
            $ltime[3], $ltime[2], $ltime[1]
        );
    }
    elsif ( $style eq "http" ) {
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime($time);
        return sprintf(
            "%s, %02d %s %04d %02d:%02d:%02d GMT",
            $days[$wday], $mday, $months[$mon], $year + 1900,
            $hour, $min, $sec
        );
    }
    elsif ( $style eq "cookie" ) {
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime($time);
		# cookie date has to stay in english
		@days   = qw(Sun Mon Tue Wed Thu Fri Sat);
		@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

        return sprintf(
            "%s, %02d-%s-%04d %02d:%02d:%02d GMT",
            $days[$wday], $mday, $months[$mon], $year + 1900,
            $hour, $min, $sec
        );
    }
    elsif ( $style eq "month" ) {
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime($time);
        return sprintf( "%s %d", $months[$mon], $year + 1900 );
    }
    elsif ( $style eq "2ch-sep93" ) {
        my $sep93 = timelocal( 0, 0, 0, 1, 8, 93 );
        return make_date( $time, "2ch" ) if ( $time < $sep93 );

        my @ltime = localtime($time);

        return sprintf(
            "%04d-%02d-%02d %02d:%02d",
            1993, 9, int( $time - $sep93 ) / 86400 + 1,
            $ltime[2], $ltime[1]
        );
    }
}

sub parse_http_date {
    my ($date) = @_;
    my %months = (
        Jan => 0,
        Feb => 1,
        Mar => 2,
        Apr => 3,
        May => 4,
        Jun => 5,
        Jul => 6,
        Aug => 7,
        Sep => 8,
        Oct => 9,
        Nov => 10,
        Dec => 11
    );

    if ( $date =~
/^[SMTWF][a-z][a-z], (\d\d) ([JFMASOND][a-z][a-z]) (\d\d\d\d) (\d\d):(\d\d):(\d\d) GMT$/
      )
    {
        return eval { timegm( $6, $5, $4, $1, $months{$2}, $3 - 1900 ) };
    }

    return undef;
}

sub cfg_expand {
    my ( $str, %grammar ) = @_;
    $str =~ s/%(\w+)%/
		my @expansions=@{$grammar{$1}};
		cfg_expand($expansions[rand @expansions],%grammar);
	/ge;
    return $str;
}

sub encode_base64    # stolen from MIME::Base64::Perl
{
    my ( $data, $eol ) = @_;
    $eol = "\n" unless ( defined $eol );

    my $res = pack "u", $data;
    $res =~ s/^.//mg;                 # remove length counts
    $res =~ s/\n//g;                  # remove newlines
    $res =~ tr|` -_|AA-Za-z0-9+/|;    # translate to base64

    my $padding = ( 3 - length($data) % 3 ) % 3;    # fix padding at the end
    $res =~ s/.{$padding}$/'='x$padding/e if ($padding);

    $res =~ s/(.{1,76})/$1$eol/g
      if ( length $eol )
      ;    # break encoded string into lines of no more than 76 characters each

    return $res;
}

sub decode_base64    # stolen from MIME::Base64::Perl
{
    my ($str) = @_;

    $str =~ tr|A-Za-z0-9+=/||cd;    # remove non-base64 characters
    $str =~ s/=+$//;                # remove padding
    $str =~ tr|A-Za-z0-9+/| -_|;    # translate to uuencode
    return "" unless ( length $str );
    return unpack "u", join '',
      map { chr( 32 + length($_) * 3 / 4 ) . $_ } $str =~ /(.{1,60})/gs;
}

sub dot_to_dec {
	my $ip = $_[0];

	if ($ip =~ /:/) { # IPv6
		my $iph = new Net::IP($ip) or return 0;
		return $iph->intip();
	}

	# IPv4
    return unpack( 'N', pack( 'C4', split( /\./, $ip ) ) );    # wow, magic.
}

sub dec_to_dot {
	my $ip = $_[0];

	# IPv6
	return ip_compress_address(ip_bintoip(ip_inttobin($ip, 6), 6), 6) if (length(pack('w', $ip)) > 5);

	# IPv4
    return join('.', unpack('C4', pack('N', $ip)));
}

sub mask_ip {
    my ( $ip, $key, $algorithm ) = @_;

    $ip = dot_to_dec($ip) if $ip =~ /\.|:/;

    my ( $block, $stir ) = setup_masking( $key, $algorithm );
    my $mask = 0x80000000;

    for ( 1 .. 32 ) {
        my $bit = $ip & $mask ? "1" : "0";
        $block = $stir->($block);
        $ip ^= $mask if ( ord($block) & 0x80 );
        $block = $bit . $block;
        $mask >>= 1;
    }

    return sprintf "%08x", $ip;
}

sub unmask_ip {
    my ( $id, $key, $algorithm ) = @_;

    $id = hex($id);

    my ( $block, $stir ) = setup_masking( $key, $algorithm );
    my $mask = 0x80000000;

    for ( 1 .. 32 ) {
        $block = $stir->($block);
        $id ^= $mask if ( ord($block) & 0x80 );
        my $bit = $id & $mask ? "1" : "0";
        $block = $bit . $block;
        $mask >>= 1;
    }

    return dec_to_dot($id);
}

sub setup_masking {
    my ( $key, $algorithm ) = @_;

    $algorithm = $has_md5 ? "md5" : "rc6" unless $algorithm;

    my ( $block, $stir );

    if ( $algorithm eq "md5" ) {
        return ( md5($key), sub { md5(shift) } );
    }
    else {
        setup_rc6($key);
        return ( null_string(16), sub { encrypt_rc6(shift) } );
    }
}

sub make_random_string {
    my ($num) = @_;
    my $chars =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    my $str;

    $str .= substr $chars, rand length $chars, 1 for ( 1 .. $num );

    return $str;
}

sub null_string { "\0" x (shift) }

sub make_key {
    my ( $key, $secret, $length ) = @_;
    return rc4( null_string($length), $key . $secret );
}

sub hide_data {
    my ( $data, $bytes, $key, $secret, $base64 ) = @_;

    my $crypt =
      rc4( null_string($bytes), make_key( $key, $secret, 32 ) . $data );

    return encode_base64( $crypt, "" ) if $base64;
    return $crypt;
}

#
# File utilities
#

sub read_array {
    my ($file) = @_;

    if ( ref $file eq "GLOB" ) {
        return map { s/\r?\n?$//; $_ } <$file>;
    }
    else {
        open FILE, $file or return ();
        binmode FILE;
        my @array = map { s/\r?\n?$//; $_ } <FILE>;
        close FILE;
        return @array;
    }
}

sub write_array {
    my ( $file, @array ) = @_;

    if ( ref $file eq "GLOB" ) {
        print $file join "\n", @array;
    }
    else    # super-paranoid atomic write
    {
        my $rndname1 = "__" . make_random_string(12) . ".dat";
        my $rndname2 = "__" . make_random_string(12) . ".dat";
        if ( open FILE, ">$rndname1" ) {
            binmode FILE;
            if ( print FILE join "\n", @array ) {
                close FILE;
                rename $file, $rndname2 if -e $file;
                if ( rename $rndname1, $file ) {
                    unlink $rndname2 if -e $rndname2;
                    return;
                }
            }
        }
        close FILE;
        die "Couldn't write to file \"$file\"";
    }
}


#
# File utilities
#

sub analyze_file {
    my ( $file, $name ) = @_;

    my $width  = 0;
    my $height = 0;
    my $ext;
    my $known = 0;

    safety_check($file);

    my $exifInfo = ImageInfo($file);

    my $data;
    read( $file, $data, $File::MimeInfo::Magic::max_buffer );
    my $io_scalar = new IO::Scalar \$data;
    my $mimeType  = mimetype($io_scalar);

    make_error($mimeType);
    if ( $exifInfo->{width} && $exifInfo->{height} ) {
        $width  = $exifInfo->{width};
        $height = $exifInfo->{height};
    }

    my %filetypes = FILETYPES;

    # wtf, well lets just do a linear search for now.
    foreach my $key ( keys %filetypes ) {
        if ( $filetypes{$key}[1] eq $mimeType ) {
            $known = 1;
            $ext   = $key;
        }

    }
    return ( $known, $ext, $width, $height );
}

#
# Image utilities
#

sub analyze_image {
    my ( $file, $name ) = @_;
    my (@res);

    safety_check($file);

    return ( "jpg", @res ) if ( @res = analyze_jpeg($file) );
    return ( "png", @res ) if ( @res = analyze_png($file) );
    return ( "gif", @res ) if ( @res = analyze_gif($file) );
	return ( "pdf", @res ) if ( @res = analyze_pdf($file) );
	return ( "svg", @res ) if ( @res = analyze_svg($file) );
	return ( "webm", @res ) if ( @res = analyze_webm($file) );

    # find file extension for unknown files
    my ($ext) = $name =~ /\.([^\.]+)$/;
    return ( lc($ext), 0, 0 );
}

sub safety_check {
    my ($file) = @_;

# Check for IE MIME sniffing XSS exploit - thanks, MS, totally appreciating this
    read $file, my $buffer, 256;
    seek $file, 0, 0;
    die "Possible IE XSS exploit in file"
      if $buffer =~
/<(?:body|head|html|img|plaintext|pre|script|table|title|a href|channel|scriptlet)/;
}

sub analyze_jpeg {
    my ($file) = @_;
    my ($buffer);

    read( $file, $buffer, 2 );

    if ( $buffer eq "\xff\xd8" ) {
      OUTER:
        for ( ; ; ) {
            for ( ; ; ) {
                last OUTER unless ( read( $file, $buffer, 1 ) );
                last if ( $buffer eq "\xff" );
            }

            last unless ( read( $file, $buffer, 3 ) == 3 );
            my ( $mark, $size ) = unpack( "Cn", $buffer );
            last if ( $mark == 0xda or $mark == 0xd9 );    # SOS/EOI
            die "Possible virus in image"
              if ( $size < 2 );    # MS GDI+ JPEG exploit uses short chunks

            if (    $mark >= 0xc0
                and $mark <= 0xc2 )   # SOF0..SOF2 - what the hell are the rest?
            {
                last unless ( read( $file, $buffer, 5 ) == 5 );
                my ( $bits, $height, $width ) = unpack( "Cnn", $buffer );
                seek( $file, 0, 0 );

                return ( $width, $height );
            }

            seek( $file, $size - 2, 1 );
        }
    }

    seek( $file, 0, 0 );

    return ();
}

sub analyze_png {
    my ($file) = @_;
    my ( $bytes, $buffer );

    $bytes = read( $file, $buffer, 24 );
    seek( $file, 0, 0 );
    return () unless ( $bytes == 24 );

    my ( $magic1, $magic2, $length, $ihdr, $width, $height ) =
      unpack( "NNNNNN", $buffer );

    return ()
      unless ( $magic1 == 0x89504e47
        and $magic2 == 0x0d0a1a0a
        and $ihdr == 0x49484452 );

    return ( $width, $height );
}

sub analyze_gif {
    my ($file) = @_;
    my ( $bytes, $buffer );

    $bytes = read( $file, $buffer, 10 );
    seek( $file, 0, 0 );
    return () unless ( $bytes == 10 );

    my ( $magic, $width, $height ) = unpack( "A6 vv", $buffer );

    return () unless ( $magic eq "GIF87a" or $magic eq "GIF89a" );

    return ( $width, $height );
}

# very basic pdf-header check
sub analyze_pdf($) {
	my ($file) = @_;
	my ($bytes, $buffer);

	$bytes = read($file, $buffer, 5);
	seek($file, 0, 0);
	return () unless($bytes == 5);

	my $magic = unpack("A5", $buffer);
	return () unless($magic eq "%PDF-");

	return (1, 1);
}

# find some characteristic strings at the beginning of the XML.
# can break on slightly different syntax. 
sub analyze_svg($) {
	my ($file) = @_;
	my ($buffer, $header);

	read($file, $buffer, 600);
	seek($file, 0, 0);

	$header = unpack("A600", $buffer);

    if ($header =~ /<svg version=/i or $header =~ /<!DOCTYPE svg/i or
		$header =~ m!<svg\s(?:.*\s)?xmlns="http://www\.w3\.org/2000/svg"\s!i or
		$header =~ m!<svg\s(?:.*\n)*\s*xmlns="http://www\.w3\.org/2000/svg"\s!i) {
        return (1, 1);
    }

	return ();
}

sub analyze_webm($) {
    my ($file) = @_;
    my ($buffer);

    read($file, $buffer, 4);
    seek($file, 0, 0);

    if ($buffer eq "\x1A\x45\xDF\xA3") {
		my $exifTool = new Image::ExifTool;
		my $exifData = $exifTool->ImageInfo($file, 'ImageSize');
		seek($file, 0, 0);
		if ($$exifData{ImageSize} =~ /(\d+)x(\d+)/) {
			return($1, $2);
		}
	}

	return();
}

sub test_afmod {
	my @now = localtime;
	my ($month, $day) = ($now[4] + 1, $now[3]);

	return 1 if (ENABLE_AFMOD && $month == 4 && $day == 1);
	return 0;
}

sub make_video_thumbnail {
	my ($filename, $thumbnail, $width, $height, $command) = @_;

	$command = "avconv" unless ($command);
	my $filter = "scale='gte(iw\\,ih)*min(${width}\\,iw)+not(gte(iw\\,ih))*-1':'gte(ih\\,iw)*min(${height}\\,ih)+not(gte(ih\\,iw))*-1'";

	`$command -v quiet -i $filename -vframes 1 -vf $filter $thumbnail`;

	return 1 unless ($?);
	return 0;
}

sub make_thumbnail {
    my ( $filename, $thumbnail, $width, $height, $quality, $convert ) = @_;

    # first try ImageMagick

	my $background = "white";
	# use transparency if a file-extension with transparency-support was passed
	$background = "transparent" if ( $thumbnail =~ /\.png$/ or $thumbnail =~ /\.gif$/ );

    my $magickname = $filename;
    $magickname .= "[0]" if ($magickname =~ /\.gif$/ or $magickname =~ /\.pdf$/);

	my $ignore_ar = "!"; # flag to force ImageMagick to ignore the aspect ratio of the image
	# let ImageMagick figure out the thumbnail-ratio
	$ignore_ar = "" if ($filename =~ /\.pdf$/ or $filename =~ /\.svg$/);

	my $param = "";

	if (test_afmod())
	{
		my @params = ('-flip', '-flop', '-transpose', '-transverse',
			'-rotate 75', '-roll +60-45', '-quality 5', '-negate', '-monochrome',
			'-gravity NorthEast -stroke "#000C" -strokewidth 2 -annotate 90x90+5+135 "Unregistered Hypercam" '
			. '-stroke none -fill white -annotate 90x90+5+135 "Unregistered Hypercam"'
		);
		$param = $params[rand @params];
		$background = "#BFB5A1" if ($thumbnail =~ /\.jpg$/ && $filename !~ /\.pdf$/);
	}

    $convert = "convert" unless ($convert);
`$convert -background $background -flatten -size ${width}x${height} -geometry ${width}x${height}${ignore_ar} -quality $quality $param $magickname $thumbnail`;

    return 1 unless ($?);

    # if that fails, try pnmtools instead

    if ( $filename =~ /\.svg$/ ) {
        $convert = "convert" unless ($convert);
        `$convert -size 200x200 $magickname $thumbnail`;

    }

    if ( $filename =~ /\.jpg$/ ) {
`djpeg $filename | pnmscale -width $width -height $height | cjpeg -quality $quality > $thumbnail`;

        # could use -scale 1/n
        return 1 unless ($?);
    }
    elsif ( $filename =~ /\.png$/ ) {
`pngtopnm $filename | pnmscale -width $width -height $height | cjpeg -quality $quality > $thumbnail`;
        return 1 unless ($?);
    }
    elsif ( $filename =~ /\.gif$/ ) {
`giftopnm $filename | pnmscale -width $width -height $height | cjpeg -quality $quality > $thumbnail`;
        return 1 unless ($?);
    }

    # try Mac OS X's sips

`sips -z $height $width -s formatOptions normal -s format jpeg $filename --out $thumbnail >/dev/null`
      ;    # quality setting doesn't seem to work
    return 1 unless ($?);

    # try PerlMagick (it sucks)

    eval 'use Image::Magick';
    unless ($@) {
        my ( $res, $magick );

        $magick = Image::Magick->new;

        $res = $magick->Read($magickname);
        return 0 if "$res";
        $res = $magick->Scale( width => $width, height => $height );

        #return 0 if "$res";
        $res = $magick->Write( filename => $thumbnail, quality => $quality );

        #return 0 if "$res";

        return 1;
    }

    # try GD lib (also sucks, and untested)
    eval 'use GD';
    unless ($@) {
        my $src;
        if ( $filename =~ /\.jpg$/i ) {
            $src = GD::Image->newFromJpeg($filename);
        }
        elsif ( $filename =~ /\.png$/i ) {
            $src = GD::Image->newFromPng($filename);
        }
        elsif ( $filename =~ /\.gif$/i ) {
            if ( defined &GD::Image->newFromGif ) {
                $src = GD::Image->newFromGif($filename);
            }
            else {
                `gif2png $filename`;    # gif2png taken from futallaby
                $filename =~ s/\.gif/\.png/;
                $src = GD::Image->newFromPng($filename);
            }
        }
        else { return 0 }

        my ( $img_w, $img_h ) = $src->getBounds();
        my $thumb = GD::Image->new( $width, $height );
        $thumb->copyResized( $src, 0, 0, 0, 0, $width, $height, $img_w,
            $img_h );
        my $jpg = $thumb->jpeg($quality);
        open THUMBNAIL, ">$thumbnail";
        binmode THUMBNAIL;
        print THUMBNAIL $jpg;
        close THUMBNAIL;
        return 1 unless ($!);
    }

    return 0;
}

#
# Crypto code
#

sub rc4 {
    my ( $message, $key, $skip ) = @_;
    my @s       = 0 .. 255;
    my @k       = unpack 'C*', $key;
    my @message = unpack 'C*', $message;
    my ( $x, $y );
    $skip = 256 unless ( defined $skip );

    $y = 0;
    for $x ( 0 .. 255 ) {
        $y = ( $y + $s[$x] + $k[ $x % @k ] ) % 256;
        @s[ $x, $y ] = @s[ $y, $x ];
    }

    $x = 0;
    $y = 0;
    for ( 1 .. $skip ) {
        $x = ( $x + 1 ) % 256;
        $y = ( $y + $s[$x] ) % 256;
        @s[ $x, $y ] = @s[ $y, $x ];
    }

    for (@message) {
        $x = ( $x + 1 ) % 256;
        $y = ( $y + $s[$x] ) % 256;
        @s[ $x, $y ] = @s[ $y, $x ];
        $_ ^= $s[ ( $s[$x] + $s[$y] ) % 256 ];
    }

    return pack 'C*', @message;
}

my @S;

sub setup_rc6 {
    my ($key) = @_;

    $key .= "\0" x ( 4 - ( length $key ) & 3 );    # pad key

    my @L = unpack "V*", $key;

    $S[0] = 0xb7e15163;
    $S[$_] = add( $S[ $_ - 1 ], 0x9e3779b9 ) for ( 1 .. 43 );

    my $v = @L > 44 ? @L * 3 : 132;
    my ( $A, $B, $i, $j ) = ( 0, 0, 0, 0 );

    for ( 1 .. $v ) {
        $A = $S[$i] = rol( add( $S[$i], $A, $B ),   3 );
        $B = $L[$j] = rol( add( $L[$j] + $A + $B ), add( $A + $B ) );
        $i = ( $i + 1 ) % @S;
        $j = ( $j + 1 ) % @L;
    }
}

sub encrypt_rc6 {
    my ( $block, ) = @_;
    my ( $A, $B, $C, $D ) = unpack "V4", $block . "\0" x 16;

    $B = add( $B, $S[0] );
    $D = add( $D, $S[1] );

    for ( my $i = 1 ; $i <= 20 ; $i++ ) {
        my $t = rol( mul( $B, rol( $B, 1 ) | 1 ), 5 );
        my $u = rol( mul( $D, rol( $D, 1 ) | 1 ), 5 );
        $A = add( rol( $A ^ $t, $u ), $S[ 2 * $i ] );
        $C = add( rol( $C ^ $u, $t ), $S[ 2 * $i + 1 ] );

        ( $A, $B, $C, $D ) = ( $B, $C, $D, $A );
    }

    $A = add( $A, $S[42] );
    $C = add( $C, $S[43] );

    return pack "V4", $A, $B, $C, $D;
}

sub decrypt_rc6 {
    my ( $block, ) = @_;
    my ( $A, $B, $C, $D ) = unpack "V4", $block . "\0" x 16;

    $C = add( $C, -$S[43] );
    $A = add( $A, -$S[42] );

    for ( my $i = 20 ; $i >= 1 ; $i-- ) {
        ( $A, $B, $C, $D ) = ( $D, $A, $B, $C );
        my $u = rol( mul( $D, add( rol( $D, 1 ) | 1 ) ), 5 );
        my $t = rol( mul( $B, add( rol( $B, 1 ) | 1 ) ), 5 );
        $C = ror( add( $C, -$S[ 2 * $i + 1 ] ), $t ) ^ $u;
        $A = ror( add( $A, -$S[ 2 * $i ] ),     $u ) ^ $t;

    }

    $D = add32( $D, -$S[1] );
    $B = add32( $B, -$S[0] );

    return pack "V4", $A, $B, $C, $D;
}

sub setup_xtea {
}

sub encrypt_xtea {
}

sub decrypt_xtea {
}

sub add {
    my ( $sum, $term );
    while ( defined( $term = shift ) ) { $sum += $term }
    return $sum % 4294967296;
}

sub rol {
    my ( $x, $n );
    ( $x = shift ) << ( $n = 31 & shift ) | 2**$n - 1 & $x >> 32 - $n;
}
sub ror { rol( shift, 32 - ( 31 & shift ) ); }    # rorororor

sub mul {
    my ( $a, $b ) = @_;
    return ( ( ( $a >> 16 ) * ( $b & 65535 ) + ( $b >> 16 ) * ( $a & 65535 ) ) *
          65536 + ( $a & 65535 ) *
          ( $b & 65535 ) ) % 4294967296;
}

sub remove_path($) {
	my ($filename) = @_;
	# match one or more characters at the end of the string after / or \
	$filename =~ m!([^/\\]+)$!;
	$filename = $1;
	return $filename;	
}

sub get_urlstring($) {
    my ($filename) = @_;
	$filename =~ s/ /%20/g;
	$filename =~ s/\[/%5B/g;
	$filename =~ s/\]/%5D/g;
	return $filename;
}

sub get_extension($) {
	my ($filename) = @_;
	$filename =~ m/\.([^.]+)$/;
	#return uc(clean_string($1));
	return uc($1);
}

sub get_displayname($) {
	my ($filename) = @_;

	# (.{12})    - first X characters of the file(base)name
	# .{5,}      - has the basename X+Y or more characters?
	# (\.[^.]+)$ - Match a dot, followed by any number of non-dots until the end
	# output is: the first match ()->$1 a fixed string "[...]" and the extension ()->$2
	$filename =~ s/(.{12}).{5,}(\.[^.]+)$/$1\[...\]$2/;

	#return clean_string($filename);
	return $filename;
}

sub get_displaysize($;$) {
	my ($size, $dec_mark) = @_;
	my $out;

	if ($size < 1024) {
		$out = sprintf("%d Bytes", $size);
	} elsif ($size >= 1024 && $size < 1024*1024) {
		$out = sprintf("%.0f kB", $size/1024);
	} else {
		$out = sprintf("%.2f MB", $size / (1024*1024));
		$out =~ s/00 MB$/0 MB/;
	}

	$out =~ s/\./$dec_mark/e if ($dec_mark);
	return $out;
}

sub get_pretty_html($$) {
	my ($text, $add) = @_;
	$text =~ s!<br />!<br />$add!g;
	return $text;
}

sub get_post_info($) {
	my ($data) = @_;
	my @items = split(/<br \/>/, $data);
	return '(n/a)' unless (@items);

	# country flag
	$items[0] = 'UNKNOWN' if ($items[0] eq 'unk');
	my $flag = '<img src="/img/flags/' . $items[0] . '.PNG"> ';

	if (scalar @items == 1) { # for legacy entries
		return $flag . $items[0];
	} else {
		# geo location
		my @loc = grep {$_} ($items[1], $items[2], $items[3]);
		my $location = join(', ', @loc);

		# as num, name and ban link
		$items[4] =~ /^AS(\d+) /;
		$items[4] .= ' <a href="' . $ENV{SCRIPT_NAME}
			. '?task=addstring&amp;type=asban&amp;string=' . $1
			. '&amp;comment=' . urlenc($items[4]) . '">[Sperren]</a>';

		return $flag . $location . '<br />' . $items[4];
	}
}

sub get_date {
    my ($date) = @_;
    DateTime->DefaultLocale("de_DE");
    my $dt = DateTime->from_epoch( epoch => $date, time_zone => 'Europe/Berlin' );
    # $day, $fullmonths[$month], $year, $days[$wday], $hour, $min, $sec
    return $dt->strftime("%e. %B %Y (%a) %H:%M:%S %Z");
}

1;
