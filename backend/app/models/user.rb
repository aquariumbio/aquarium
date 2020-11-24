# frozen_string_literal: true

# users table
class User < ActiveRecord::Base
  has_secure_password

  # Validate a token for an optional permission_id and return the user
  #
  # @param options [Hash] options
  # @param[permission_id] [Int] an optional permission_id (default to 0 for any permission)
  #
  # @option options[:token] [String] a token
  # @option options[:ip] [String] an IP address
  #
  # @return the user
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
      # Invalid token or ip
      [401, "Invalid"]
    elsif usertoken.timenow.to_s[0, 19] < timeok
      # Session timeout
      # Delete the token
      deletes = sanitize_sql_for_conditions(['token = ? and ip = ?', option_token, option_ip])
      sql = "delete from user_tokens where #{deletes} limit 1"
      User.connection.execute sql

      [401, "Session timeout"]
    elsif !usertoken.permission?(check_permission_id)
      # Forbidden
      [403, nil]
    else
      # Valid token + ip + time

      #Reset user.timenow
      usertoken.timenow = option_timenow
      sql = "update user_tokens ut set timenow = '#{option_timenow.to_s[0, 19]}' where #{wheres} limit 1"
      User.connection.execute sql

      # Return user
      [200, { id: usertoken.user_id, name: usertoken.name, login: usertoken.login, permission_ids: usertoken.permission_ids }]
    end
  end

  # Sign out a user (delete their token)
  #
  # @param options [Hash] options
  #
  # @option options[:token] [String] the token
  # @option options[:ip] [String] the IP address associated with the token
  # @option options[:all] [String] optional "true" or "on" to sign the user out of all devices (delete all their tokens)
  #
  # @return true
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

  # Check whether user has permission_id
  #
  # @param permission_id [Int] the permission_id to check
  #
  # @return true
  def permission?(permission_id)
    # Retired - always false
    return false if permission_ids.index(".#{Permission.permission_ids.key('retired')}.")

    # Any role - always true (even if ".")
    return true if permission_id.zero?

    # Check <role_id> and check "admin"
    permission_ids.index(".#{permission_id}.") or permission_ids.index(".#{Permission.permission_ids.key('admin')}.")
  end

  # Set a specific permission for a specific user.
  #
  # @param id [Int] the id of the user
  # @param permission_id [Int] the permission_id to set
  # @param val [Boolean] true to turn permission on, false to turn permission off
  #
  # @return true
  def self.set_permission(user_id, permission_id, val)
    user = User.find_by(id: user_id)
    return false unless user

    permission_ids = Permission.permission_ids
    return false unless permission_ids[permission_id]

    if !val && user.permission_ids.index(".#{permission_id}.")
      # Replace all instances of ".<id>." with "." (there should only be one)
      user.permission_ids.gsub!(".#{permission_id}.", '.')
    elsif val && !user.permission_ids.index(".#{permission_id}.")
      # Append "<id>." if not ".<id>."
      user.permission_ids += "#{permission_id}."
    end

    user.save

    user
  end

  # Return filtered / sorted list of users with specific permission_ids.
  #
  # @param conditions [Array] list of specific permission_ids to check (empty array for any permission_id)
  # @param order [String] order by value for the SQL query
  #
  # @return filtered / sorted list of users
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
