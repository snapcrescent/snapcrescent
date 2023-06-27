REPLACE INTO app_config VALUES("1", "DEMO_APP", "false");
REPLACE INTO app_config VALUES("2", "DEMO_USERNAME", "demo-account");
REPLACE INTO app_config VALUES("3", "DEMO_PASSWORD", "demo-account");



INSERT IGNORE INTO user (`id`,`first_name`, `last_name`, `password`, `username`	) VALUES("1","Admin","User", "$2y$10$15SQK6ocohQ/GW8suLd.W.dVn8Z4ZHdfbs.4Q7A0CkI5YNH2r.AqS", "admin");

INSERT IGNORE INTO user (`id`,`first_name`, `last_name`, `password`, `username`	) VALUES("2","Demo","User", "$2a$04$H17plbyjUXImsKiBCo6O5uf0b0287ATzDCrY2TfYzWnJ1v/PEhkz6", "demo-account");