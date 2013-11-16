class User < ActiveRecord::Base

  attr_accessible :login, :name, :password, :password_confirmation, :password_digest
  has_secure_password
  has_many :samples
  has_many :logs
  has_many :jobs
  has_many :cart_items
  has_many :memberships

  # Q: Why not = user.login.downcase?
  before_save { |user| user.login = login.downcase } 
  before_save :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 }
  validates :login, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  def is_admin
    g = Group.find_by_name('admin')
    return (!g || g.memberships.length == 0 || g.member?(id))
  end

  def member? group_id
    g = Group.find_by_id (group_id)
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

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end


