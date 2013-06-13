class User < ActiveRecord::Base

  attr_accessible :login, :name, :password, :password_confirmation

  has_secure_password

  # Q: Why not user.login.downcase?
  before_save { |user| user.login = login.downcase } 

  validates :name,  presence: true, length: { maximum: 50 }
  validates :login, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

end
