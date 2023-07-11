-- liquibase formatted sql
-- changeset navalgandhi1989:create_thumbnail logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `thumbnail` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `creation_date_time` datetime DEFAULT NULL,
  `last_modified_date_time` datetime DEFAULT NULL,
  `version` bigint DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
);
-- rollback DROP TABLE if exists thumbnail;