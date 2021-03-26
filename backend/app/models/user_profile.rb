# frozen_string_literal: true

# user_profiles table
class UserProfile < ActiveRecord::Base
  # create a user parameter
  # NOTE: used for keys
  # -  email
  # -  phone
  # -  biofab
  # -  aquarium
  # -  new_samples_private
  # -  lab_name
  # NOTE: validation occurs in user.rb
  #
  # @param user_id [Int] the user_id
  # @param key [String] the key
  # @param value [String] the value
  # @return the parameter
  def self.set_user_profile(user_id, key, value)
    wheres = sanitize_sql(['up.user_id = ? and up.key = ?', user_id, key])
    sql = "select * from user_profiles up where #{wheres} limit 1"
    if user_profile = (UserProfile.find_by_sql sql)[0]
      user_profile.value = value
    else
      user_profile = UserProfile.new({
                                       user_id: user_id,
                                       key: key,
                                       value: value
                                     })
    end
    user_profile.save
  end
end
