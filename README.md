Phutaba Imageboard based on Wakaba
==================================

Installation
------------
1. Modify `lib/site_config.pl.dist` and save as `lib/site_config.pl`
2. Modify `board/config.pl` to configure your board
3. Create `board/src/` and `board/thumb/` directories  
 - SQL tables are created automatically (if db user has `CREATE TABLE` permissions)
4. Create new boards by copying the structure and files from `board/`

##### Apache modules needed
* suexec (apache2-suexec-custom)
* expires
* ssl
* headers
* rewrite
* cgi

##### Perl modules needed (Ubuntu packages)
* libnet-dns-perl
* libjson-xs-perl
* libjson-perl
* libimage-exiftool-perl
* libgeo-ip-perl
* libtemplate-perl

##### external libs
* imagemagick
* ffmpeg

**Only for enterprise Imageboards**
