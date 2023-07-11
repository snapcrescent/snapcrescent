-- liquibase formatted sql
-- changeset navalgandhi1989:create_user logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_username` (`username`)
);
-- rollback DROP TABLE if exists user;