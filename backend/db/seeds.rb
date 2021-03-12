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
    (1, 'neptune', 'neptune', '#{timenow}', '#{timenow}', '$2a$12$6l3iReiogPbGbLTcDj47aubRky1ZqFBRPYPNkrp/2UA/ivIDMzRYW', NULL, 0, NULL, '.1.');
"
