module PlanSerializer

  def precedes aop, input
    # returns true of there is an output fv in aop that is wired to the specified input fv of bop
    return false if aop["visited"]
    aop["outputs"].each { |output|
      output["wires_as_source"].each { |wire| 
        if wire["from_id"] == output["id"] && wire["to_id"] == input["id"]
          return true 
        end
      }
    }
    return false
  end

  def predecessors op, ops
    op["inputs"].collect { |input|
      {
        name: input["name"],
        id: input["id"],
        operations: ops.select { |other_op| ( @status != "Running" || other_op["status"] != "unplanned" ) && precedes(other_op, input) }
                       .collect { |other_op| 
                                    other_op["visited"] = true
                                    other_op.merge(predecessors: predecessors(other_op,ops)) 
                                }
      }
    }
  end

  def goal? op
    g = true
    op["outputs"].each do |output|
      g = false unless output["wires_as_source"].empty? 
    end
    g
  end

  def serialize

    @status = "Under Construction"

    ops = operations.includes(:job).as_json(include: :job)

    ops.each do |op|
      op["selected"] = (op["status"] != "unplanned")
      @status = "Running" if [ "pending", "waiting", "ready", "scheduled", "running", "done", "error" ].member? op["status"] 
    end

    operation_types = OperationType.where(id: ops.collect { |o| o["operation_type_id"] }).as_json

    field_types = FieldType.includes(allowable_field_types: [ :sample_type, :object_type ])
                        .where(parent_class: "OperationType", parent_id: operation_types.collect { |ot| ot["id"] })
                        .collect { |ft| ft.as_json }

    operation_types.each do |ot|
      ot["inputs"] = field_types.select { |ft| ft["parent_id"] == ot["id"] && ft["role"] == "input" }
      ot["outputs"] = field_types.select { |ft| ft["parent_id"] == ot["id"] && ft["role"] == "output" }      
    end

    field_values = FieldValue
                   .includes(:child_sample,:child_item)
                   .where(parent_class: "Operation", parent_id: ops.collect { |o| o["id"] })
                   .collect { |fv| fv.export }

    fids = field_values.collect { |fv| fv["id"] }
    wires = Wire.where("from_id in (?) OR to_id in (?)", fids, fids)

    field_values.each do |fv|
      fv["wires_as_source"] = wires.select { |w| w["from_id"] == fv["id"] }
      fv["wires_as_dest"]   = wires.select { |w| w["to_id"] == fv["id"] }      
    end

    ops.each do |op|
      op["operation_type"] = operation_types.select { |ot| ot["id"] == op["operation_type_id"] }[0]
      op["inputs"]  = field_values.select { |fv| fv["parent_id"] == op["id"] && fv["role"] == "input" }
      op["outputs"] = field_values.select { |fv| fv["parent_id"] == op["id"] && fv["role"] == "output" }      
    end

    goals = ops.select { |op| goal? op }

    goals.each do |g| 
      g["visited"] = true
    end

    {
      id: id,
      user_id: user_id,
      created_at: created_at,
      updated_at: updated_at,
      status: @status,
      goals: goals.collect { |g| g.merge(predecessors: predecessors(g,ops)) }
    }

  end

end

