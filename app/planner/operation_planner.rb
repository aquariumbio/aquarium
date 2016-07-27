module OperationPlanner

  def ready?

    operation_type.inputs.each do |i|

      input_list = inputs.select { |j| j.name == i.name }

      if input_list.empty? && !i.array
        return false
      else
        input_list.each do |j|
          if ! j.satisfied_by_environment
            return false
          end
        end
      end

    end

    return true

  end

  def leaf?
    inputs.each do |i|
      if i.predecessors.count > 0
        return false
      end
    end
    return true
  end

  def undetermined_inputs?

    operation_type.inputs.each do |i|
      input_list = inputs.select { |j| j.name == i.name }
      if input_list.empty? && ! i.array
        return true
      end
    end

    return false

  end

  def issues

    issues = []

    recurse do |op|
      if op.status == "planning" && op.leaf? && !op.ready?
        issues << "leaf operation #{op.id} is not ready"
      elsif op.status == "planning" && op.undetermined_inputs?
        issues << "operation #{op.id} has undetermined inputs"
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

end