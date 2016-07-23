package SimpleCtemplate;
# Simple and fast template engine. Templates are compiled into perlcode and are cached as methods of template engine object

# use strict; # No strict? oh fuck no!
use Encode;
use utf8;
use Data::Dumper;
use POSIX;

#<var $var> - show variable
# $var - variable, changes inside loop,  %var - global variable, doesn't change inside loop
#<if CONDITION> html content<else>(optional)<elsif>(optional) html content </if> - условие
#<loop $hashref> show data using variables </loop> - loop
#<aloop $arrayref> show data using variables </loop> - loop through array. Current value is inside $_
#<perleval perl_code  /> - run perl code
#<time($vars)> - readable timestamp string
#<include %TMPLDIR%/head.tpl> load code from file

sub get_captcha_key {
	my ($parent) = @_;

	return 'res' . $parent if ($parent);
	return 'mainpage';
}

sub new {
	my $self = $_[1]? $_[1] : {};

	$self->{globals}={} unless $self->{globals};
	$self->{range} = 5 unless($self->{range});
	$self->{die_if_compile_error}=1 unless(defined $self->{die_if_compile_error});

	bless $self,'Template_'.$self->{tmpl_dir};

########################## Working with templates ################################
		#compiles template from code/file and creates object method. (code/path to file ; name of method, unnecessary if loading from file )
		*{'Template_'.$self->{tmpl_dir}.'::load'}=sub {
			my ($self,$code,$name)=@_;

			if(!$name && -e $code){$code=~m|[^A-z]([A-z_-]*?).tpl$|; $name=$1;}
			die __PACKAGE__.'->load: You must define method name!' unless ($name);


			*{'Template_'.$self->{tmpl_dir}.'::'.$name}=$self->compile($code);

			return 1;
		};

		# (code/path to file)= reference to compiled template
		*{'Template_'.$self->{tmpl_dir}.'::compile'}=sub {
			my ($self,$code)=@_;
			my $filename=' ';
			my $str;

			if(-e $code){ #loading from file as well
				$filename.=$code;
				open my $tmlf,'<',$code;
				$code=join '',<$tmlf>;
				close $tmlf;
			}
		# includes
			while($code=~m/(<include .*?>)/){
				while($code=~m/(<include .*?>)/g){
					my ($incname,$inctext)=($1,$1);
					$incname=~s/%TMPLDIR%/${$self}{tmpl_dir}/;

					$incname=~m/<include ([^|>]*)\|?(.*?)>/;
					open my $tmlf,'<',$1;
					binmode $tmlf;
					my $inccode = join '',<$tmlf>;

						$inccode='<if %to_file><!--# include virtual="'.$2.'" --></else/>'.$inccode.'</if>' if($2);

					close $tmlf;
					$code=~s/\Q$inctext/$inccode/g;
				}
			}
		##Handler
		while($code=~m!(.*?)(<(/?)(var|const|if|elsif|else|loop|aloop|perleval|time)(?:|\s+(.*?[^\\]))>|$)!sg)
		{
			my ($html,$tag,$closing,$name,$args)=($1,$2,$3,$4,$5);

			$args =~ s/\$([_A-z0-9]+)/\$vars{$1}/sg;
			$args =~ s/%([_A-z0-9]+)/\$global{$1}/sg;

			$html=~s/(['\\])/\\$1/g;
			$str.="\$text.='$html';" if(length $html);
			$args=~s/\\>/>/g;

			if($tag)
			{
				if($closing)
				{
					if($name eq 'if') { $str.='}' }
					elsif($name eq 'loop') { $str.='};' }
				}
				else
				{
					if($name eq 'var') { $str.='$text.=eval{'.$args.'};' }
					elsif($name eq 'const') { my $const=eval $args; $const=~s/(['\\])/\\$1/g; $str.='$text.=\''.$const.'\';' }
					elsif($name eq 'if') { $str.='if(eval{'.$args.'}){' }
					elsif($name eq 'elsif') { $str.='}elsif(eval{'.$args.'}){' }
					elsif($name eq 'else') { $str.='}else{' }
					elsif($name eq 'loop')
					{ $str.='for(@{'.$args.'}){my %vars=%{$_};' }
					elsif($name eq 'aloop')
					{ $str.='for(@{'.$args.'}){$vars{_}=$_;' }
					elsif($name eq 'perleval')
					{
						$args =~ s|^(.+?)/|$1|g;
						$str.='eval{'.$args.'};'
					}
					elsif($name eq 'time')
					{ $str.='$text.=Wakaba::make_date'.$args.';' }
				}
			}
		}

		##Compiling into anon function
		my $sub;
		use strict;
			eval q |
			$sub = sub{
			my ($self,$vars,$globals)=@_;
			my (%vars,%global,$k,$v);
			%vars=%{$vars} if($vars);
			%global=%{$self->{globals}};

			$global{self}=$ENV{SCRIPT_NAME};
			$global{server_name}=$ENV{SERVER_NAME};

			if($globals){$global{$_}=$globals->{$_} for(keys %{$globals});};

			my $text;
			|.$str.q|
			return encode('utf8',$text);};|;

			if($@){
				die __PACKAGE__."- Can't compile template$filename - $@\n $str" if $self->{die_if_compile_error};
				print __PACKAGE__."- Can't compile template$filename - $@\n";
				$sub = sub{my ($self,$vars)=@_; Dumper($vars)};
				print "$filename - Data::Dumper loaded!\n";
			};
			no strict;
			return $sub;
		};

		#Loading templates from folder and compiling them
		*{'Template_'.$self->{tmpl_dir}.'::load_from_dir'}=sub {
			my ($self,$dir)=@_;

			for( glob($dir.'*.tpl') ){
				m|[^A-z]([A-z_-]*?).tpl$|;
				*{'Template_'.$self->{tmpl_dir}.'::'.$1}=$self->compile($_);
			}

		};

########################## Template methods ################################
	##########################
		our $AUTOLOAD;
		*{'Template_'.$self->{tmpl_dir}.'::AUTOLOAD'}=sub  {
			my ($self,@vars)=@_;
			print "Undefined method $AUTOLOAD ! Data::Dumper loaded!\n";
			Dumper(@vars)
		};
		*{'Template_'.$self->{tmpl_dir}.'::DESTROY'}=sub {};

	##########################################
	# saving to file
		*{'Template_'.$self->{tmpl_dir}.'::to_file'}=sub {return bless([@_],'TemplateSaver')};


	$self->load_from_dir($self->{tmpl_dir});
return $self; }

'nyak-nyak';

package TemplateSaver;
	use utf8;
	our $AUTOLOAD;
	use Data::Dumper;
	sub AUTOLOAD {

		my $self=shift;
		$AUTOLOAD=~m/([^:]+)$/;

		open(my $handle,'>',$self->[1]) or die 'Can`t save file '.$self->[1];
		flock($handle,2); # 2 - LOCK_EX
		binmode($handle);
						$_[1]->{to_file}=1;
		print $handle $self->[0]->$1(@_);
		close $handle;
	}
	sub DESTROY {}

'nyak-nyak';
