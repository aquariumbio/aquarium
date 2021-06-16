# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# We use find_or_create_by to make seeding idempotent

Permission.find_or_create_by( id: 1, name: 'admin',   sort: 1 )
Permission.find_or_create_by( id: 2, name: 'manage',  sort: 2 )
Permission.find_or_create_by( id: 3, name: 'run',     sort: 3 )
Permission.find_or_create_by( id: 4, name: 'design',  sort: 4 )
Permission.find_or_create_by( id: 5, name: 'develop', sort: 5 )
Permission.find_or_create_by( id: 6, name: 'retired', sort: 6 )

FieldTypeSort.find_or_create_by( id: 1, ftype: 'string',  sort: 1 )
FieldTypeSort.find_or_create_by( id: 2, ftype: 'number',  sort: 2 )
FieldTypeSort.find_or_create_by( id: 3, ftype: 'url',     sort: 3 )
FieldTypeSort.find_or_create_by( id: 4, ftype: 'sample',  sort: 4 )

# Cannot use find_or_create_by for User b/c cannot do a where clause on password
# Note that passwords must be 10 visible characters
User.create( id:1, name: 'user_admin', login: 'user_admin', password: 'aquarium123', permission_ids: '.1.') unless User.find_by(login: 'user_admin')
User.create( id:2, name: 'user_manage', login: 'user_manage', password: 'aquarium123', permission_ids: '.2.') unless User.find_by(login: 'user_manage')
User.create( id:3, name: 'user_run', login: 'user_run', password: 'aquarium123', permission_ids: '.3.') unless User.find_by(login: 'user_run')
User.create( id:4, name: 'user_design', login: 'user_design', password: 'aquarium123', permission_ids: '.4.') unless User.find_by(login: 'user_design')
User.create( id:5, name: 'user_develop', login: 'user_develop', password: 'aquarium123', permission_ids: '.5.') unless User.find_by(login: 'user_develop')
User.create( id:6, name: 'user_retired', login: 'user_retired', password: 'aquarium123', permission_ids: '.1.2.3.4.5.6.') unless User.find_by(login: 'user_retired')
User.create( id:7, name: 'test_user', login: 'test_user', password: 'aquarium123', permission_ids: '.1.') unless User.find_by(login: 'test_user')

