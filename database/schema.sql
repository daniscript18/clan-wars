-- Clan Wars core schema
-- Compatible with MariaDB 10.4+ / MySQL 8+

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `Version` varchar(64) NOT NULL,
  `AppliedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `players` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `Ip` varchar(45) DEFAULT NULL,
  `Username` varchar(24) NOT NULL,
  `Password` varchar(128) DEFAULT NULL,
  `PasswordHash` varchar(128) DEFAULT NULL,
  `PasswordSalt` varchar(64) DEFAULT NULL,
  `PasswordAlgo` varchar(16) NOT NULL DEFAULT 'legacy_sha256',
  `Skin` int NOT NULL DEFAULT 124,
  `Admin` tinyint unsigned NOT NULL DEFAULT 0,
  `Kills` int unsigned NOT NULL DEFAULT 0,
  `Deaths` int unsigned NOT NULL DEFAULT 0,
  `Wins` int unsigned NOT NULL DEFAULT 0,
  `LoginFailures` smallint unsigned NOT NULL DEFAULT 0,
  `LoginLockedUntil` int unsigned NOT NULL DEFAULT 0,
  `LoginLockIp` varchar(45) NOT NULL DEFAULT '',
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_players_username` (`Username`),
  KEY `idx_players_admin` (`Admin`),
  KEY `idx_players_stats` (`Wins`, `Kills`, `Deaths`),
  KEY `idx_players_login_lock` (`LoginLockedUntil`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `worlds` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(24) NOT NULL,
  `Password` varchar(32) NOT NULL DEFAULT '',
  `World` int unsigned NOT NULL DEFAULT 0,
  `State` tinyint unsigned NOT NULL DEFAULT 0,
  `Privacy` tinyint unsigned NOT NULL DEFAULT 0,
  `TeamOneName` varchar(24) NOT NULL DEFAULT 'Team One',
  `TeamTwoName` varchar(24) NOT NULL DEFAULT 'Team Two',
  `MaxRounds` smallint unsigned NOT NULL DEFAULT 5,
  `MaxPoints` smallint unsigned NOT NULL DEFAULT 10,
  `Weapons` int unsigned NOT NULL DEFAULT 0,
  `Map` int unsigned NOT NULL DEFAULT 0,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_worlds_virtual_world` (`World`),
  KEY `idx_worlds_state` (`State`),
  KEY `idx_worlds_privacy` (`Privacy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `maps` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `World` int unsigned NOT NULL,
  `Name` varchar(24) NOT NULL,
  `SpecX` float NOT NULL DEFAULT 0,
  `SpecY` float NOT NULL DEFAULT 0,
  `SpecZ` float NOT NULL DEFAULT 0,
  `SpecA` float NOT NULL DEFAULT 0,
  `TeamOneX` float NOT NULL DEFAULT 0,
  `TeamOneY` float NOT NULL DEFAULT 0,
  `TeamOneZ` float NOT NULL DEFAULT 0,
  `TeamOneA` float NOT NULL DEFAULT 0,
  `TeamTwoX` float NOT NULL DEFAULT 0,
  `TeamTwoY` float NOT NULL DEFAULT 0,
  `TeamTwoZ` float NOT NULL DEFAULT 0,
  `TeamTwoA` float NOT NULL DEFAULT 0,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  KEY `idx_maps_world` (`World`),
  CONSTRAINT `fk_maps_world` FOREIGN KEY (`World`) REFERENCES `worlds` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `weapons` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `World` int unsigned NOT NULL,
  `Name` varchar(24) NOT NULL,
  `Weapon1` smallint NOT NULL DEFAULT -1,
  `Weapon2` smallint NOT NULL DEFAULT -1,
  `Weapon3` smallint NOT NULL DEFAULT -1,
  `Weapon4` smallint NOT NULL DEFAULT -1,
  `Ammo1` int NOT NULL DEFAULT -1,
  `Ammo2` int NOT NULL DEFAULT -1,
  `Ammo3` int NOT NULL DEFAULT -1,
  `Ammo4` int NOT NULL DEFAULT -1,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  KEY `idx_weapons_world` (`World`),
  CONSTRAINT `fk_weapons_world` FOREIGN KEY (`World`) REFERENCES `worlds` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `worlds_admins` (
  `Player` int unsigned NOT NULL,
  `World` int unsigned NOT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Player`, `World`),
  KEY `idx_worlds_admins_world` (`World`),
  CONSTRAINT `fk_worlds_admins_player` FOREIGN KEY (`Player`) REFERENCES `players` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `fk_worlds_admins_world` FOREIGN KEY (`World`) REFERENCES `worlds` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bans` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `PlayerId` int unsigned NOT NULL,
  `AdminId` int unsigned DEFAULT NULL,
  `Reason` varchar(64) NOT NULL DEFAULT 'Sin especificar',
  `DateTime` varchar(32) NOT NULL,
  `Time` int NOT NULL DEFAULT -1,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_bans_player` (`PlayerId`),
  KEY `idx_bans_time` (`Time`),
  CONSTRAINT `fk_bans_player` FOREIGN KEY (`PlayerId`) REFERENCES `players` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bans_admin` FOREIGN KEY (`AdminId`) REFERENCES `players` (`Id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mutes` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `PlayerId` int unsigned NOT NULL,
  `AdminId` int unsigned DEFAULT NULL,
  `Reason` varchar(64) NOT NULL DEFAULT 'Sin especificar',
  `DateTime` varchar(32) NOT NULL,
  `Time` int NOT NULL DEFAULT -1,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_mutes_player` (`PlayerId`),
  KEY `idx_mutes_time` (`Time`),
  CONSTRAINT `fk_mutes_player` FOREIGN KEY (`PlayerId`) REFERENCES `players` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mutes_admin` FOREIGN KEY (`AdminId`) REFERENCES `players` (`Id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `matches` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `World` int unsigned NOT NULL,
  `WorldName` varchar(24) NOT NULL,
  `TeamOneName` varchar(24) NOT NULL,
  `TeamTwoName` varchar(24) NOT NULL,
  `TeamOneRounds` smallint unsigned NOT NULL DEFAULT 0,
  `TeamTwoRounds` smallint unsigned NOT NULL DEFAULT 0,
  `WinnerTeam` tinyint unsigned NOT NULL DEFAULT 0,
  `WinnerName` varchar(24) NOT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  KEY `idx_matches_world` (`World`),
  KEY `idx_matches_winner` (`WinnerTeam`),
  KEY `idx_matches_created_at` (`CreatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `action_logs` (
  `Id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ActorId` int unsigned DEFAULT NULL,
  `TargetId` int unsigned DEFAULT NULL,
  `World` int unsigned DEFAULT NULL,
  `Action` varchar(32) NOT NULL,
  `Details` varchar(255) DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  KEY `idx_action_logs_actor` (`ActorId`),
  KEY `idx_action_logs_target` (`TargetId`),
  KEY `idx_action_logs_world` (`World`),
  KEY `idx_action_logs_created_at` (`CreatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Legacy hardening for old imports (MySQL 8 / MariaDB compatible)
SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'PasswordHash'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `PasswordHash` char(64) DEFAULT NULL AFTER `Password`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'PasswordSalt'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `PasswordSalt` varchar(40) DEFAULT NULL AFTER `PasswordHash`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'Skin'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `Skin` int NOT NULL DEFAULT 124 AFTER `PasswordSalt`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'Kills'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `Kills` int unsigned NOT NULL DEFAULT 0 AFTER `Admin`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'Deaths'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `Deaths` int unsigned NOT NULL DEFAULT 0 AFTER `Kills`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'Wins'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `Wins` int unsigned NOT NULL DEFAULT 0 AFTER `Deaths`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'LoginFailures'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `LoginFailures` smallint unsigned NOT NULL DEFAULT 0 AFTER `Wins`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'LoginLockedUntil'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `LoginLockedUntil` int unsigned NOT NULL DEFAULT 0 AFTER `LoginFailures`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'LoginLockIp'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `LoginLockIp` varchar(45) NOT NULL DEFAULT '''' AFTER `LoginLockedUntil`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'CreatedAt'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `LoginLockIp`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'UpdatedAt'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `CreatedAt`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `players`
SET `PasswordSalt` = IFNULL(`PasswordSalt`, CONCAT(`Id`, '_', `Username`, '_legacy'))
WHERE `PasswordSalt` IS NULL OR `PasswordSalt` = '';

UPDATE `players`
SET `PasswordHash` = SHA2(CONCAT(IFNULL(`Password`, ''), `PasswordSalt`), 256)
WHERE (`PasswordHash` IS NULL OR `PasswordHash` = '') AND `Password` IS NOT NULL;


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


-- Persistent login throttling and legacy plaintext cleanup.
SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'LoginFailures'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `LoginFailures` smallint unsigned NOT NULL DEFAULT 0 AFTER `Wins`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'LoginLockedUntil'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `LoginLockedUntil` int unsigned NOT NULL DEFAULT 0 AFTER `LoginFailures`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'LoginLockIp'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `LoginLockIp` varchar(45) NOT NULL DEFAULT '''' AFTER `LoginLockedUntil`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `players`
SET `Password` = NULL
WHERE `PasswordHash` IS NOT NULL AND `PasswordHash` <> '';


-- Match lifecycle, round history and per-player match statistics.
-- Compatible with MariaDB 10.4+ / MySQL 8+.

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'MatchKey'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `MatchKey` varchar(64) DEFAULT NULL AFTER `Id`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'MapId'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `MapId` int unsigned DEFAULT NULL AFTER `WorldName`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'MapName'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `MapName` varchar(24) NOT NULL DEFAULT '''' AFTER `MapId`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'WeaponId'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `WeaponId` int unsigned DEFAULT NULL AFTER `MapName`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'WeaponName'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `WeaponName` varchar(24) NOT NULL DEFAULT '''' AFTER `WeaponId`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'PointsToWin'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `PointsToWin` smallint unsigned NOT NULL DEFAULT 0 AFTER `TeamTwoName`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'RoundsToWin'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `RoundsToWin` smallint unsigned NOT NULL DEFAULT 0 AFTER `PointsToWin`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'Status'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `Status` varchar(16) NOT NULL DEFAULT ''completed'' AFTER `WinnerName`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'StartedAt'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `StartedAt` timestamp NULL DEFAULT NULL AFTER `Status`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND COLUMN_NAME = 'EndedAt'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD COLUMN `EndedAt` timestamp NULL DEFAULT NULL AFTER `StartedAt`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `matches`
SET `MatchKey` = CONCAT('legacy-', `Id`)
WHERE `MatchKey` IS NULL OR `MatchKey` = '';

UPDATE `matches`
SET `StartedAt` = COALESCE(`StartedAt`, `CreatedAt`),
    `EndedAt` = CASE WHEN `Status` = 'completed' THEN COALESCE(`EndedAt`, `CreatedAt`) ELSE `EndedAt` END;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND INDEX_NAME = 'uq_matches_match_key'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD UNIQUE KEY `uq_matches_match_key` (`MatchKey`)'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matches' AND INDEX_NAME = 'idx_matches_status'),
  'SELECT 1',
  'ALTER TABLE `matches` ADD KEY `idx_matches_status` (`Status`)'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `match_players` (
  `Id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `MatchId` int unsigned NOT NULL,
  `PlayerId` int unsigned NOT NULL,
  `PlayerName` varchar(24) NOT NULL,
  `Team` tinyint unsigned NOT NULL,
  `Kills` int unsigned NOT NULL DEFAULT 0,
  `Deaths` int unsigned NOT NULL DEFAULT 0,
  `Won` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `WinCredited` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `JoinedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_match_players_match_player` (`MatchId`, `PlayerId`),
  KEY `idx_match_players_player` (`PlayerId`),
  KEY `idx_match_players_team` (`MatchId`, `Team`),
  KEY `idx_match_players_won` (`PlayerId`, `Won`),
  CONSTRAINT `fk_match_players_match` FOREIGN KEY (`MatchId`) REFERENCES `matches` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `match_rounds` (
  `Id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `MatchId` int unsigned NOT NULL,
  `RoundNumber` smallint unsigned NOT NULL,
  `WinnerTeam` tinyint unsigned NOT NULL,
  `WinnerName` varchar(24) NOT NULL,
  `TeamOnePoints` smallint unsigned NOT NULL DEFAULT 0,
  `TeamTwoPoints` smallint unsigned NOT NULL DEFAULT 0,
  `TeamOneRounds` smallint unsigned NOT NULL DEFAULT 0,
  `TeamTwoRounds` smallint unsigned NOT NULL DEFAULT 0,
  `CreatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_match_rounds_match_round` (`MatchId`, `RoundNumber`),
  KEY `idx_match_rounds_winner` (`WinnerTeam`),
  CONSTRAINT `fk_match_rounds_match` FOREIGN KEY (`MatchId`) REFERENCES `matches` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- 0005 bcrypt/open.mp consolidated changes
SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'PasswordAlgo'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `PasswordAlgo` varchar(16) NOT NULL DEFAULT ''legacy_sha256'' AFTER `PasswordSalt`'
);
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
ALTER TABLE `players` MODIFY COLUMN `PasswordHash` varchar(128) DEFAULT NULL, MODIFY COLUMN `PasswordSalt` varchar(64) DEFAULT NULL;
UPDATE `players` SET `PasswordAlgo` = CASE WHEN `PasswordHash` LIKE '$2%' THEN 'bcrypt' ELSE 'legacy_sha256' END WHERE `PasswordHash` IS NOT NULL AND `PasswordHash` <> '';
UPDATE `players` SET `Password` = NULL WHERE `PasswordHash` IS NOT NULL AND `PasswordHash` <> '';
