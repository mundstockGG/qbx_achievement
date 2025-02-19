CREATE TABLE IF NOT EXISTS `players_achievements` (
    `id` int(50) NOT NULL PRIMARY KEY,
    `isFirstDrive` TINYINT(1) DEFAULT 0,
    `isKillSpecificPed` TINYINT(1) DEFAULT 0,
    `isDrinkItem` TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;