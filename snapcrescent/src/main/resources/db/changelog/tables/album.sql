-- changeset navalgandhi1989:create_album logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `album` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
);
-- rollback DROP TABLE if exists album;