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

  def show op, space=""

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
          show p.operation, space+"    "
        end

      end

      if input_list.empty?
        afts = j.allowable_field_types.collect { |aft| aft.sample_type.name }.join(',')
        puts "  #{space}+ #{j.name} (#{afts}): NOT DETERMINED (by Operation.instantiate)"
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
