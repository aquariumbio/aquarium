class User < ActiveRecord::Base

    has_secure_password

    def self.validate_token(options)
      option_token = options[:token].to_s
      option_ip = options[:ip].to_s
      option_timenow = Time.now.utc
      timeok = (option_timenow - 15.minutes).to_s[0,19]

      wheres = sanitize_sql_for_conditions(["ut.token = ? and ut.ip = ?", option_token, option_ip])

      sql = "
        select ut.*, u.name, u.login
        from user_tokens ut
        inner join users u on u.id = ut.user_id
        where #{wheres}
        limit 1
      "
      usertoken = (User.find_by_sql sql)[0]

      if !usertoken
        # INVALID TOKEN OR IP
        return 400, nil
      elsif usertoken.timenow.to_s[0,19] < timeok
        # SESSION TIMEOUT / RESET USER
        sql = "delete from user_tokens ut where #{wheres} limit 1"
        User.connection.execute sql

        return 401, nil
      else
        # VALID TOKEN + IP + TIME / RESET USER.TIMENOW
        usertoken.timenow = option_timenow
        sql = "update user_tokens ut set timenow = '#{option_timenow.to_s[0,19]}' where #{wheres} limit 1"
        User.connection.execute sql

        return 200, { :id => usertoken.user_id, :name => usertoken.name, :login => usertoken.login }
      end
    end

    def self.sign_out(options)
      token = options[:token].to_s
      ip = options[:ip].to_s
      all = options[:all]

      wheres = sanitize_sql_for_conditions(["token = ? and ip = ?", token, ip])

      sql = "select * from user_tokens where #{wheres} limit 1"
      usertoken = (User.find_by_sql sql)[0]
      return false if !usertoken

      if all
        sql = "delete from user_tokens where user_id = #{usertoken.user_id}"
        User.connection.execute sql
      else
        sql = "delete from user_tokens ut where #{wheres} limit 1"
        User.connection.execute sql
      end

      return true
    end

end
