-- changeset navalgandhi1989:create_metadata logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `metadata` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `creation_date_time` datetime DEFAULT NULL,
  `last_modified_date_time` datetime DEFAULT NULL,
  `version` bigint DEFAULT NULL,
  `duration` bigint NOT NULL,
  `file_extension` varchar(255) DEFAULT NULL,
  `file_type_long_name` varchar(255) DEFAULT NULL,
  `file_type_name` varchar(255) DEFAULT NULL,
  `fstop` varchar(255) DEFAULT NULL,
  `hash` bigint NOT NULL,
  `height` bigint NOT NULL,
  `width` bigint NOT NULL,
  `internal_name` varchar(255) DEFAULT NULL,
  `location_id` bigint DEFAULT NULL,
  `mime_type` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `orientation` int NOT NULL,
  `path` varchar(255) DEFAULT NULL,
  `size` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_metadata_location_id` (`location_id`),
  CONSTRAINT `fk_metadata_location_id` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`)
);
-- rollback DROP TABLE if exists metadata;