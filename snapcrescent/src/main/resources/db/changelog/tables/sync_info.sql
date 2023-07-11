-- liquibase formatted sql
-- changeset navalgandhi1989:create_sync_info logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `sync_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `creation_date_time` datetime DEFAULT NULL,
  `last_modified_date_time` datetime DEFAULT NULL,
  `version` bigint DEFAULT NULL,
  `sync_count` int NOT NULL,
  PRIMARY KEY (`id`)
);
-- rollback DROP TABLE if exists sync_info;