class Group < ActiveRecord::Base

  attr_accessible :description, :name
  has_many :memberships, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.list
    users = (User.all.collect { |u| u.login }).sort
    groups = ((all.reject { |g| users.select { |u| g.name == u } != [] }).collect { |g| g.name }).sort
    { groups: groups, users: users }
  end

end
