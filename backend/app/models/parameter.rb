# frozen_string_literal: true

# parameters table
class Parameter < ActiveRecord::Base

  # create a parameter
  # NOTE: validation occurs in user.rb
  #
  # @param user_id [Int] the user_id
  # @param key [String] the key
  # @param value [String] the value
  # @return the parameter
  def self.create_or_update(user_id, key, value)
    wheres = sanitize_sql(['p.user_id = ? and p.key = ?', user_id, key ])
    sql = "select * from parameters p where #{wheres} limit 1"
    if parameter = (Parameter.find_by_sql sql)[0]
      parameter.value = value
    else
      parameter = Parameter.new( {
        user_id: user_id,
        key: key,
        value: value
      })
    end
    parameter.save
  end

end
