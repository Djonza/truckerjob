CREATE TABLE IF NOT EXISTS `player_stats` (
  `identifier` varchar(46) NOT NULL,
  `level` int(11) DEFAULT 1,
  `experience` int(11) DEFAULT 0,
  `totalEarnings` int(11) DEFAULT 0,
  `kilometers` float DEFAULT 0,
  `completedMissions` int(11) DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
