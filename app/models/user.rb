class User < ActiveRecord::Base

  include Budgeting

  attr_accessible :login, :name, :password, :password_confirmation, :password_digest, :key
  has_secure_password
  has_many :samples
  has_many :logs
  has_many :jobs
  has_many :metacols
  has_many :cart_items
  has_many :memberships
  has_many :tasks
  has_many :account
  has_many :user_budget_associations
  has_many :budgets, through: :user_budget_associations
  has_many :plans
  has_many :parameters
  
  before_create { |user| user.login = login.downcase }
  before_create :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 }
  validates :login, presence: true, uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }, :on => :create
  validates :password_confirmation, presence: true, :on => :create

  def is_admin
    g = Group.find_by_name('admin')
    g && Membership.where(group_id: g.id, user_id: self.id).length > 0
    # return (!g || g.memberships.length == 0 || g.member?(id))
  end

  def member? group_id
    Membership.where(group_id: group_id, user_id: self.id).length > 0
    # g && g.member?(id)
  end

  def retired?
    g = Group.find_by_name('retired')
    g && g.member?(id)
  end

  def copy u
    self.id = u.id
    self.login = u.login
    self.name = u.name
    self.password = "asdasd"
    self.password_confirmation = "asdasd"
    self.password_digest = u.password_digest
    save!
  end

  def generate_api_key
    self.key = SecureRandom.urlsafe_base64 32
    self.save
    self.key
  end

  def export
    a = attributes
    a.delete "password_digest"
    a.delete "remember_token"
    a.delete "key"
    a
  end

  def groups
    self.memberships.collect { |m| m.group }
  end

  def as_json opts={}
    j = super opts
    j[:groups] = self.groups.as_json
    j
  end

  def self.folders current_user
    { id: -1, 
      name: "Users", 
      children: (User.all.reject { |u| u.retired? }).collect { |u|
        Folder.tree(u,locked:u.id != current_user.id)
      },
      locked: true
    }
  end    

  def up_to_date

    return false if self.parameters.length == 0

    email  = self.parameters.find { |p| p.key == 'email' && p.value && p.value.length > 0 } != nil
    phone  = self.parameters.find { |p| p.key == 'phone' && p.value && p.value.length > 0 } != nil
    biofab = self.parameters.find { |p| p.key == 'biofab' && p.value && p.value == 'true' }  != nil
    aq     = self.parameters.find { |p| p.key == 'aquarium' && p.value && p.value == 'true' } != nil

    email && phone && biofab && aq

  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end


