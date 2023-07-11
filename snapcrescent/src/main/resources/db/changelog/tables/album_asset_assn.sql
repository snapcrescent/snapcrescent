-- liquibase formatted sql
-- changeset navalgandhi1989:create_album_asset_assn logicalFilePath:path-independent
CREATE TABLE IF NOT EXISTS `album_asset_assn` (  
  `album_id` BIGINT NOT NULL,
  `asset_id` BIGINT NOT NULL,
  PRIMARY KEY (`album_id`, `asset_id`) ,
  CONSTRAINT `fk_album_asset_assn_album_id` FOREIGN KEY (`album_id`) REFERENCES `snap_crescent`.`album`(`id`),
  CONSTRAINT `fk_album_asset_assn_asset_id` FOREIGN KEY (`asset_id`) REFERENCES `snap_crescent`.`asset`(`id`)
);
-- rollback DROP TABLE if exists album_asset_assn;