-- liquibase formatted sql

-- changeset navalgandhi1989:alter_album_drop_password logicalFilePath:path-independent
ALTER TABLE `album` DROP COLUMN `password`;
-- rollback ALTER TABLE `album` ADD COLUMN `password` varchar(255) DEFAULT NULL AFTER `creation_date_time`;

-- changeset navalgandhi1989:alter_album_add_public_access_user_id logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `public_access_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_album_public_access_user_id` (`public_access_user_id`),
			ADD CONSTRAINT `fk_album_public_access_user_id` FOREIGN KEY (`public_access_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `album` DROP COLUMN `public_access_user_id`, DROP INDEX `idx_album_public_access_user_id`,  DROP FOREIGN KEY `fk_album_public_access_user_id`;