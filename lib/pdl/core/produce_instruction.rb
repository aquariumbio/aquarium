class ProduceInstruction < Instruction

  def initialize object_type_name, quantity
    @object_type_name = object_type_name
    @quantity = quantity
    @location = 'B0.000'
    super 'produce'
  end

  def bt_execute scope, params

    x = ObjectType.find_by_name(@object_type_name)
    x.items.create(location: (scope.substitute @location), quantity: @quantity)
    
  end

  def render scope

    #Ask the use where they put the produced object
    puts "Please enter the new location of #{@object_type_name} and press return: "

  end

  def execute scope
    
    location = gets.chomp
    result = liaison 'produce', { name: @object_type_name, location: location, quantity: (scope.evaluate @quantity) }

    if result[:error]
      raise result[:error]
    end

  end

end
