package SimpleCtemplate;
# Простой и быстрый шаблонизатор. Шаблоны компилируются в перлокод и кешируются в виде методов обьекта-шаблонизатора

# use strict; # No strict? oh fuck no!
use Encode; 
use utf8;
use Data::Dumper;
use POSIX;

use lib '.';
BEGIN { # fuck
 do "lib/site_config.pl";
 do "lib/config_defaults.pl";
}

#<var $var> - вывод переменной
# $var - перемерная, изменяется внутри loop,  %var - глобальная переменная, не изменется внутри loop
#<if УСЛОВИЕ> html контент</else/>(опционально) html контент </if> - условие
#<loop $hashref> вывод данных используя переменные </loop> - цикл
#<aloop $arrayref> вывод данных используя переменные </loop> - цикл перебора массива. Текущее значение находится в $_
#<perleval perl_код  /> - выполнение кода
#<pagination $var> - листалка страниц
#<include %TMPLDIR%/head.tpl> подгрузка кода из другого файла

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
	
	
	
########################## Методы работы с шаблонами ################################
		#компилирует шаблон из кода/файла и создает метод обьекта. (код/путь к файлу ; имя метода, необязательно, если загружается из файла )
		# my ($text, %vars);
		*{'Template_'.$self->{tmpl_dir}.'::load'}=sub { 
			my ($self,$code,$name)=@_; 
			
			if(!$name && -e $code){$code=~m|[^A-z]([A-z_-]*?).tpl$|; $name=$1;}
			die __PACKAGE__.'->load: You must define method name!' unless ($name);

			
			*{'Template_'.$self->{tmpl_dir}.'::'.$name}=$self->compile($code);
			
			return 1;
		};

		# (код/путь к файлу)= ссылка на скомпилированный в функцию шаблон
		*{'Template_'.$self->{tmpl_dir}.'::compile'}=sub  {
			my ($self,$code)=@_; 
			my $filename=' ';
			
			if(-e $code){ #можно и из файла грузить
				$filename.=$code;
				open my $tmlf,'<',$code;
				$code=join '',<$tmlf>;
				close $tmlf;
				}
		###
			while($code=~m/(<include .*?>)/){
				while($code=~m/(<include .*?>)/g){ # подгрузка шаблонов
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
		##Обработка
			$code=~s/<!--[^#].*?-->//sg; #комментарий 
			$code=~s/'/\\'/g;#экранируем кавычки
			$code=~s/\$j/##jquery/g; # kostyl, dont name any variable as "$j"
			$code=~s/([^\\])\$([_A-z0-9]+)/$1\$vars{$2}/g; #имена переменны берем только из защищенного массива
			$code=~s/([^\[\\])%([_A-z0-9]+)/$1\$global{$2}/g; # или глобального массива # который тоже защищен и существет только внутри метода-шаблона
			$code=~s/##jquery/\$j/g; # kostyl
			
			#добавляем переменные
			$code=~s/<var +(.*?)>/'.$1.'/g;
			$code=~s/#var +(.*?)#/'.$1.'/g;

			$code=~s/<const +(.*?)>/'.&$1.'/g;
			$code=~s/#const +(.*?)#/'.&$1.'/g;

			$code=~s|#loop +(.*?)#|'; for(\@{$1}){my \%vars=%{\$_};\$text.='|g;#циклы
			$code=~s|#aloop +(.*?)#|'; for(\@{$1}){\$vars{_}=\$_;\$text.='|g;
			$code=~s^#/loop#^'}; \$text.='^g; 
			
			$code=~s|<loop +(.*?)>|'; for(\@{$1}){my \%vars=%{\$_};\$text.='|g;#циклы
			$code=~s|<aloop +(.*?)>|'; for(\@{$1}){\$vars{_}=\$_;\$text.='|g;
			$code=~s^</loop>^'}; \$text.='^g; 
			
			$code=~s|#if +(.*?)#|'; if($1){\$text.='|g; #условия
			$code=~s|#/else/#|';}else{ \$text.='|g; 
			$code=~s|#else#|';}else{ \$text.='|g; 
			$code=~s|#/if#|';}; \$text.='|g; 
			
			$code=~s|<if +(.*?)>|'; if($1){\$text.='|g; #условия
			$code=~s|</else/>|';}else{ \$text.='|g; 
			$code=~s|<else>|';}else{ \$text.='|g; 
			$code=~s|</if>|';}; \$text.='|g; 
			
			$code=~s|#perleval +(.*?)/#|'; $1 ;\$text.='|sg; #выполнение кода
			$code=~s|<perleval +(.*?)/>|'; $1 ;\$text.='|sg; #выполнение кода
			
		##Компилируем в анонимную функцию
		
		my $sub;
		use strict;
			eval q |
			$sub = sub{
			my ($self,$vars,$globals)=@_;
			my (%vars,%global,$k,$v);
			%vars=%{$vars} if($vars);
			%global=%{$self->{globals}};

			$vars{self}=decode("utf-8", $ENV{SCRIPT_NAME});
			$global{self}=$vars{self};
			$global{board}=$vars{cfg}{SELFPATH};

			if($globals){$global{$_}=$globals->{$_} for(keys %{$globals});};
			
			my $text; 
			$text='|.$code.q|'; 
			return encode('utf8',$text);};|;

			if($@){
				die __PACKAGE__."- Can't compile template$filename - $@\n $code" if $self->{die_if_compile_error};
				print __PACKAGE__."- Can't compile template$filename - $@\n";
				$sub = sub{my ($self,$vars)=@_; Dumper($vars)};
				print "$filename - Data::Dumper loaded!\n";
			};
		no strict;
			return $sub;
		};

		#Подгружает шаблоны из папки и компилирует их
		*{'Template_'.$self->{tmpl_dir}.'::load_from_dir'}=sub { 
			my ($self,$dir)=@_; 
			
			for( glob($dir.'*.tpl') ){
				m|[^A-z]([A-z_-]*?).tpl$|;
				*{'Template_'.$self->{tmpl_dir}.'::'.$1}=$self->compile($_);
			}
			
		};
		
########################## Методы шаблонизации ################################
	##########################
		our $AUTOLOAD;
		*{'Template_'.$self->{tmpl_dir}.'::AUTOLOAD'}=sub  {
			my ($self,@vars)=@_; 
			print "Undefined method $AUTOLOAD ! Data::Dumper loaded!\n";
			Dumper(@vars)
		};
		*{'Template_'.$self->{tmpl_dir}.'::DESTROY'}=sub {};
		
	##########################################
	# сохранялка в файл
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