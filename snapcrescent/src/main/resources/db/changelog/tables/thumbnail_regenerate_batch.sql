-- liquibase formatted sql
-- changeset navalgandhi1989:create_thumbnail_regenerate_batch logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `thumbnail_regenerate_batch` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `active` BIT NULL,
  `version` BIGINT NULL,
  `start_date_time` DATETIME NULL,
  `end_date_time` DATETIME NULL,
  `creation_date_time` DATETIME NULL,
  `last_modified_date_time` DATETIME NULL,
  `created_by_user_id` BIGINT NULL,
  `batch_status` int DEFAULT NULL,
  PRIMARY KEY (`id`)
);
-- rollback DROP TABLE if exists thumbnail_regenerate_batch;