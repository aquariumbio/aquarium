# typed: false
# frozen_string_literal: true

class UserBudgetAssociation < ActiveRecord::Base

  attr_accessible :budget_id, :disabled, :quota, :user_id

  belongs_to :user
  belongs_to :budget

end
