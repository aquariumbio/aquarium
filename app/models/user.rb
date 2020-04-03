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

  # deprecated
  def is_admin
    admin?
  end

  def admin?
    Group.admin&.member?(id)
  end

  def member?(group_id)
    !Membership.where(group_id: group_id, user_id: id).empty?
  end

  def retired?
    Group.retired&.member?(id)
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
    biofab = parameters.find { |p| p.key == 'biofab' && p.value && p.value == 'true' }
    aq     = parameters.find { |p| p.key == 'aquarium' && p.value && p.value == 'true' }

    !email.nil? && !phone.nil? && !biofab.nil? && !aq.nil?

  end

  # Send an email to the user
  # @param subject [String] The subject of the email
  # @param message [String] The body of the email, in html
  def send_email(subject, message)

    email_parameters = Parameter.where(user_id: id, key: 'email')
    raise "Email address not defined for user {id}: #{name}" if email_parameters.empty?

    to_address = email_parameters[0].value

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
