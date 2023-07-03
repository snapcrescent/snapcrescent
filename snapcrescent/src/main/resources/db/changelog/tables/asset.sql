-- liquibase formatted sql
-- changeset navalgandhi1989:create_asset logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `asset` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `creation_date_time` datetime DEFAULT NULL,
  `last_modified_date_time` datetime DEFAULT NULL,
  `version` bigint DEFAULT NULL,
  `asset_type` int DEFAULT NULL,
  `favorite` bit(1) DEFAULT NULL,
  `metadata_id` bigint NOT NULL,
  `thumbnail_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_asset_metadata_id` (`metadata_id`),
  KEY `idx_asset_thumbnail_id` (`thumbnail_id`),
  CONSTRAINT `fk_asset_metadata_id` FOREIGN KEY (`metadata_id`) REFERENCES `metadata` (`id`),
  CONSTRAINT `fk_asset_thumbnail_id` FOREIGN KEY (`thumbnail_id`) REFERENCES `thumbnail` (`id`)
);
-- rollback DROP TABLE if exists asset;