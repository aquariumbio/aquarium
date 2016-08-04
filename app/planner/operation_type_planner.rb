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

        # puts "instantiating op#{op.id}(#{i.name},#{desired_value.child_sample.name}) from properties #{desired_value.child_sample.properties}"

        # For any other input, find a fv in the desired_value's properties with the
        # same name, and set that inputs value to that property.
        desired_value.child_sample.field_values.each do |fv|
          if i.name == fv.name
            op.set_input(i.name,fv.child_sample)
          end
        end

      end

    end    

    puts "  #{op}"
    op

  end

  def random n=1

    (1..n).collect do |i|

      op = operations.create status: "pending", user_id: User.all.sample.id

      inputs.each do |input|
        op.set_input(input.name,input.random)
      end

      outputs.each do |output|
        op.set_output(output.name,output.random)
      end      

      op

    end

  end

end


