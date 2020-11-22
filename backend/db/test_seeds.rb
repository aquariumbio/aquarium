# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Permission.create([
  {id: 1, name: 'admin',   sort: 1},
  {id: 2, name: 'manage',  sort: 2},
  {id: 3, name: 'run',     sort: 3},
  {id: 4, name: 'design',  sort: 4},
  {id: 5, name: 'develop', sort: 5},
  {id: 6, name: 'retired', sort: 6},
])

User.create([
  {id: 1, name: 'Factory', login: 'user_1', password_digest: '$2a$04$t1STwkRNJWV35R8Sd6eGKu841QubzwdDY6Rysz55cel2xA4WikwH6', permission_ids: '.1.'},
  {id: 2, name: 'Factory', login: 'user_2', password_digest: '$2a$04$YFitBLDLIyzxOonLuB4Rd.3yPVj75r/3.uLw1ylq9geavOvsfhY4a', permission_ids: '.2.3.'},
  {id: 3, name: 'Factory', login: 'user_3', password_digest: '$2a$04$6Y3URfFd8d2ENBD00O7OLe/sAgXw13pNWyP/v9eyqIfOvjh/26/7y', permission_ids: '.1.6.'},
])
