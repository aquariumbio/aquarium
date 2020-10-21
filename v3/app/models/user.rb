class User < ActiveRecord::Base

    has_secure_password

    def self.validate_token(options, check_role_id = false)
      option_token = options[:token].to_s
      option_ip = options[:ip].to_s
      option_timenow = Time.now.utc
      timeok = (option_timenow - 15.minutes).to_s[0,19]

      wheres = sanitize_sql_for_conditions(["ut.token = ? and ut.ip = ?", option_token, option_ip])

      sql = "
        select ut.*, u.name, u.login, u.role_ids
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
        # SESSION TIMEOUT / REMOVE TOKEN
        sql = "delete from user_tokens ut where #{wheres} limit 1"
        User.connection.execute sql

        return 401, nil
      elsif check_role_id and !usertoken.is_role?(check_role_id)
        # FORBIDDEN / DO NOT RESET USER.TIMENOW
        return 403, nil
      else
        # VALID TOKEN + IP + TIME / RESET USER.TIMENOW
        usertoken.timenow = option_timenow
        sql = "update user_tokens ut set timenow = '#{option_timenow.to_s[0,19]}' where #{wheres} limit 1"
        User.connection.execute sql

        return 200, { :id => usertoken.user_id, :name => usertoken.name, :login => usertoken.login, :role_ids => usertoken.role_ids }
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

    # DOES USER HAVE PERMISSIONS FOR <ROLE_ID>
    # IF RETIRED THEN THEY LOSE ALL PERMISSIONS
    def is_role?(role_id)
      if role_ids == "." or  role_ids.index(".#{Role.role_ids.key("retired")}.")
        return false
      else
        # CHECK <ROLE_ID> AND CHECK "ADMIN"
        role_ids.index(".#{role_id}.") or role_ids.index(".#{Role.role_ids.key("admin")}.")
      end
    end

    # SET ROLE
    def self.set_role(user_id,role_id,val)
      user = User.find_by(id: user_id)
      return false if !user

      role_ids = Role.role_ids
      return false if !role_ids[role_id]

      if !val and user.role_ids.index(".#{role_id}.")
        # REPLACE ALL INSTANCES OF ".<ID>." WITH "." (THERE SHOULD ONLY BE ONE)
        user.role_ids.gsub!(".#{role_id}.",".")
      elsif val and !user.role_ids.index(".#{role_id}.")
        # APPEND "<ID>." IF NOT ".<ID>."
        user.role_ids += ("#{role_id}.")
      end

      user.save

      return user
    end

    def self.get_roles(ins, order)
      wheres = ""
      ors = "where"
      ins.each do |i|
        wheres += "#{ors} role_ids like '%.#{i.to_i}.%'"
        ors = " or"
      end

      sql = "select id, login, name, role_ids from users #{wheres} order by #{order}"
      User.find_by_sql sql
    end

end
