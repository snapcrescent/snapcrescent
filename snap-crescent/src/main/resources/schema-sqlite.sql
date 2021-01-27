--
-- File generated with SQLiteStudio v3.2.1 on Tue Jan 19 21:30:49 2021
--
-- Text encoding used: System
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: config
CREATE TABLE IF NOT EXISTS config (id bigint not null, config_key varchar, config_value varchar, primary key (id));

-- Table: location
CREATE TABLE IF NOT EXISTS location (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, city VARCHAR (255), country VARCHAR (255), latitude DOUBLE, longitude DOUBLE, postcode VARCHAR (255), state VARCHAR (255), town VARCHAR (255));

-- Table: metadata
CREATE TABLE IF NOT EXISTS metadata (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, created_date DATETIME (6), file_extension VARCHAR (255) NOT NULL, file_type_long_name VARCHAR (255), file_type_name VARCHAR (255), fspot VARCHAR (255), height VARCHAR (255), location_id INTEGER REFERENCES location (id), mime_type VARCHAR (255), model VARCHAR (255), name VARCHAR (255) NOT NULL, orientation INTEGER NOT NULL, path VARCHAR (255) NOT NULL, size VARCHAR (255) NOT NULL, width VARCHAR (255));

-- Table: photo
CREATE TABLE IF NOT EXISTS photo (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, metadata_id INTEGER NOT NULL REFERENCES metadata (id), thumbnail_id INTEGER NOT NULL REFERENCES thumbnail (id));

-- Table: thumbnail
CREATE TABLE IF NOT EXISTS thumbnail (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR (255) NOT NULL, path VARCHAR (255) NOT NULL);

-- Table: user
CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, first_name VARCHAR (255) NOT NULL, last_name VARCHAR (255), password VARCHAR (255) NOT NULL, username VARCHAR (255) NOT NULL);

INSERT OR IGNORE INTO config VALUES("1", "SKIP_UPLOADING", "false");

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
