-- liquibase formatted sql

-- changeset navalgandhi1989:alter_user_add_user_type logicalFilePath:path-independent
ALTER TABLE `user` ADD COLUMN `user_type` int DEFAULT NULL AFTER `password`;
-- rollback ALTER TABLE `user` DROP COLUMN `user_type`;