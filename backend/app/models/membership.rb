# memberships table
class Membership < ActiveRecord::Base

  validates :user_id,   presence: true
  validates :group_id,  presence: true

  # Return a specific membership.
  #
  # @param membership_id [Int] the id of the membership
  # @param group_id [Int] the id of the group
  # @return the membership
  def self.find_id(membership_id, group_id)
    wheres = sanitize_sql(['id = ? and group_id = ?', membership_id, group_id ])
    sql = "select * from memberships where #{wheres} limit 1"
    (Membership.find_by_sql sql)[0]
  end
end
