class PlanCopier

  def initialize plan_id
    @plan = Plan.includes(:operations).find(plan_id)
    @fv_map = []
  end

  def copy

    @new_plan = @plan.dup
    @new_plan.status = "planning"
    @new_plan.name = @plan.name ? @plan.name + " (copy)" : "Copy of plan #{@plan.id}";
    @new_plan.save

    copy_ops
    copy_wires

    @new_plan

  end

  def copy_ops

    y = 16

    @plan.operations.each do |op|

      new_op = op.dup
      new_op.status = "planning"

      new_op.x = 500 * rand unless op.x
      unless op.y
        new_op.y = y 
        y += 64
      end

      new_op.save

      pa = PlanAssociation.new plan_id: @new_plan.id, operation_id: new_op.id
      pa.save

      copy_fvs op, new_op

    end

  end

  def copy_fvs op, new_op

    op.field_values.each do |fv|

      new_fv = fv.dup
      new_fv.parent_id = new_op.id
      new_fv.save
      @fv_map[fv.id] = new_fv.id

    end

  end

  def copy_wires

    @plan.wires.each do |wire|
      new_wire = Wire.new from_id: @fv_map[wire.from_id], to_id: @fv_map[wire.to_id]
      new_wire.save
    end

  end

end