-- liquibase formatted sql
-- changeset navalgandhi1989:app_config runOnChange:True logicalFilePath:path-independent
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE app_config;
INSERT INTO app_config VALUES('1', 'DEMO_APP', 'false');
INSERT INTO app_config VALUES('2', 'DEMO_USERNAME', 'demo-account');
INSERT INTO app_config VALUES('3', 'DEMO_PASSWORD', 'demo-password');