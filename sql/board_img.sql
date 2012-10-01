CREATE TABLE IF NOT EXISTS `ernstchan_b_img` (
  `timestamp` bigint(20) NOT NULL,
  `image` text,
  `size` int(11) DEFAULT NULL,
  `md5` text,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `thumbnail` text,
  `tn_width` text,
  `tn_height` text,
  `uploadname` text,
  `displaysize` text,
  PRIMARY KEY (`timestamp`),
  FULLTEXT KEY `uploadname` (`uploadname`),
  FULLTEXT KEY `image` (`image`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;