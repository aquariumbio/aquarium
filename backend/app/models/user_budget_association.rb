# user_budget_associations table
class UserBudgetAssociation < ActiveRecord::Base
  validates :user_id,   presence: true
  validates :budget_id, presence: true
  validates :quota,     presence: true

  # Return a specific user_budget.
  #
  # @param user_budget_id [Int] the id of the user_budget_association
  # @param budget_id [Int] the id of the budget
  # @return the user_budget
  def self.find_id(user_budget_id, budget_id)
    wheres = sanitize_sql(['id = ? and budget_id = ?', user_budget_id, budget_id])
    sql = "select * from user_budget_associations where #{wheres} limit 1"
    (UserBudgetAssociation.find_by_sql sql)[0]
  end
end
