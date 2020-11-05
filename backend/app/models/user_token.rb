class UserToken < ActiveRecord::Base

  def self.new_token(this_ip)
    exists = true
    count = 0

    # MAKE 3 ATTEMPTS TO CREATE A TOKEN
    while exists and count < 3
      this_token = SecureRandom.hex(64) # 128 characters
      wheres = sanitize_sql_for_conditions(["ip = ? and token = ?", this_ip, this_token])
      sql = "select * from user_tokens where #{wheres} limit 1"
      exists = (UserToken.find_by_sql sql)[0]

      count += 1
    end

    # RETURN NIL IF ALL 3 ATTPEMPTS FAIL
    return nil if exists

    return this_token
  end

end
