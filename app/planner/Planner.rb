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
              input.add_predecessor pre_op.get_output(output.name)
              @plan_space_size += 1
              if @plan_space_size < 20
                plan pre_op
              else
                puts "MAX DEPTH REACHED, PLANNER STOPPED"
              end
            end
          end
        end

      end

    end

  end

  def mark_shortest op

    d = if op.inputs.empty?

      1

    else

      input_depths = op.inputs.collect { |i|

        if i.predecessors.empty? 
          1
        else
          pred_lengths = (i.predecessors.collect { |p| mark_shortest p.operation })

          if i.predecessors.length > 1
            puts "Determining best choice for input #{i.name} of operation #{op.id}"
            index = pred_lengths.each_with_index.min[1]
            puts "  It's option #{index}"
            i.predecessors.each_with_index do |p,j| 
              unless j == index
                puts "  Unplanning operation #{p.operation.id}"
                p.operation.set_status_recursively "unplanned"
              end
            end
          end
          pred_lengths.min + 1
        end

      }

      input_depths.max

    end

    puts "#{op.id} #{op.operation_type.name} has depth #{d}"

    d

  end

end
