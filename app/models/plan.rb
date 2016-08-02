class Plan < ActiveRecord::Base

  attr_accessible :user_id

  has_many :plan_associations
  has_many :operations, through: :plan_associations

end