-- liquibase formatted sql

-- changeset navalgandhi1989:alter_album_add_album_type logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `album_type` int DEFAULT NULL AFTER `name`;
-- rollback ALTER TABLE `album` DROP COLUMN `album_type`;

-- changeset navalgandhi1989:alter_user_add_active logicalFilePath:path-independent
ALTER TABLE `user` ADD COLUMN `active` BIT NULL AFTER `id`;
-- rollback ALTER TABLE `user` DROP COLUMN `active`;

-- changeset navalgandhi1989:alter_user_add_creation_date_time logicalFilePath:path-independent
ALTER TABLE `user` ADD COLUMN `creation_date_time` DATETIME NULL AFTER `active`;
-- rollback ALTER TABLE `user` DROP COLUMN `creation_date_time`;

-- changeset navalgandhi1989:alter_user_add_last_modified_date_time logicalFilePath:path-independent
ALTER TABLE `user` ADD COLUMN `last_modified_date_time` DATETIME NULL AFTER `creation_date_time`;
-- rollback ALTER TABLE `user` DROP COLUMN `last_modified_date_time`;

-- changeset navalgandhi1989:alter_user_add_version logicalFilePath:path-independent
ALTER TABLE `user` ADD COLUMN `version` BIGINT NULL AFTER `last_modified_date_time`;
-- rollback ALTER TABLE `user` DROP COLUMN `version`;

-- changeset navalgandhi1989:alter_user_add_created_by_user_id logicalFilePath:path-independent
ALTER TABLE `user` ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_user_created_by_user_id` (`created_by_user_id`),
			ADD CONSTRAINT `fk_user_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `user` DROP COLUMN `created_by_user_id`, DROP INDEX `idx_user_created_by_user_id`,  DROP FOREIGN KEY `fk_user_created_by_user_id`;