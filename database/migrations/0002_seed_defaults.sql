-- Default worlds, maps and weapons. Safe to run once through migration system.

INSERT INTO `worlds` (`Id`, `Name`, `Password`, `World`, `State`, `Privacy`, `TeamOneName`, `TeamTwoName`, `MaxRounds`, `MaxPoints`, `Weapons`, `Map`) VALUES
  (1, 'Mundo 1', '', 100, 0, 1, 'Team One', 'Team Two', 5, 10, 1, 1),
  (2, 'Mundo 2', '', 200, 0, 1, 'Team One', 'Team Two', 5, 10, 3, 2),
  (3, 'Mundo 3', '', 300, 0, 1, 'Team One', 'Team Two', 5, 10, 5, 3)
ON DUPLICATE KEY UPDATE
  `Name` = VALUES(`Name`),
  `World` = VALUES(`World`),
  `Privacy` = VALUES(`Privacy`),
  `Weapons` = VALUES(`Weapons`),
  `Map` = VALUES(`Map`);

INSERT INTO `maps` (`Id`, `World`, `Name`, `SpecX`, `SpecY`, `SpecZ`, `SpecA`, `TeamOneX`, `TeamOneY`, `TeamOneZ`, `TeamOneA`, `TeamTwoX`, `TeamTwoY`, `TeamTwoZ`, `TeamTwoA`) VALUES
  (1, 1, 'Aeropuerto LS', 2021.63, -2381.96, 26.4903, 89.9708, 1973.97, -2280.87, 13.5469, 169.816, 1969.04, -2422.62, 13.5469, 6.7741),
  (2, 2, 'Aeropuerto LV', -1219.64, -69.6603, 28.9255, 310.17, -1341.99, -26.4392, 14.1484, 225.009, -1186.47, -182.016, 14.1484, 44.5505),
  (3, 3, 'Aeropuerto SF', 1604.97, 1447.61, 33.4481, 93.7946, 1555.4, 1536.83, 10.8266, 179.97, 1547.58, 1364.82, 10.8672, 2.332)
ON DUPLICATE KEY UPDATE
  `World` = VALUES(`World`),
  `Name` = VALUES(`Name`),
  `SpecX` = VALUES(`SpecX`),
  `SpecY` = VALUES(`SpecY`),
  `SpecZ` = VALUES(`SpecZ`),
  `SpecA` = VALUES(`SpecA`),
  `TeamOneX` = VALUES(`TeamOneX`),
  `TeamOneY` = VALUES(`TeamOneY`),
  `TeamOneZ` = VALUES(`TeamOneZ`),
  `TeamOneA` = VALUES(`TeamOneA`),
  `TeamTwoX` = VALUES(`TeamTwoX`),
  `TeamTwoY` = VALUES(`TeamTwoY`),
  `TeamTwoZ` = VALUES(`TeamTwoZ`),
  `TeamTwoA` = VALUES(`TeamTwoA`);

INSERT INTO `weapons` (`Id`, `World`, `Name`, `Weapon1`, `Weapon2`, `Weapon3`, `Weapon4`, `Ammo1`, `Ammo2`, `Ammo3`, `Ammo4`) VALUES
  (1, 1, 'RW', 22, 26, 28, -1, 9999, 9999, 9999, -1),
  (2, 1, 'WW', 24, 26, 29, 31, 9999, 9999, 9999, 9999),
  (3, 2, 'RW', 22, 26, 28, -1, 9999, 9999, 9999, -1),
  (4, 2, 'WW', 24, 26, 29, 31, 9999, 9999, 9999, 9999),
  (5, 3, 'RW', 22, 26, 28, -1, 9999, 9999, 9999, -1),
  (6, 3, 'WW', 24, 26, 29, 31, 9999, 9999, 9999, 9999)
ON DUPLICATE KEY UPDATE
  `World` = VALUES(`World`),
  `Name` = VALUES(`Name`),
  `Weapon1` = VALUES(`Weapon1`),
  `Weapon2` = VALUES(`Weapon2`),
  `Weapon3` = VALUES(`Weapon3`),
  `Weapon4` = VALUES(`Weapon4`),
  `Ammo1` = VALUES(`Ammo1`),
  `Ammo2` = VALUES(`Ammo2`),
  `Ammo3` = VALUES(`Ammo3`),
  `Ammo4` = VALUES(`Ammo4`);
