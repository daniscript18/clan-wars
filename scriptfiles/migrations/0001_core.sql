-- Clan Wars core schema.
-- Baseline: MariaDB 10.5+ / MySQL 8+.
-- This migration is the reset point and becomes immutable after the initial rewrite.

CREATE TABLE IF NOT EXISTS `schema_migrations` (
    `version` VARCHAR(64) NOT NULL,
    `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `players` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(24) NOT NULL,
    `password_hash` VARCHAR(60) NOT NULL,
    `ip_address` VARCHAR(45) DEFAULT NULL,
    `skin` SMALLINT UNSIGNED NOT NULL DEFAULT 124,
    `admin_level` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `failed_login_count` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `locked_until` DATETIME DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `last_login_at` DATETIME DEFAULT NULL,
    `last_seen_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_players_username` (`username`),
    KEY `idx_players_admin_level` (`admin_level`),
    KEY `idx_players_locked_until` (`locked_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `player_stats` (
    `player_id` INT UNSIGNED NOT NULL,
    `kills` INT UNSIGNED NOT NULL DEFAULT 0,
    `deaths` INT UNSIGNED NOT NULL DEFAULT 0,
    `wins` INT UNSIGNED NOT NULL DEFAULT 0,
    `losses` INT UNSIGNED NOT NULL DEFAULT 0,
    `matches_played` INT UNSIGNED NOT NULL DEFAULT 0,
    `rounds_won` INT UNSIGNED NOT NULL DEFAULT 0,
    `rounds_lost` INT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`player_id`),
    CONSTRAINT `fk_player_stats_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `punishments` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `player_id` INT UNSIGNED NOT NULL,
    `issued_by_player_id` INT UNSIGNED DEFAULT NULL,
    `revoked_by_player_id` INT UNSIGNED DEFAULT NULL,
    `type` VARCHAR(16) NOT NULL,
    `reason` VARCHAR(160) NOT NULL DEFAULT 'Sin especificar',
    `expires_at` DATETIME DEFAULT NULL,
    `revoked_at` DATETIME DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_punishments_player_active` (`player_id`,`type`,`revoked_at`,`expires_at`),
    KEY `idx_punishments_created_at` (`created_at`),
    CONSTRAINT `fk_punishments_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_punishments_issuer` FOREIGN KEY (`issued_by_player_id`) REFERENCES `players` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_punishments_revoker` FOREIGN KEY (`revoked_by_player_id`) REFERENCES `players` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `worlds` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `owner_player_id` INT UNSIGNED DEFAULT NULL,
    `virtual_world_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(32) NOT NULL,
    `password_hash` VARCHAR(60) DEFAULT NULL,
    `privacy` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `status` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `team_alpha_name` VARCHAR(24) NOT NULL DEFAULT 'Alpha',
    `team_bravo_name` VARCHAR(24) NOT NULL DEFAULT 'Bravo',
    `rounds_to_win` SMALLINT UNSIGNED NOT NULL DEFAULT 5,
    `points_to_win` SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    `max_players` SMALLINT UNSIGNED NOT NULL DEFAULT 32,
    `enabled` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_worlds_virtual_world_id` (`virtual_world_id`),
    UNIQUE KEY `uq_worlds_name` (`name`),
    KEY `idx_worlds_enabled_status` (`enabled`,`status`),
    CONSTRAINT `fk_worlds_owner` FOREIGN KEY (`owner_player_id`) REFERENCES `players` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `maps` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `world_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(32) NOT NULL,
    `interior` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `spectator_x` FLOAT NOT NULL DEFAULT 0,
    `spectator_y` FLOAT NOT NULL DEFAULT 0,
    `spectator_z` FLOAT NOT NULL DEFAULT 10,
    `spectator_a` FLOAT NOT NULL DEFAULT 0,
    `alpha_x` FLOAT NOT NULL DEFAULT 0,
    `alpha_y` FLOAT NOT NULL DEFAULT 0,
    `alpha_z` FLOAT NOT NULL DEFAULT 3,
    `alpha_a` FLOAT NOT NULL DEFAULT 0,
    `bravo_x` FLOAT NOT NULL DEFAULT 5,
    `bravo_y` FLOAT NOT NULL DEFAULT 0,
    `bravo_z` FLOAT NOT NULL DEFAULT 3,
    `bravo_a` FLOAT NOT NULL DEFAULT 180,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_maps_world_name` (`world_id`,`name`),
    KEY `idx_maps_world` (`world_id`),
    CONSTRAINT `fk_maps_world` FOREIGN KEY (`world_id`) REFERENCES `worlds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `loadouts` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `world_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(32) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_loadouts_world_name` (`world_id`,`name`),
    KEY `idx_loadouts_world` (`world_id`),
    CONSTRAINT `fk_loadouts_world` FOREIGN KEY (`world_id`) REFERENCES `worlds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `loadout_items` (
    `loadout_id` INT UNSIGNED NOT NULL,
    `slot` TINYINT UNSIGNED NOT NULL,
    `weapon_id` SMALLINT UNSIGNED NOT NULL,
    `ammo` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`loadout_id`,`slot`),
    CONSTRAINT `fk_loadout_items_loadout` FOREIGN KEY (`loadout_id`) REFERENCES `loadouts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `world_staff` (
    `world_id` INT UNSIGNED NOT NULL,
    `player_id` INT UNSIGNED NOT NULL,
    `role` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`world_id`,`player_id`),
    KEY `idx_world_staff_player` (`player_id`),
    CONSTRAINT `fk_world_staff_world` FOREIGN KEY (`world_id`) REFERENCES `worlds` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_world_staff_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `matches` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `world_id` INT UNSIGNED NOT NULL,
    `map_id` INT UNSIGNED DEFAULT NULL,
    `loadout_id` INT UNSIGNED DEFAULT NULL,
    `status` VARCHAR(16) NOT NULL DEFAULT 'pending',
    `team_alpha_name` VARCHAR(24) NOT NULL,
    `team_bravo_name` VARCHAR(24) NOT NULL,
    `rounds_to_win` SMALLINT UNSIGNED NOT NULL,
    `points_to_win` SMALLINT UNSIGNED NOT NULL,
    `alpha_rounds` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `bravo_rounds` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `winner_team` TINYINT UNSIGNED DEFAULT NULL,
    `started_at` DATETIME DEFAULT NULL,
    `ended_at` DATETIME DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_matches_world_created` (`world_id`,`created_at`),
    KEY `idx_matches_status` (`status`),
    CONSTRAINT `fk_matches_world` FOREIGN KEY (`world_id`) REFERENCES `worlds` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_matches_map` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_matches_loadout` FOREIGN KEY (`loadout_id`) REFERENCES `loadouts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `match_players` (
    `match_id` BIGINT UNSIGNED NOT NULL,
    `player_id` INT UNSIGNED NOT NULL,
    `team` TINYINT UNSIGNED NOT NULL,
    `kills` INT UNSIGNED NOT NULL DEFAULT 0,
    `deaths` INT UNSIGNED NOT NULL DEFAULT 0,
    `winner` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    `joined_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `left_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`match_id`,`player_id`),
    KEY `idx_match_players_player` (`player_id`,`match_id`),
    CONSTRAINT `fk_match_players_match` FOREIGN KEY (`match_id`) REFERENCES `matches` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_match_players_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `match_rounds` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `match_id` BIGINT UNSIGNED NOT NULL,
    `round_number` SMALLINT UNSIGNED NOT NULL,
    `alpha_points` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `bravo_points` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `winner_team` TINYINT UNSIGNED DEFAULT NULL,
    `started_at` DATETIME DEFAULT NULL,
    `ended_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_match_rounds_match_number` (`match_id`,`round_number`),
    CONSTRAINT `fk_match_rounds_match` FOREIGN KEY (`match_id`) REFERENCES `matches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `actor_player_id` INT UNSIGNED DEFAULT NULL,
    `target_player_id` INT UNSIGNED DEFAULT NULL,
    `world_id` INT UNSIGNED DEFAULT NULL,
    `action` VARCHAR(48) NOT NULL,
    `metadata` TEXT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_audit_logs_actor` (`actor_player_id`,`created_at`),
    KEY `idx_audit_logs_target` (`target_player_id`,`created_at`),
    KEY `idx_audit_logs_world` (`world_id`,`created_at`),
    CONSTRAINT `fk_audit_logs_actor` FOREIGN KEY (`actor_player_id`) REFERENCES `players` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_audit_logs_target` FOREIGN KEY (`target_player_id`) REFERENCES `players` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_audit_logs_world` FOREIGN KEY (`world_id`) REFERENCES `worlds` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `world_defaults` (
    `world_id` INT UNSIGNED NOT NULL,
    `map_id` INT UNSIGNED DEFAULT NULL,
    `loadout_id` INT UNSIGNED DEFAULT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`world_id`),
    KEY `idx_world_defaults_map` (`map_id`),
    KEY `idx_world_defaults_loadout` (`loadout_id`),
    CONSTRAINT `fk_world_defaults_world` FOREIGN KEY (`world_id`) REFERENCES `worlds` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_world_defaults_map` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_world_defaults_loadout` FOREIGN KEY (`loadout_id`) REFERENCES `loadouts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Development seed: one public world, map and loadout so a clean database is immediately testable.
INSERT INTO `worlds` (`virtual_world_id`,`name`,`privacy`,`status`,`team_alpha_name`,`team_bravo_name`,`rounds_to_win`,`points_to_win`,`max_players`,`enabled`)
VALUES (1,'Public CW',1,0,'Alpha','Bravo',5,10,32,1)
ON DUPLICATE KEY UPDATE `id`=LAST_INSERT_ID(`id`),`enabled`=1;
SET @default_world_id = LAST_INSERT_ID();

INSERT INTO `maps` (`world_id`,`name`,`interior`,`spectator_x`,`spectator_y`,`spectator_z`,`spectator_a`,`alpha_x`,`alpha_y`,`alpha_z`,`alpha_a`,`bravo_x`,`bravo_y`,`bravo_z`,`bravo_a`)
VALUES (@default_world_id,'Los Santos',0,1481.0,-1750.0,60.0,0.0,1481.0,-1771.0,18.8,0.0,1510.0,-1771.0,18.8,180.0)
ON DUPLICATE KEY UPDATE `id`=LAST_INSERT_ID(`id`);
SET @default_map_id = LAST_INSERT_ID();

INSERT INTO `loadouts` (`world_id`,`name`)
VALUES (@default_world_id,'Competitive')
ON DUPLICATE KEY UPDATE `id`=LAST_INSERT_ID(`id`);
SET @default_loadout_id = LAST_INSERT_ID();

INSERT INTO `loadout_items` (`loadout_id`,`slot`,`weapon_id`,`ammo`) VALUES
(@default_loadout_id,1,24,120),
(@default_loadout_id,2,31,300),
(@default_loadout_id,3,34,40)
ON DUPLICATE KEY UPDATE `weapon_id`=VALUES(`weapon_id`),`ammo`=VALUES(`ammo`);

INSERT INTO `world_defaults` (`world_id`,`map_id`,`loadout_id`)
VALUES (@default_world_id,@default_map_id,@default_loadout_id)
ON DUPLICATE KEY UPDATE `map_id`=VALUES(`map_id`),`loadout_id`=VALUES(`loadout_id`);
