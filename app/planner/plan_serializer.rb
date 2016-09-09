module PlanSerializer

  # Because the operations in a plan form a tree, serializing them with build in rails stuff is super slow, because it 
  # requires recursion. This code loads everything involved with a plan in a few db queries, and then stiches it all 
  # together into a nice recursive object. Since the stiching is done in memory, its fast.

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

  def predecessors op, ops, field_types

    determined_predecessors = op["inputs"].collect { |input|
      {
        name: input["name"],
        id: input["id"],
        operations: ops.select { |other_op| ( !@running || other_op["status"] != "unplanned" ) && precedes(other_op, input) }
                       .collect { |other_op| 
                                    other_op["visited"] = true
                                    other_op.merge(predecessors: predecessors(other_op,ops,field_types)) 
                                },
        undetermined: false
      }      
    }

    undetermined_predecessors = op["operation_type"]["inputs"].reject { |ot_input|
      op["inputs"].collect { |input| input["name"] }.member? ot_input["name"]
    }.collect { |ot_input|
      field_types.select { |ft| ft["id"] == ot_input["id"] }.first.merge undetermined: true
    }

    determined_predecessors + undetermined_predecessors

  end

  def goal? op
    g = true
    op["outputs"].each do |output|
      g = false unless output["wires_as_source"].empty? 
    end
    g
  end

  def serialize

    @running = false
    @done = true

    ops = operations.includes(:job).as_json(include: :job, methods: :nominal_cost)
    op_ids = ops.collect { |o| o["id"] }
    Rails.logger.info "====================== OP_IDS = #{op_ids} =============================="

    associations = DataAssociation.includes(:upload).where(parent_class: "Operation", parent_id: op_ids).as_json(include: :upload)

    ops.each do |op|
      op["selected"] = (op["status"] != "unplanned")
      @running = true if [ "pending", "waiting", "ready", "scheduled", "running" ].member? op["status"]
      @done = false unless [ "done", "error" ].member? op["status"]
      op["data_associations"] = associations.select { |a| a["parent_id"] == op["id"] }
      op["fvs"] = {}
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
                   .where(parent_class: "Operation", parent_id: op_ids)
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

    @status = "Under Construction" if !@running && !@done
    @status = "Running" if @running 
    @status = "Completed" if @done

    {
      id: id,
      user_id: user_id,
      created_at: created_at,
      updated_at: updated_at,
      status: @status,
      goals: goals.collect { |g| g.merge(predecessors: predecessors(g,ops,field_types)) }
    }

  end

end

