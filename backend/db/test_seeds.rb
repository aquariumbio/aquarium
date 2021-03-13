# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Permission.create([
                    { id: 1, name: 'admin', sort: 1 },
                    { id: 2, name: 'manage',  sort: 2 },
                    { id: 3, name: 'run',     sort: 3 },
                    { id: 4, name: 'design',  sort: 4 },
                    { id: 5, name: 'develop', sort: 5 },
                    { id: 6, name: 'retired', sort: 6 },
                  ])

# Cannot use User.create because the method is overridden
timenow = (Time.now.utc).to_s[0, 19]
sql = "
  INSERT INTO `users` (`id`, `name`, `login`, `created_at`, `updated_at`, `password_digest`, `remember_token`, `admin`, `key`, `permission_ids`)
  VALUES
    (1, 'user_admin', 'user_admin', '#{timenow}', '#{timenow}', '$2a$12$7OSsbeNoRkx1pgALaVE/Ru5hcVmZxVKoCoMg/MTJnsRwqfH/34Nfm', NULL, 0, NULL, '.1.'),
    (2, 'user_manage', 'user_manage', '#{timenow}', '#{timenow}', '$2a$12$QpQTu72pwuFTTnrnAGCVwewpd4oFWl3fxGZAIaQG12fI54G.14VOy', NULL, 0, NULL, '.2.'),
    (3, 'user_run', 'user_run', '#{timenow}', '#{timenow}', '$2a$12$4ZOrJDTUdC22e/XbhvVwbuLTlRSgxqBhX1/lyD5lITk.QCeqdnTdq', NULL, 0, NULL, '.3.'),
    (4, 'user_design', 'user_design', '#{timenow}', '#{timenow}', '$2a$12$MGLq.g4I9AVSdaG1q196BuDLTysBUfJocXTsWpJmVktycSAjfRo8a', NULL, 0, NULL, '.4.'),
    (5, 'user_develop', 'user_develop', '#{timenow}', '#{timenow}', '$2a$12$2w7.1JYbSot6pORrivoQ9O2TFfN1TK5dzwyWf9E7a5M6TFLOiNN36', NULL, 0, NULL, '.5.'),
    (6, 'user_retired', 'user_retired', '#{timenow}', '#{timenow}', '$2a$12$XkO1mbW4.bjNzDTijEYnyuVBmMA5mwBEgy9TKclL4L89CzFnlb92y', NULL, 0, NULL, '.1.2.3.4.5.6.');
"
User.connection.execute sql
