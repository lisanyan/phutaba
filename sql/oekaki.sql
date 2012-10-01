CREATE TABLE IF NOT EXISTS `oekaki` (
  `board` varchar(10) NOT NULL,
  `tmpid` varchar(255) NOT NULL,
  `filename` text NOT NULL,
  `time` datetime NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `thumbnail` text,
  `tn_width` int(11) DEFAULT NULL,
  `th_height` int(11) DEFAULT NULL,
  PRIMARY KEY (`tmpid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;