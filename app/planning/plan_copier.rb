class PlanCopier

  def initialize plan_id
    @plan = Plan.includes(:operations).find(plan_id)
    @fv_map = []
    @op_map = []
  end

  def copy

    @new_plan = @plan.dup
    @new_plan.status = "planning"
    @new_plan.name = @plan.name ? @plan.name + " (copy)" : "Copy of plan #{@plan.id}";
    @new_plan.save

    copy_ops
    copy_wires

    begin
      @base_module = JSON.parse @plan.layout, symbolize_names: true
    rescue Exception => e
      @base_module = { id: 0 }
    end

    port_module_wires @base_module
    @new_plan.layout = @base_module.to_json
    @new_plan.save

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

      @op_map[op.id] = new_op.id

      pa = PlanAssociation.new plan_id: @new_plan.id, operation_id: new_op.id
      pa.save

      copy_fvs op, new_op

    end

  end

  def copy_fvs op, new_op

    op.field_values.each do |fv|

      new_fv = fv.dup
      new_fv.parent_id = new_op.id
      new_fv.child_item_id = nil
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

  def port_module_wires m

    if m[:wires]
      m[:wires].each do |wire|
        wire[:from][:id]    = @fv_map[wire[:from][:id]]    if wire[:from][:record_type] == "FieldValue"
        wire[:to][:id]      = @fv_map[wire[:to][:id]]      if wire[:to][:record_type] == "FieldValue"
        wire[:from_op][:id] = @op_map[wire[:from_op][:id]] if wire[:from_op]
        wire[:to_op][:id]   = @op_map[wire[:to_op][:id]]   if wire[:to_op]
      end
    end

    if m[:children]
      m[:children].each do |child|
        port_module_wires child
      end
    end

  end

end