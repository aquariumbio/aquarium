class Plan < ActiveRecord::Base

  attr_accessible :user_id

  has_many :plan_associations
  has_many :operations, through: :plan_associations

  def goals
    # TODO: Make this faster. Note, fvs doesn't work, so will probably need to be some kind of SQL query.
    operations.select { |op| op.successors.length == 0 }.as_json(include: :operation_type, methods: :field_values)
  end

  def serialize

    {
      id: id,
      user_id: user_id,
      created_at: created_at,
      updated_at: updated_at,
      goals: goals,
      trees: operations.collect { |op| op.serialize },
      issues: operations.collect { |op| op.issues }.flatten,
      operations: operations.as_json(methods: :field_values)
    }
  
  end

end