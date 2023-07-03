-- liquibase formatted sql
-- changeset navalgandhi1989:app_config runOnChange:True logicalFilePath:path-independent
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE app_config;
INSERT INTO app_config VALUES('1', 'DEMO_APP', 'false');
INSERT INTO app_config VALUES('2', 'DEMO_USERNAME', 'demo-account');
INSERT INTO app_config VALUES('3', 'DEMO_PASSWORD', 'demo-password');


-- liquibase formatted sql
-- changeset navalgandhi1989:user runOnChange:True logicalFilePath:path-independent
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE user;
INSERT INTO user (`id`,`first_name`, `last_name`, `password`, `username`) VALUES('1','Admin','User', '$2y$10$15SQK6ocohQ/GW8suLd.W.dVn8Z4ZHdfbs.4Q7A0CkI5YNH2r.AqS', 'admin');

INSERT INTO user (`id`,`first_name`, `last_name`, `password`, `username`) VALUES('2','Demo','User', '$2a$04$aEZriaEgOFangaXFmMwkt.9yr6bXewo2kmJlYW4S73L4YJrsnvn8W', 'demo-account');



-- liquibase formatted sql
-- changeset navalgandhi1989:album runOnChange:True logicalFilePath:path-independent
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE album;
INSERT INTO album (`id`,`name`, `public_access`) VALUES('1','My Album',b'0');