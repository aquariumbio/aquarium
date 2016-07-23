class Planner

  def initialize operation_types
    @operation_types = operation_types
    @plan_space_size = 0
  end

  def plan op

    op.inputs.each do |input|

      if !input.satisfied_by_environment

        @operation_types.each do |pre_op_type|
          pre_op_type.outputs.each do |output|
            if output.can_produce input
              pre_op = pre_op_type.instantiate output, input
              input.predecessors << { operation: pre_op, output_name: output.name }
              @plan_space_size += 1
              if @plan_space_size < 20
                plan pre_op
              else
                puts "MAX DEPTH REACHED, PLANNER STOPPED"
              end
            end
          end
        end

        if input.predecessors.empty?
          input.unsat = true
        end 

      end

    end

  end

  def show op, space=""

    puts "#{space}#{op.id}: #{op.operation_type.name}"

    op.inputs.each do |i|
      puts "  #{space}#{i.sample_type.name} #{i.child_sample.name}(#{i.object_type.name})"
      i.predecessors.each do |p|
        show(p[:operation], space+"    ")
      end
    end

  end

end
