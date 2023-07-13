-- liquibase formatted sql

-- changeset navalgandhi1989:alter_album_add_album_thumbnail_id logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `album_thumbnail_id` BIGINT NULL AFTER `public_access_user_id`,
			ADD  KEY `idx_album_thumbnail_id` (`album_thumbnail_id`),
			ADD CONSTRAINT `fk_album_thumbnail_id` FOREIGN KEY (`album_thumbnail_id`) REFERENCES `thumbnail`(`id`);
-- rollback ALTER TABLE `album` DROP COLUMN `album_thumbnail_id`, DROP INDEX `idx_album_thumbnail_id`,  DROP FOREIGN KEY `fk_album_thumbnail_id`;