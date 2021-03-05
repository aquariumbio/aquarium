# When starting backend in test environment seeds.rb is loaded.
# This is the user seeds from test_seeds.rb
#
timenow = (Time.now.utc).to_s[0, 19]
sql = "
  INSERT INTO `users` (`id`, `name`, `login`, `created_at`, `updated_at`, `password_digest`, `remember_token`, `admin`, `key`, `permission_ids`)
  VALUES
    (1, 'Factory', 'user_1', '#{timenow}', '#{timenow}', '$2a$04$t1STwkRNJWV35R8Sd6eGKu841QubzwdDY6Rysz55cel2xA4WikwH6', NULL, 0, NULL, '.1.'),
    (2, 'Factory', 'user_2', '#{timenow}', '#{timenow}', '$2a$04$YFitBLDLIyzxOonLuB4Rd.3yPVj75r/3.uLw1ylq9geavOvsfhY4a', NULL, 0, NULL, '.2.3.'),
    (3, 'Factory', 'user_3', '#{timenow}', '#{timenow}', '$2a$04$6Y3URfFd8d2ENBD00O7OLe/sAgXw13pNWyP/v9eyqIfOvjh/26/7y', NULL, 0, NULL, '.1.6.');
"
User.connection.execute sql