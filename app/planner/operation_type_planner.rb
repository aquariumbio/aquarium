module OperationTypePlanner

  def instantiate output, desired_value

    op = operations.create status: "planning"

    # Set the output fv to the desired value.
    aft = nil
    output.allowable_field_types.each do |output_aft|
      desired_value.field_type.allowable_field_types.each do |input_aft|
        if output_aft.equals input_aft
          aft = output_aft
        end
      end
    end

    op.set_output(output.name, desired_value.child_sample,aft)

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

      op = operations.create status: "pending", user_id: User.all.sample.id

      inputs.each do |input|
        random_sample, random_aft = input.random
        op.set_input(input.name,random_sample,random_aft) 
      end

      outputs.each do |output|
        matching_inputs = op.inputs.select { |i| i.name == output.name }
        if matching_inputs.empty?
          random_sample, random_aft = output.random
          op.set_output(output.name,random_sample,random_aft)
        else
          if output.allowable_field_types.length > 0
            aft = output.allowable_field_types.sample
          else
            aft = nil
          end
          op.set_output(output.name,matching_inputs[0].val,aft)
        end
      end      

      op

    end

  end

end
