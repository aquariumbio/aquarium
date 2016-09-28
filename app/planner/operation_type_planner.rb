module OperationTypePlanner

  def instantiate output, desired_value

    op = operations.create status: "planning"

    # Set the output fv to the desired value.
    op.set_output(output.name, desired_value.child_sample)
    unless op.errors.empty?
      raise "Could not set output of operation: #{op.errors.full_messages.join(', ')}"
    end

    inputs.each do |i|

      if i.name == output.name

        # For any input whose name equals the name of the output, set that fv to the desired value.        
        op.set_input(i.name, desired_value.child_sample)
        unless op.errors.empty?
          raise "Could not set input of operation: #{op.errors.full_messages.join(', ')}"
        end

      else

        props = desired_value.child_sample.properties

        puts "instantiating op #{op.id}'s input #{i.name}, which should lead to #{desired_value.child_sample.name}"
        puts "from #{desired_value.child_sample.name}'s properties #{props}"

        # For other inputs, find a fv in the desired_value's properties with the
        # same name, and set that input's value to that property.
        found_match = false
        desired_value.child_sample.sample_type.field_types.each do |ft|
          if i.name == ft.name 
            found_match = true            
            if props[ft.name]  # note: if no child sample, don't set the input, which signals
                               # to the planner that desired_value's properties are incomplete
              op.set_input(i.name,props[ft.name])
              puts "  ==> SETTING #{i.name} to #{props[ft.name]}"
            end
          end
        end

        # set any remaining inputs to nil
        puts "  ==> SETTING #{i.name} to nil" unless found_match
        op.set_input(i.name,nil) if !i.has_sample_type && !found_match

      end

    end    

    puts "  #{op}"
    op

  end

  def random n=1

    (1..n).collect do |i|

      puts "==== making operation of type #{name}"

      op = operations.create status: "pending", user_id: User.all.sample.id

      inputs.each do |input|
        op.set_input(input.name,input.random)
        puts "==== set input #{input.name}"
      end

      outputs.each do |output|
        matching_inputs = op.inputs.select { |i| i.name == output.name }
        if matching_inputs.empty?
          op.set_output(output.name,output.random)
        else
          op.set_output(output.name,matching_inputs[0].val)
        end
        puts "==== set output #{output.name}"        
      end      

      op

    end

  end

end
