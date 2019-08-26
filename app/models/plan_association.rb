# frozen_string_literal: true

class PlanAssociation < ActiveRecord::Base

  attr_accessible :plan_id, :operation_id

  belongs_to :plan
  belongs_to :operation

end
