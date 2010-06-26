SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

CREATE TABLE IF NOT EXISTS `phutaba_start` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `Titel` varchar(100) NOT NULL,
  `Datum` datetime NOT NULL,
  `Inhalt` text NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

