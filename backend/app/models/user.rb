# frozen_string_literal: true

# users table
class User < ActiveRecord::Base
  has_secure_password

  validates :name,             presence: true
  validates :login,            presence: true, uniqueness: { case_sensitive: false }
  validates :password,         presence: true
  validate  :custom_validator

  # Return all users.
  #
  # @return all users
  def self.find_all
    User.select("id, name, login, permission_ids").order(:name)
  end

  # Return a specific user.
  #
  # @param id [Int] the id of the user
  # @return the user
  def self.find_id(id)
    User.select("id, name, login, permission_ids").find_by(id: id)
  end

  # Create a user
  #
  # @param user [Hash] the objet type
  # @option user[:name] [String] the name
  # @option user[:password] [String] the password
  # @option user[:login] [String] the login
  # @option user[:permission_ids] [Array] the permission_ids
  # return the user
  def self.create(user)
    # Read the parameters
    name = Input.text_field(user[:name])
    login = Input.text_field(user[:login])
    password = user[:password]

    permission_ids = "."
    user[:permission_ids].to_a.each do |permission_id|
      permission_ids += "#{permission_id.to_i}."
    end

    user_new = User.new(
      name: name,
      login: login,
      password: password,
      permission_ids: permission_ids
    )

    valid = user_new.valid?
    return false, user_new.errors if !valid

    # Save the user if it is valid
    user_new.save

    return user_new, false
  end

  # Update a user's info (information tab)
  #
  # @param user [Hash] the objet type
  # @param user_data [Hash] the objet type
  # TODO: UPDATE EMAIL ADDRESS + PHONE NUMBER
  # return the user
  def update_info(user_data)
    valid = true

    # update name
    self.name = Input.text_field(user_data[:name])
    valid = false if !self.valid_name?

    # TODO: update email address (user_profile branch)
    # TODO: update phone number (user_profile branch)

    return self.errors, :ok if !valid

    # Update the user (use SQL directly to bypass password validations)
    sets = ActiveRecord::Base.sanitize_sql( [ 'name = ?', self.name ] )
    sql = "update users set #{sets} where id = #{self.id} limit 1"
    User.connection.execute sql

    # Remove password_digest from return value
    return self, :ok
  end

  # Update a user's permissions (permissions tab)
  #
  # @param user_data [Hash] the objet type
  # @option user_data[:permission_ids] [Array] array of permission ids
  # return the user
  def update_permissions(by_user_id, user_data)
    valid = true
    update_self = by_user_id == self.id

    # update permissions_ids
    # initialize permission_ids
    self.permission_ids = update_self ? ".1." : "."
    user_data[:permission_ids].to_a.each do |permission_id|
      if !Permission.permission_ids[permission_id]
        self.errors.add(:permisisons, "Permission_id #{permission_id} is invalid")
        valid = false
      elsif update_self && permission_id == 1
        # noop
      elsif update_self && permission_id == 6
        self.errors.add(:permisisons, "Cannot set retired for self")
        valid = false
      else
        self.permission_ids += "#{permission_id.to_i}."
      end
    end

    return self.errors, :ok if !valid

    # Update the user (use SQL directly to bypass password validations)
    sets = ActiveRecord::Base.sanitize_sql( [ 'permission_ids = ?', self.permission_ids ] )
    sql = "update users set #{sets} where id = #{self.id} limit 1"
    User.connection.execute sql

    # Remove password_digest from return value
    return self, :ok
  end

  # Validate a token for an optional permission_id and return the user
  #
  # @param options [Hash] options
  # @param[permission_id] [Int] an optional permission_id (default to 0 for any permission)
  #
  # @option options[:token] [String] a token
  # @option options[:ip] [String] an IP address
  # @return the user
  def self.validate_token(options, check_permission_id, check_target_id)
    option_token = options[:token].to_s
    option_ip = options[:ip].to_s
    option_timenow = Time.now.utc
    timeok = (option_timenow - ENV['SESSION_TIMEOUT'].to_i.minutes).to_s[0, 19]

    wheres = sanitize_sql(['ut.token = ? and ut.ip = ?', option_token, option_ip])

    sql = "
        select u.id, u.name, u.login, u.permission_ids, ut.timenow
        from user_tokens ut
        inner join users u on u.id = ut.user_id
        where #{wheres}
        limit 1
      "
    user = (User.find_by_sql sql)[0]

    if !user
      # Invalid token or ip
      [401, "Invalid"]
    elsif user.timenow.to_s[0, 19] < timeok
      # Session timeout
      # Delete the token
      deletes = sanitize_sql(['token = ? and ip = ?', option_token, option_ip])
      sql = "delete from user_tokens where #{deletes} limit 1"
      User.connection.execute sql

      [401, "Session timeout"]
    elsif !user.permission?(check_permission_id, check_target_id)
      # Forbidden
      [403, nil]
    else
      # Valid token + ip + time

      #Reset user.timenow
      user.timenow = option_timenow
      sql = "update user_tokens ut set timenow = '#{option_timenow.to_s[0, 19]}' where #{wheres} limit 1"
      User.connection.execute sql

      # Returns user
      [200, user.attributes.except("timenow")]
    end
  end

  # Sign out a user (delete their token)
  #
  # @param options [Hash] options
  #
  # @option options[:token] [String] the token
  # @option options[:ip] [String] the IP address associated with the token
  # @option options[:all] [String] optional "true" or "on" to sign the user out of all devices (delete all their tokens)
  # @return true
  def self.sign_out(options)
    token = options[:token].to_s
    ip = options[:ip].to_s
    all = options[:all]

    wheres = sanitize_sql(['token = ? and ip = ?', token, ip])

    sql = "select * from user_tokens where #{wheres} limit 1"
    user = (User.find_by_sql sql)[0]
    return false unless user

    sql = if all
            "delete from user_tokens where user_id = #{user.user_id}"
          else
            "delete from user_tokens where #{wheres} limit 1"
          end
    User.connection.execute sql

    true
  end

  # Check whether user has permission_id
  # permission_id ==  0: anything                                (not retired)
  # permission_id ==  1: admin                                   (not retired)
  # permission_id == -1: admin             or target_id == self  (not retired)
  # permission_id ==  2: manage  or admin                        (not retired)
  # permission_id ==  3: run     or admin                        (not retired)
  # permission_id ==  4: design  or admin                        (not retired)
  # permission_id ==  5: develop or admin                        (not retired)
  # permission_id ==  6: retired
  #
  # @param permission_id [Int] the permission_id to check
  # @param target_id [Int] the user_id of the user being updated
  # @return true
  def permission?(permission_id, target_id)
    # return false if retired
    return false if permission_ids.index(".#{Permission.permission_ids.key('retired')}.")

    # return true if permission_id == 0
    return true if permission_id.zero?

    # return true if permission_id == -1 and target_id is self
    return true if permission_id == -1 and target_id == self.id

    # Check <permission_id> and check "admin"
    # NOTE: permission_id == -1 will still validate on admin
    permission_ids.index(".#{permission_id}.") or permission_ids.index(".#{Permission.permission_ids.key('admin')}.")
  end

  # Set a specific permission for a specific user.
  #
  # @param user_id [Int] the id of the user
  # @param permission_id [Int] the permission_id to set
  # @param val [Boolean] true to turn permission on, false to turn permission off
  # @return true
  def self.set_permission(by_user_id, user_id, permission_id, val)
    # Cannot edit admin or retired for self
    return [ { error: 'Cannot edit admin or retired for self.' }, :forbidden ] if user_id == by_user_id && ((permission_id == 1) || (permission_id == 6))

    # Check user_id
    user = User.find_id(user_id)
    return [ { error: 'Invalid' }, :unauthorized ] unless user

    # Check valid permission_id
    permission_ids = Permission.permission_ids
    return [ { error: 'Invalid' }, :unauthorized ]  unless permission_ids[permission_id]

    # Update permission_id
    if !val && user.permission_ids.index(".#{permission_id}.")
      # Replace all instances of ".<id>." with "." (there should only be one)
      user.permission_ids.gsub!(".#{permission_id}.", '.')
    elsif val && !user.permission_ids.index(".#{permission_id}.")
      # Append "<id>." if not ".<id>."
      user.permission_ids += "#{permission_id}."
    end

    # Update the user (use SQL directly to bypass password validations)
    sets = sanitize_sql( [ 'permission_ids = ?', user.permission_ids ] )
    sql = "update users set #{sets} where id = #{user_id} limit 1"
    User.connection.execute sql

    return { user: user }, :ok
  end

  # Return filtered / sorted list of users with specific permission_ids.
  #
  # @param conditions [Array] list of specific permission_ids to check (empty array for any permission_id)
  # @param order [String] order by value for the SQL query
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

  private

  def custom_validator
    errors.add(:name, "name cannot contain invisible characters") if name and !TEXT.match(name)
    errors.add(:login, "login cannot contain spaces or invisible characters") if login and !TEXT_NO_SPACES.match(login)
    errors.add(:password, "password must be at least 10 characters") if password.to_s.length < 10
    errors.add(:password, "passsword cannot contain spaces or invisible characters") if password and !TEXT_NO_SPACES.match(password)
  end

  def valid_name?
    User.validators_on(:name).each do |validator|
      validator.validate_each(self, :name, self.name)
    end

    # Return true if there are no errors (i.e., errors.to_json == "{}")
    self.errors.to_json == "{}"
  end
end
