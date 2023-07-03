-- liquibase formatted sql
-- changeset navalgandhi1989:create_app_config logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `app_config` (
  `id` bigint NOT NULL,
  `config_key` varchar(255) DEFAULT NULL,
  `config_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
);
-- rollback DROP TABLE if exists app_config;