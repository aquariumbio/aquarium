class Planner

  def initialize operation_types
    @operation_types = operation_types
  end

  def plan op

    op.inputs.each do |input|

      if !input.satisfied_by_environment

        @operation_types.each do |pre_op_type|
          pre_op_type.outputs.each do |output|
            if output.can_produce input.value
              pre_op = pre_op_type.instantiate output, input
              input.predecessors |= []
              input.predecessors << { operation: pre_op, output_name: output.name }
              plan pre_op
            end
          end
        end

        if input.predecessors.empty?
          input.unsat = true
        end 

      end

    end

  end

end
