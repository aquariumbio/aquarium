# frozen_string_literal: true

# user_tokens table
class UserToken < ActiveRecord::Base
  # Create a new token
  #
  # @param this_ip [String] the IP address to associate with the token
  # @return a new token
  def self.new_token(this_ip)
    exists = true
    count = 0

    # Make 3 attempts to create a token
    while exists && (count < 3)
      this_token = SecureRandom.hex(16) # 32 characters
      conditions = sanitize_sql(['ip = ? and token = ?', this_ip, this_token])
      sql = "select * from user_tokens where #{conditions} limit 1"
      exists = (UserToken.find_by_sql sql)[0]

      count += 1
    end

    # Return nil if all 3 attpempts fail
    return nil if exists

    this_token
  end
end
