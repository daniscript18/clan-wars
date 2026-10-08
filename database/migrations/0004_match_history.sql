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
