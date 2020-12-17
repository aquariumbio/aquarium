# frozen_string_literal: true

# user_parameters table
class UserParameter < ActiveRecord::Base
  # create a user parameter
  # NOTE: used for keys
  # -  email
  # -  phone
  # -  biofab
  # -  aquarium
  # -  new_samples_private
  # NOTE: validation occurs in user.rb
  #
  # @param user_id [Int] the user_id
  # @param key [String] the key
  # @param value [String] the value
  # @return the parameter
  def self.set_user_parameter(user_id, key, value)
    wheres = sanitize_sql(['up.user_id = ? and up.key = ?', user_id, key ])
    sql = "select * from user_parameters up where #{wheres} limit 1"
    if user_parameter = (UserParameter.find_by_sql sql)[0]
      user_parameter.value = value
    else
      user_parameter = UserParameter.new( {
        user_id: user_id,
        key: key,
        value: value
      })
    end
    user_parameter.save
  end
end
