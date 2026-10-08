-- Password hashing migration: preserve legacy SHA-256 hashes and allow bcrypt.
SET @ddl = IF(
  EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'PasswordAlgo'),
  'SELECT 1',
  'ALTER TABLE `players` ADD COLUMN `PasswordAlgo` varchar(16) NOT NULL DEFAULT ''legacy_sha256'' AFTER `PasswordSalt`'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `players`
  MODIFY COLUMN `PasswordHash` varchar(128) DEFAULT NULL,
  MODIFY COLUMN `PasswordSalt` varchar(64) DEFAULT NULL;

UPDATE `players`
SET `PasswordAlgo` = CASE
  WHEN `PasswordHash` LIKE '$2%' THEN 'bcrypt'
  ELSE 'legacy_sha256'
END
WHERE `PasswordHash` IS NOT NULL AND `PasswordHash` <> '';

UPDATE `players`
SET `Password` = NULL
WHERE `PasswordHash` IS NOT NULL AND `PasswordHash` <> '';
