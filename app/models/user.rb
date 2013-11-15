class User < ActiveRecord::Base

  attr_accessible :login, :name, :password, :password_confirmation
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
    Group.find_by_name('admin').member?(id)
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end



end


