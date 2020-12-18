# typed: false
class CreateViewUsers < ActiveRecord::Migration

  # View used to get extended user data (including parameters)
  def change

    # VIEW - CURRENT JOB ASSIGNMENT
    execute <<-SQL
      create view view_users as
      select
        u.id, u.name, u.login, u.permission_ids,
        up_email.value as 'email',
        up_phone.value as 'phone',
        up_lab.value as 'lab_agreement',
        up_aquarium.value as 'aquarium_agreement',
        up_private.value as 'new_samples_private',
        up_labname.value as 'lab_name'
      from users u
      left join user_profiles up_email on up_email.user_id = u.id and up_email.key = 'email'
      left join user_profiles up_phone on up_phone.user_id = u.id and up_phone.key = 'phone'
      left join user_profiles up_lab on up_lab.user_id = u.id and up_lab.key = 'lab_agreement'
      left join user_profiles up_aquarium on up_aquarium.user_id = u.id and up_aquarium.key = 'aquarium_agreement'
      left join user_profiles up_private on up_private.user_id = u.id and up_private.key = 'new_samples_private'
      left join user_profiles up_labname on up_labname.user_id = u.id and up_labname.key = 'lab_name'
    SQL

  end

end
