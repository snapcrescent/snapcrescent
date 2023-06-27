INSERT IGNORE INTO app_config VALUES("1", "SKIP_UPLOADING", "false");
INSERT IGNORE INTO app_config VALUES("2", "DEMO_JWT", "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkZW1vIiwiZXhwIjoxOTI1OTgzNTI1LCJpYXQiOjE2MTA2MjM1MjV9.DfgFn1YkN8yuhp5vtZmVZotfJsNXREYIhqnx6KP2OeMESapphWuSDbWe_B_1yrN4ZmBhZs-T1cqJQOvrP-7BKQ");
INSERT IGNORE INTO app_config VALUES("3", "HOST_ADDRESS", "localhost");

INSERT IGNORE INTO user (`id`,`first_name`, `last_name`, `password`, `username`	) VALUES("1","Admin","User", "$2y$10$15SQK6ocohQ/GW8suLd.W.dVn8Z4ZHdfbs.4Q7A0CkI5YNH2r.AqS", "admin");