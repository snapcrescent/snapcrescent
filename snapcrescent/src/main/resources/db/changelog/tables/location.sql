-- liquibase formatted sql
-- changeset navalgandhi1989:create_location logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `location` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `creation_date_time` datetime DEFAULT NULL,
  `last_modified_date_time` datetime DEFAULT NULL,
  `version` bigint DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `town` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
);
-- rollback DROP TABLE if exists location;