class Group < ActiveRecord::Base

  attr_accessible :description, :name
  has_many :memberships, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.list
    retired = find_by_name('retired')
    rid = retired ? retired.id : -1
    users = (User.all.collect { |u| u.login }).sort
    active_users = ((User.all.reject {|u| u.member? rid }).collect { |u| u.login }).sort
    groups = ((all.reject { |g| g.name == 'retired' || users.select { |u| g.name == u } != [] }).collect { |g| g.name }).sort
    { groups: groups, users: active_users }
  end

  def member? uid
    (self.memberships.select { |m| m.user_id == uid }) != []
  end

end
