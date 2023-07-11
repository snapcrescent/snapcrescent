-- liquibase formatted sql

-- changeset navalgandhi1989:alter_asset_add_created_by_user_id logicalFilePath:path-independent
ALTER TABLE `asset` ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_asset_created_by_user_id` (`created_by_user_id`),
			ADD CONSTRAINT `fk_asset_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `asset` DROP COLUMN `created_by_user_id`, DROP INDEX `idx_asset_created_by_user_id`,  DROP FOREIGN KEY `fk_asset_created_by_user_id`;

-- changeset navalgandhi1989:alter_album_drop_created_date logicalFilePath:path-independent
ALTER TABLE `album` DROP COLUMN `created_date`;
-- rollback ALTER TABLE `album` ADD COLUMN `created_date` varchar(255) DEFAULT NULL;

-- changeset navalgandhi1989:alter_album_add_active logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `active` BIT NULL AFTER `id`;
-- rollback ALTER TABLE `album` DROP COLUMN `active`;

-- changeset navalgandhi1989:alter_album_add_creation_date_time logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `creation_date_time` DATETIME NULL AFTER `name`;
-- rollback ALTER TABLE `album` DROP COLUMN `creation_date_time`;

-- changeset navalgandhi1989:alter_album_add_password logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `password` varchar(255) DEFAULT NULL AFTER `creation_date_time`;
-- rollback ALTER TABLE `album` DROP COLUMN `password`;

-- changeset navalgandhi1989:alter_album_add_public_access logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `public_access` BIT NULL AFTER `password`;
-- rollback ALTER TABLE `album` DROP COLUMN `public_access`;

-- changeset navalgandhi1989:alter_album_add_last_modified_date_time logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `last_modified_date_time` DATETIME NULL AFTER `public_access`;
-- rollback ALTER TABLE `album` DROP COLUMN `last_modified_date_time`;

-- changeset navalgandhi1989:alter_album_add_version logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `version` BIGINT NULL AFTER `last_modified_date_time`;
-- rollback ALTER TABLE `album` DROP COLUMN `version`;

-- changeset navalgandhi1989:alter_album_add_created_by_user_id logicalFilePath:path-independent
ALTER TABLE `album` ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_album_created_by_user_id` (`created_by_user_id`),
			ADD CONSTRAINT `fk_album_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `album` DROP COLUMN `created_by_user_id`, DROP INDEX `idx_album_created_by_user_id`,  DROP FOREIGN KEY `fk_album_created_by_user_id`;

-- changeset navalgandhi1989:alter_location_add_created_by_user_id logicalFilePath:path-independent
ALTER TABLE `location` ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_location_created_by_user_id` (`created_by_user_id`),
			ADD CONSTRAINT `fk_location_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `location` DROP COLUMN `created_by_user_id`, DROP INDEX `idx_location_created_by_user_id`,  DROP FOREIGN KEY `fk_location_created_by_user_id`;


-- changeset navalgandhi1989:alter_metadata_add_created_by_user_id logicalFilePath:path-independent
ALTER TABLE `metadata` ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_metadata_created_by_user_id` (`created_by_user_id`),
			ADD CONSTRAINT `fk_metadata_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `metadata` DROP COLUMN `created_by_user_id`, DROP INDEX `idx_metadata_created_by_user_id`,  DROP FOREIGN KEY `fk_metadata_created_by_user_id`;

-- changeset navalgandhi1989:alter_thumbnail_add_created_by_user_id logicalFilePath:path-independent
ALTER TABLE `thumbnail` ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `version`,
			ADD  KEY `idx_thumbnail_created_by_user_id` (`created_by_user_id`),
			ADD CONSTRAINT `fk_thumbnail_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`);
-- rollback ALTER TABLE `thumbnail` DROP COLUMN `created_by_user_id`, DROP INDEX `idx_thumbnail_created_by_user_id`,  DROP FOREIGN KEY `fk_thumbnail_created_by_user_id`;