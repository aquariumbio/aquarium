

class Planner

  attr_accessor :errors

  def initialize(plan_id)
    @plan = Plan.includes(operations: :operation_type).find_by_id(plan_id)
    @errors = []
    @errors << "Could not find plan #{plan_id}" unless @plan
  end

  def start

    if errors.empty?

      mark_leaves

      # set all leaves to pending
      @plan.operations.each do |op|

        next unless op.status == 'planning'

        op.status = if leaf? op

                      if op.operation_type.on_the_fly?
                        'primed'
                      else
                        op.status = if op.precondition_value
                                      'pending'
                                    else
                                      'delayed'
                                    end
                      end

                    else

                      # if the op has an on the fly pred
                      if ready? op
                        if op.precondition_value
                          'pending'
                        else
                          'delayed'
                        end
                      else
                        'waiting'
                      end

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

  def leaf?(op)

    !@non_leaves.member? op.id

  end

  def preds(fv)

    @plan.wires.select do |w|
      w.to_id == fv.id
    end.collect(&:from_op)

  end

  def ready?(op)

    rval = true

    op.field_values.each do |fv|
      preds(fv).each do |pred|
        rval = false unless pred.on_the_fly
      end
    end

    rval

  end

end
