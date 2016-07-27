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

end