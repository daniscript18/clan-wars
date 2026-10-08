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
