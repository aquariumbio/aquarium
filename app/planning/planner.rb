class Planner

  attr_accessor :errors

  def initialize plan_id
    @plan = Plan.includes(operations: :operation_type).find_by_id(plan_id)
    @errors = []
    @errors << "Could not find plan #{plan_id}" unless @plan
  end

  def start

    if errors.empty?

      mark_leaves

      # set all leaves to pending
      @plan.operations.each do |op|

        if leaf? op

          if op.operation_type.on_the_fly?
            op.status = "primed"
          else
            op.status = "pending"
          end

        else
          op.status = "waiting"
        end

        op.save

      end

      @plan.status = nil # for historical reasons, this means the plan is active
      @plan.save

    end

    @errors.empty?

  end

  def mark_leaves

    @non_leaves = []

    fvids = @plan.wires.collect { |w| [w.to_id, w.from_id] }.flatten
    fvs = FieldValue.where(id: fvids, role: 'input')

    fvs.each do |fv|
      @non_leaves << fv.parent_id
    end

  end

  def leaf? op

    ! @non_leaves.member? op.id

  end

end