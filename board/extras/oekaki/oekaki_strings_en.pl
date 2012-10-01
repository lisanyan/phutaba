use constant S_OEKPAINT => 'Programm: ';									# Describes the oekaki painter to use
use constant S_OEKSOURCE => 'Source: ';							# Describes the source selector
use constant S_OEKNEW => 'Neues Bild';							# Describes the new image option
use constant S_OEKMODIFY => 'Nr. %d bearbeiten';						# Describes an option to modify an image
use constant S_OEKX => 'Breite: ';									# Describes x dimension for oekaki
use constant S_OEKY => 'H&ouml;he: ';									# Describes y dimension for oekaki
use constant S_OEKSUBMIT => 'Malen!';									# Oekaki button used for submit
use constant S_OEKIMGREPLY => 'Antworten';

use constant S_OEKIMGREPLY => 'Datei';
use constant S_OEKREPEXPL => 'Dein Oekaki wird als Antwort in Thread <a href="%s">%s</a> benutzt.';

use constant S_OEKTOOBIG => 'Bitte w&auml;hle ein kleineres Format.';
use constant S_OEKTOOSMALL => 'Bitte w&auml;hle ein gr&ouml;&szlig;eres Format.';
use constant S_OEKUNKNOWN => 'Unbekanntes Programm gew&auml;hlt.';
use constant S_HAXORING => 'Unbekannter Fehler.';

use constant S_OEKPAINTERS => [
	{ painter=>"shi_norm", name=>"Shi-Painter" },
	{ painter=>"shi_pro", name=>"Shi-Painter Pro" },
	{ painter=>"shi_norm_selfy", name=>"Shi-Painter +Selfy" },
	{ painter=>"shi_pro_selfy", name=>"Shi-Painter Pro +Selfy" },
];

1;
