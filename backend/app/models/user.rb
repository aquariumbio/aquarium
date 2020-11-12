# frozen_string_literal: true

# USERS TABLE
class User < ActiveRecord::Base
  has_secure_password

  # VALIDATE TOKEN (CHECK AGAINST OPTIONAL PERMISSION_ID)
  # CHECK_PERMISSION_ID DEFAULT TO 0 FOR 'ANY'
  def self.validate_token(options, check_permission_id = 0)
    option_token = options[:token].to_s
    option_ip = options[:ip].to_s
    option_timenow = Time.now.utc
    timeok = (option_timenow - ENV['SESSION_TIMEOUT'].to_i.minutes).to_s[0, 19]

    wheres = sanitize_sql_for_conditions(['ut.token = ? and ut.ip = ?', option_token, option_ip])

    sql = "
        select ut.*, u.name, u.login, u.permission_ids
        from user_tokens ut
        inner join users u on u.id = ut.user_id
        where #{wheres}
        limit 1
      "
    usertoken = (User.find_by_sql sql)[0]

    if !usertoken
      # INVALID TOKEN OR IP
      [400, nil]
    elsif usertoken.timenow.to_s[0, 19] < timeok
      # SESSION TIMEOUT / REMOVE TOKEN
      sql = "delete from user_tokens ut where #{wheres} limit 1"
      User.connection.execute sql

      [401, nil]
    elsif !usertoken.permission?(check_permission_id)
      # FORBIDDEN / DO NOT RESET USER.TIMENOW
      [403, nil]
    else
      # VALID TOKEN + IP + TIME / RESET USER.TIMENOW
      usertoken.timenow = option_timenow
      sql = "update user_tokens ut set timenow = '#{option_timenow.to_s[0, 19]}' where #{wheres} limit 1"
      User.connection.execute sql

      [200, { id: usertoken.user_id, name: usertoken.name, login: usertoken.login, permission_ids: usertoken.permission_ids }]
    end
  end

  # SIGN OUT
  # ALL = SIGN OUT OF ALL DEVICES
  def self.sign_out(options)
    token = options[:token].to_s
    ip = options[:ip].to_s
    all = options[:all]

    wheres = sanitize_sql_for_conditions(['token = ? and ip = ?', token, ip])

    sql = "select * from user_tokens where #{wheres} limit 1"
    usertoken = (User.find_by_sql sql)[0]
    return false unless usertoken

    sql = if all
            "delete from user_tokens where user_id = #{usertoken.user_id}"
          else
            "delete from user_tokens where #{wheres} limit 1"
          end
    User.connection.execute sql

    true
  end

  # DOES USER HAVE PERMISSIONS FOR <ROLE_ID>
  def permission?(permission_id)
    # RETIRED - ALWAYS FALSE
    return false if permission_ids.index(".#{Permission.permission_ids.key('retired')}.")

    # ANY ROLE - ALWAYS TRUE (EVEN IF ".")
    return true if permission_id.zero?

    # CHECK <ROLE_ID> AND CHECK "ADMIN"
    permission_ids.index(".#{permission_id}.") or permission_ids.index(".#{Permission.permission_ids.key('admin')}.")
  end

  # SET ROLE
  def self.set_permission(user_id, permission_id, val)
    user = User.find_by(id: user_id)
    return false unless user

    permission_ids = Permission.permission_ids
    return false unless permission_ids[permission_id]

    if !val && user.permission_ids.index(".#{permission_id}.")
      # REPLACE ALL INSTANCES OF ".<ID>." WITH "." (THERE SHOULD ONLY BE ONE)
      user.permission_ids.gsub!(".#{permission_id}.", '.')
    elsif val && !user.permission_ids.index(".#{permission_id}.")
      # APPEND "<ID>." IF NOT ".<ID>."
      user.permission_ids += "#{permission_id}."
    end

    user.save

    user
  end

  def self.get_users_by_permission(conditions, order)
    wheres = ''
    ors = 'where'
    conditions.each do |i|
      wheres += "#{ors} permission_ids like '%.#{i.to_i}.%'"
      ors = ' or'
    end

    sql = "select id, login, name, permission_ids from users #{wheres} order by #{order}"
    User.find_by_sql sql
  end
end
