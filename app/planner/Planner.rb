class Planner

  attr_reader :plan

  def initialize operation_types, plan=nil
    @operation_types = operation_types
    @plan_space_size = 0
    @plan = plan || Plan.new
    @plan.save    
  end

  def plan_trees ops

    ops.each do |op|
      plan_tree op
      mark_shortest op
    end

    ops.each do |op|
      mark_unused op
    end   

    @plan

  end

  def satisfied_by_plan input

    @plan.reload

    @plan.operations.reject { |op| op.on_the_fly}.each do |op|
      op.outputs.each do |output|
        if output.satisfies input
          puts "\e[92mALREADY FOUND OPERATION TO MAKE #{input}. ADDING TO PLAN\e[39m"
          return output
        end
      end
    end

    return nil

  end

  def plan_tree op

    op.associate_plan @plan unless op.plan

    op.inputs.each do |input|

      puts "\e[94mOperation #{op.id}: Backchaining #{input.name}\e[39m"

      if !input.satisfied_by_environment

        puts "\e[94m  #{input.name} is not satisfied by the environment!\e[39m"

        output = satisfied_by_plan input

        if output

          output.add_successor input

        else 

          @operation_types.each do |pre_op_type|
            pre_op_type.outputs.each do |output|
              if output.can_produce input
                pre_op = pre_op_type.instantiate output, input
                input.add_predecessor pre_op.get_output(output.name)
                @plan_space_size += 1
                if @plan_space_size < 20
                  self.plan_tree pre_op
                else
                  puts "MAX DEPTH REACHED, PLANNER STOPPED"
                end
              end
            end
          end

        end

      else

        puts "\e[94m  #{input.name} is satisfied by the environment!\e[39m"

      end

    end

    @plan

  end

  def unused op

    op.outputs.each do |output|
      output.wires_as_source.each do |wire|
        if wire.active
          return false
        end
      end
    end

    return true

  end

  def mark_unused op
    op.recurse do |o|
      if o != op && unused(o)
        # remove wires to o
        o.inputs.each do |input|
          input.wires_as_dest.each do |w|
            w.active = false
            w.save
          end
        end
        puts "Setting operation #{o.id} to unplanned"
        o.status = "unplanned"
        o.save
      end
    end
  end

  def old_mark_unused op
    op.recurse do |o|
      if o != op && unused(o)
        o.set_status_recursively "unplanned"
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
                wires = Wire.where( from_id: p.id, to_id: i.id )

                if wires.length > 0
                  puts "  Deactivating wire: #{wires[0].inspect}"
                  wires[0].active = false
                  wires[0].save
                end

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
