package Pomf;

use strict;
# use warnings;
use LWP;

use Exporter qw(import);
our @EXPORT_OK = qw(pomf_sender);

sub new {
  my $package = shift;
  return bless({}, $package);
}

sub pomf_sender {
	my ($JSON, $file)=@_;
	my ($data, $rdata, $request, $return);
	my $post = 'https://safe.moe/api/upload'; # POST url

	$request = LWP::UserAgent->new;
	$request->agent('Pomf.se-PerlUploader/0.1');
    $request->default_header('token' => 'CwmWq8AYfCy6PRN3OY5OSVYQYS2yemZIvsXSlEcwLAz2osNQBrwqdbUpgwCEB8Qj');

	$data = $request->post(
		$post,
		[ 
			'files[]' => [$file]
		],
			'Content_Type' => 'form-data'
	);
	$rdata = $data->content();

	my $json;
    eval { $json = $JSON->decode($rdata); 1 };

	unless ($@)
	{
		return $json;
    }
    else
    {
    	return {};
    }
}

1;
