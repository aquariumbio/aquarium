module OperationTypePlanner

  def instantiate output, desired_value

    puts "    Need to instantiate an operation of type '#{name}'"

    #   - Set the output fv to the desired value.
    op = operations.create status: "planning"
    op.set_output(output.name, desired_value.child_sample)
    unless op.errors.empty?
      raise "Could not set io of operation: #{op.errors.full_messages.join(', ')}"
    end

    #   - Leave any other outputs unspecified?
    #   - For any input whose name equals the name of the output, also set that fv to the desired value .
    #   - For any other input, find a fv in the desired_value's properties with the same name, and set
    #     that inputs value to that property.

    puts "    Required inputs:"
    inputs.each do |i|
      puts "      #{i.name}"
    end

    puts "    Required output: #{desired_value.child_sample.sample_type.name} '#{desired_value.child_sample.name}'"
    puts "      Field:"
    desired_value.child_sample.properties.each do |k,v|
      puts "        #{k}: #{v}"
    end

    puts "\nInstantiated new operation"
    puts op

    raise "instantiate implementation under construction"

  end

end

