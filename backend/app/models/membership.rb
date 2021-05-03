# frozen_string_literal: true

# memberships table
class Membership < ActiveRecord::Base
  validates :user_id,   presence: true
  validates :group_id,  presence: true

  # Return a specific membership.
  #
  # @param group_id [Int] the id of the group
  # @param user_id [Int] the id of the user
  # @return the membership
  def self.find(group_id, user_id)
    wheres = sanitize_sql(['group_id = ? and user_id = ?', group_id, user_id])
    sql = "select * from memberships where #{wheres} limit 1"
    (Membership.find_by_sql sql)[0]
  end
end
