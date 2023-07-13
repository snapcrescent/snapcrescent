-- liquibase formatted sql
-- changeset navalgandhi1989:create_album_user_assn logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `album_user_assn` (  
  `album_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`album_id`, `user_id`) ,
  CONSTRAINT `fk_album_user_assn_album_id` FOREIGN KEY (`album_id`) REFERENCES `album`(`id`),
  CONSTRAINT `fk_album_user_assn_user_id` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
);
-- rollback DROP TABLE if exists album_user_assn;