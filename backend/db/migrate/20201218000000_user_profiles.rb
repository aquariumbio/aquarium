# typed: false
class UserProfiles < ActiveRecord::Migration[4.2]
  def change
    # backup parameters table
    execute <<-SQL
      create table parameters_bak
      select * from parameters
    SQL

    # create user_profiles table from parameters_bak
    execute <<-SQL
      create table user_profiles
      select p.id, p.key, p.value, p.created_at, p.updated_at, p.user_id
      from parameters_bak p
      where id in (select max(id) as 'id' from parameters_bak up where up.key = 'email' group by up.user_id)
      or id in (select max(id) as 'id' from parameters_bak up where up.key = 'phone' group by up.user_id)
      or id in (select max(id) as 'id' from parameters_bak up where up.key = 'biofab' group by up.user_id)
      or id in (select max(id) as 'id' from parameters_bak up where up.key = 'aquarium' group by up.user_id)
      or id in (select max(id) as 'id' from parameters_bak up where up.key = 'Make new samples private' group by up.user_id)
      or id in (select max(id) as 'id' from parameters_bak up where up.key = 'Lab Name' group by up.user_id)
    SQL

    # set user_profiles.id as the primary key
    execute <<-SQL
      alter table user_profiles
      add primary key(id);
    SQL

    # set user_profiles.id to auto-increment
    execute <<-SQL
      alter table user_profiles
      modify column id int auto_increment;
    SQL

    # change 'biofab' to 'lab_agreement'
    execute <<-SQL
      update user_profiles up
      set up.key = 'lab_agreement' where up.key = 'biofab'
    SQL

    # change 'aquarium' to 'aquarium_agreement'
    execute <<-SQL
      update user_profiles up
      set up.key = 'aquarium_agreement' where up.key = 'aquarium'
    SQL

    # change 'Make new samples private' to 'new_samples_private'
    execute <<-SQL
      update user_profiles up
      set up.key = 'new_samples_private' where up.key = 'Make new samples private'
    SQL

    # change 'Lab Name' to 'lab_name'
    execute <<-SQL
      update user_profiles up
      set up.key = 'lab_name' where up.key = 'Lab Name'
    SQL

    # remove user_profile data from parameters table
    execute <<-SQL
      delete from parameters where user_id is not null
    SQL

    # drop the user_id from the parameters table
    execute <<-SQL
      alter table parameters drop user_id
    SQL

    add_index       :user_profiles, :user_id if !index_exists?(:user_profiles, :user_id)
    add_foreign_key :user_profiles, :users, on_delete: :cascade rescue nil
  end
end
