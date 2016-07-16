package Pomf;

use strict;
# use warnings;
use LWP;

use Exporter qw(import);
our @EXPORT_OK = qw(pomf_upload);

sub new {
  my $package = shift;
  return bless({}, $package);
}

sub pomf_upload
{
	my ($file) = @_;
	my $post = 'https://pomf.cat/upload.php'; # POST url

	if (!$file) {
		return 0;
	}
	else {
		pomf_sender($file, $post);
	}
}

sub pomf_sender {
	my ($file,$post)=@_;
	my ($data, $rdata, $request, $return);

	$request = LWP::UserAgent->new;
	$request->agent('Pomf.se-PerlUploader/0.1');

	$data = $request->post(
		$post,
		[ 
			'files[]' => [$file]
		],
			'Content_Type' => 'form-data'
	);
	$rdata = $data->content();
		
		
	if($rdata =~ /\{"success":(.*?)(,"files":\[\{"hash":["|']?(.*?)["|']?,"name":["|']?(.*?)["|']?,"url":["|']?(.*?)["|']?,"size":["|']?(.*?)["|']?\}\])?\}/)
	{
		my $success = $1;
		#my $error = $2;
		if($success eq 'true'){
			my $hash = $3;
			my $original = $4;
			my $uploaded = $5;
			my $size = $6;
					
			# print "Successfully uploaded!\n";
			$return = "id: $uploaded";

		} else { # shit...
			$return = "Unknown Error";
		}
	}
	else {
		$return  = "Error: Bad server response.";
		$rdata   =~ s|<.+?>||g;
		$rdata   =~ s/Your IP: (.+?)//g;
		$return .= "<br />" . $rdata;
	}

	return $return;
}

1;
