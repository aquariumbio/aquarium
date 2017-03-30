module OperationPlanner

  def associate_plan plan
    pa = plan_associations.create plan_id: plan.id
    pa.save
    if !plan.user_id
      plan.user_id = user_id
      plan.save
    end
  end

  def ready?

    @@ready_errors ||= []

    operation_type.inputs.each do |i|

      input_list = inputs.select { |j| j.name == i.name }

      if input_list.empty? # && !i.array # arrays need to have at least one element (for now)
        @@ready_errors << "#{operation_type.name}>#{i.name}: Arrays should have at least one element."
        return false
      elsif on_the_fly
        @@ready_errors << "#{operation_type.name}>#{i.name}: Input is on the fly."
        return false
      elsif input_list[0].field_type.ftype != 'sample'
        return true
      else

        input_list.each do |j|
          if ! j.predecessors.empty?
            j.predecessors.each do |pred|
              if ! ( pred.operation.status == 'primed' || 
                     pred.operation.status == 'done' || 
                     pred.operation.status == 'unplanned' ||
                     pred.operation.status == 'planning' )
                @@ready_errors << "#{operation_type.name}>#{i.name}: " + 
                                 "Predecessor '#{pred.operation.operation_type.name}' " + 
                                 "has status #{pred.operation.status}."
                return false
              end
            end
          elsif ! j.satisfied_by_environment
            @@ready_errors << "#{operation_type.name}>#{i.name}: no available items."
            return false
          end
        end

      end

    end

    return true

  end

  def undetermined_inputs?

    operation_type.inputs.each do |i|
      input_list = inputs.select { |j| j.name == i.name }
      if input_list.empty? # && ! i.array # arrays need to have at least one element (for now)
        return true
      end
    end

    return false

  end

  def has_no_stock_or_method
    inputs.select { |i| i.field_type.ftype == 'sample' }.each do |i|
      if i.predecessors.length == 0 && !i.satisfied_by_environment 
        return true
      end
    end
    return false
  end

  def issues

    @@ready_errors ||= []
    issues = []

    recurse do |op|
      ready = op.ready?
      if op.status == "planning" && op.leaf? && !ready
        issues << "Operation '#{op.operation_type.name}' is not ready (#{ready}). #{@@ready_errors.join(' ')}"
      elsif op.status == "planning" && op.undetermined_inputs?
        issues << "Operation '#{op.operation_type.name}' has unspecified inputs."
      elsif op.has_no_stock_or_method
        issues << "No way to make at least one input of operation '#{op.operation_type.name}'."
      end
    end

    return issues

  end

  def show_plan space=""

    op = self

    if op.status == "planning"
      print "#{space}\e[95m#{op.operation_type.name} #{op.id}, status: #{op.status}\e[39m"
    else
      print "#{space}\e[90m#{op.operation_type.name} #{op.id}, status: #{op.status}\e[39m"      
    end

    if op.ready?
      puts ", ready"
    else
      puts ", not ready"
    end

    op.operation_type.inputs.each do |j|

      input_list = op.inputs.each.select { |i| i.name == j.name }

      input_list.each do |i| # note: array inputs may have multiple fvs with the same name

        print "  #{space}+ #{i.sample_type.name}"
        print " #{i.child_sample.name}"
        print " (#{i.object_type ? i.object_type.name : 'NO OBJECT TYPE'})"

        if i.predecessors.length > 0
          puts " ... #{i.predecessors.length} option(s)"
        elsif i.satisfied_by_environment
          puts " ... available"
        else
          puts " ... no inventory and no way to make this sample"
        end

        i.predecessors.each do |p|
          p.operation.show_plan space+"    "
        end

      end

      if input_list.empty?
        afts = j.allowable_field_types.collect { |aft| aft.sample_type.name }.join(',')
        puts "  #{space}+ #{j.name} (#{afts}): NOT DETERMINED (by Operation.instantiate)"
      end

    end

  end  
  
  def serialize override_status=nil

    problem = false
    input_list = []

    operation_type.inputs.each do |ot_input|

      op_inputs = inputs.select { |i| i.name == ot_input.name }

      if op_inputs.length > 0 

        op_inputs.each do |i| 

          sat = i.satisfied_by_environment
          preds = i.predecessors
          os = override_status if (override_status)
          os = status if (!override_status && status == "unplanned")
          problem = problem || ( !sat && preds.length == 0 )

          input_list << {
            name: i.name,
            satisfied: sat,
            issue: !sat && preds.length == 0,
            predecessors: preds.reject { |p| p.operation.status == "unplanned" }.collect { |p|
              {
                id: p.id,
                name: p.name,
                operation: p.operation.serialize(os)
              }
            }
          }

        end

      else
        problem = true
        input_list << { 
          name: ot_input.name,
          missing: true
        }
      end

    end

    {

      id: id,
      operation_type_id: operation_type_id,
      status: override_status ? override_status : status,
      ready: ready?,
      inputs: input_list,
      problem: problem

    }

  end  

end

