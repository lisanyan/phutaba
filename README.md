# Phutaba Imageboard based on Wakaba

## Installation
* Modify lib/site_config.pl.dist and save it as lib/site_config.pl
* Modify lib/config/moders.pl to add moderators
* Modify lib/config/settings.pl to configure boards
* Modify lib/config/trips.pl to add special tripcodes if you need
* SQL tables are created automatically (if db user has CREATE TABLE permissions)
* Create new boards by copying the structure and files from board/* and editing settings.pl

## Dependencies
* MySQL 5
* Perl >= 5.14
* CGI::Fast / libcgi-fast-perl
* FCGI::ProcManager / libfcgi-procmanager-perl
* Net::DNS / libnet-dns-perl
* Net::IP / libnet-ip-perl
* Image::ExifTool / libimage-exiftool-perl
* Template / libtemplate-perl
* JSON:XS / libjson-xs-perl
* JSON / libjson-perl
* Geo::IP / libgeo-ip-perl
* ... and many more

## External libs
* ImageMagick
* FFmpeg

*Only for enterprise imageboards*
