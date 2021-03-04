mysql -uroot -Nse "select table_name from information_schema.tables where table_schema = 'aquarium_test' and table_type = 'BASE TABLE'" | \
while read table; do mysql -uroot -e "delete from $table" aquarium_test; mysql -uroot -e "alter table $table auto_increment = 1" aquarium_test; done
mysql -uroot -e " \
use aquarium_test; \
INSERT INTO \`schema_migrations\` (\`version\`) \
VALUES \
('20201030000000'), \
('20201218000000'), \
('20201218000010'); \
INSERT INTO \`users\` (\`id\`, \`name\`, \`login\`, \`created_at\`, \`updated_at\`, \`password_digest\`, \`remember_token\`, \`admin\`, \`key\`, \`permission_ids\`) \
VALUES \
(1, 'Factory', 'user_1', '2021-02-22 21:03:11', '2021-02-22 21:03:11', '$2a$04$t1STwkRNJWV35R8Sd6eGKu841QubzwdDY6Rysz55cel2xA4WikwH6', NULL, 0, NULL, '.1.'), \
(2, 'Factory', 'user_2', '2021-02-22 21:03:11', '2021-02-22 21:03:11', '$2a$04$YFitBLDLIyzxOonLuB4Rd.3yPVj75r/3.uLw1ylq9geavOvsfhY4a', NULL, 0, NULL, '.2.3.'), \
(3, 'Factory', 'user_3', '2021-02-22 21:03:11', '2021-02-22 21:03:11', '$2a$04$6Y3URfFd8d2ENBD00O7OLe/sAgXw13pNWyP/v9eyqIfOvjh/26/7y', NULL, 0, NULL, '.1.6.'); \
INSERT INTO \`permissions\` (\`id\`, \`name\`, \`sort\`, \`created_at\`, \`updated_at\`) \
VALUES \
(1, 'admin', 1, '2021-02-22 21:03:11', '2021-02-22 21:03:11'), \
(2, 'manage', 2, '2021-02-22 21:03:11', '2021-02-22 21:03:11'), \
(3, 'run', 3, '2021-02-22 21:03:11', '2021-02-22 21:03:11'), \
(4, 'design', 4, '2021-02-22 21:03:11', '2021-02-22 21:03:11'), \
(5, 'develop', 5, '2021-02-22 21:03:11', '2021-02-22 21:03:11'), \
(6, 'retired', 6, '2021-02-22 21:03:11', '2021-02-22 21:03:11'); \
"
