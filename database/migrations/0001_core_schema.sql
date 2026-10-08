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
  `PasswordHash` char(64) DEFAULT NULL,
  `PasswordSalt` varchar(40) DEFAULT NULL,
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
