# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# We use find_or_create_by to make seeding idempotent

Permission.find_or_create_by( id: 1, name: 'admin', sort: 1 )
Permission.find_or_create_by( id: 2, name: 'manage',  sort: 2 )
Permission.find_or_create_by( id: 3, name: 'run',     sort: 3 )
Permission.find_or_create_by( id: 4, name: 'design',  sort: 4 )
Permission.find_or_create_by( id: 5, name: 'develop', sort: 5 )
Permission.find_or_create_by( id: 6, name: 'retired', sort: 6 )

# Cannot use find_or_create_by for User b/c cannot do a where clause on password
# Note that passwords must be 10 visible characters
User.create(id: 1, name: 'Alice Neptune', login: 'neptune', password: 'aquarium123', permission_ids: '.1.') unless User.find_by(login: 'neptune')