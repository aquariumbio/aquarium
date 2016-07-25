module OperationPlanner

  def set_status_recursively str

    puts "    Setting operation #{id} status to #{str}"

    self.status = str
    save

    puts "      Now #{inspect}"

    inputs.each do |input|
      input.predecessors.each do |pred|
        pred.operation.set_status_recursively str
      end
    end

    unless errors.empty?
      puts "      ERROR: #{errors.full_messages.join(', ')}"
    end

  end

end