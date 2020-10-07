# typed: false
# frozen_string_literal: true

class User < ActiveRecord::Base

  include Budgeting

  attr_accessible :login, :name, :password, :password_confirmation, :password_digest, :key
  has_secure_password
  has_many :samples
  has_many :jobs
  has_many :memberships
  has_many :account
  has_many :user_budget_associations
  has_many :budgets, through: :user_budget_associations
  has_many :plans
  has_many :parameters
  has_many :codes

  before_create { |user| user.login = login.downcase }
  before_create :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 }
  validates :login, presence: true, uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create

  def create_user_group
    group = Group.create!(name: login, description: "A group containing only user #{name}")
    group.add(self)

    group
  end

  def member?(group_id)
    memberships.where(group_id: group_id).present?
  end

  # does user have permissions for <role>
  # if retired then they lose all other permissions, but keep them in the list for reference
  def is_role?(role)
    role_ids = Role.role_ids
puts ">>> role #{role}"
puts ">>> roles #{roles}"

    if roles == "."
      return false
    elsif roles.index(".#{Role.role_ids.key("retired")}.")
      # only return true if checking "retired"
      role == "retired"
    else
      # check <role> and check "admin"
      roles.index(".#{Role.role_ids.key(role)}.") or roles.index(".#{Role.role_ids.key("admin")}.")
    end
  end

  # toggle role
  def role_toggle(user_id,role_id)
    user = User.find(user_id)
    return if !user

    role_ids = Role.role_ids
    return if !role_ids[role_id]

    if user.roles.index(".#{role_id}.")
      # replace all instances of ".<id>." with "." (there should only be one)
      user.roles.gsub!(".#{role_id}.",".")
    else
      # append "<id>." if not ".<id>."
      user.roles += ("#{role_id}.")
    end

    user.save
  end

  def self.get_roles(ins, order)

    wheres = ""
    ors = "where"
    ins.each do |i|
      wheres += "#{ors} roles like '%.#{i.to_i}.%'"
      ors = " or"
    end

    sql = "select id, login, name, roles from users #{wheres} order by #{order}"
    User.find_by_sql sql
  end

  # deprecated
  # TODO: eliminate need for this
  # keep because it is used by json_controller.current
  # otherwise should not be used
  def is_admin
    admin?
  end

  def admin?
    Group.admin&.member?(self)
  end

  def retired?
    Group.retired&.member?(self)
  end

  def retire
    m = Membership.new
    m.user_id = id
    m.group_id = Group.retired.id
    m.save
  end

  def copy(u)
    self.id = u.id
    self.login = u.login
    self.name = u.name
    self.password = 'asdasd'
    self.password_confirmation = 'asdasd'
    self.password_digest = u.password_digest
    save!
  end

  def generate_api_key
    self.key = SecureRandom.urlsafe_base64 32
    save
    key
  end

  def export
    a = attributes
    a.delete 'password_digest'
    a.delete 'remember_token'
    a.delete 'key'
    a
  end

  def groups
    memberships.collect(&:group)
  end

  def make_admin
    admin_group = Group.find_by(name: 'admin')
    admin_group.add(self)
  end

  def as_json(opts = {})
    j = super opts
    j[:groups] = groups.as_json
    j
  end

  def self.folders(current_user)
    { id: -1,
      name: 'Users',
      children: User.all.reject(&:retired?).collect do |u|
        Folder.tree(u, locked: u.id != current_user.id)
      end,
      locked: true }
  end

  def up_to_date

    return false if parameters.empty?

    email  = parameters.find { |p| p.key == 'email' && p.value && !p.value.empty? }
    phone  = parameters.find { |p| p.key == 'phone' && p.value && !p.value.empty? }
    # TODO: remove lab name specific variables and parameter
    lab = parameters.find { |p| p.key == 'lab_agreement' && p.value && p.value == 'true' }
    aq = parameters.find { |p| p.key == 'aquarium' && p.value && p.value == 'true' }

    !email.nil? && !phone.nil? && !lab.nil? && !aq.nil?

  end

  def email_address
    email_parameters = Parameter.where(user_id: id, key: 'email')
    raise "Email address not defined for user {id}: #{name}" if email_parameters.empty?

    email_parameters[0].value
  end

  # Send an email to the user
  # @param subject [String] The subject of the email
  # @param message [String] The body of the email, in html
  def send_email(subject, message)
    to_address = email_address

    sleep 0.1 # Throttle email sending rate in case this method is called from within a loop

    Thread.new do

      ses = AWS::SimpleEmailService.new

      ses.send_email(
        subject: subject,
        from: Bioturk::Application.config.email_from_address,
        to: to_address,
        body_text: "This email is better viewed with an email handler capable of rendering HTML\n\n#{message}",
        body_html: message
      )
    rescue StandardError => e
      Rails.logger.error "Emailer Error: #{e}"

    end

  end

  def stats

    job_ids = Job.where(user_id: id).pluck :id
    ops = JobAssociation.includes(operation: :operation_type).where(job_id: job_ids).collect { |j| j.operation }

    data = {}

    ops.each do |op|
      next unless op

      data[op.operation_type.name] ||= { count: 0, done: 0, error: 0 }
      data[op.operation_type.name][:count] += 1
      data[op.operation_type.name][:done] += 1 if op.done?
      data[op.operation_type.name][:error] += 1 if op.error?
    end

    data.collect { |k, v| { name: k }.merge v }.sort_by { |stat| stat[:count] }.reverse

  end

  def self.logins
    all.collect(&:login).sort
  end

  def self.select_active
    all.reject(&:retired?)
  end

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
