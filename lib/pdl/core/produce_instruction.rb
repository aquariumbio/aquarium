class ProduceInstruction < Instruction

  def initialize object_type_name, location, quantity
    @object_type_name = object_type_name
    @location = location
    @quantity = quantity
    super 'produce'
  end

  def bt_execute scope, params

    x = ObjectType.find_by_name(@object_type_name)
    x.items.create(location: (scope.substitute @location), quantity: @quantity)
    
  end

  def execute scope

    result = liaison 'produce', { name: @object_type_name, location:( scope.substitute @location ) }

    if result[:error]
      raise result[:error]
    end

  end

end
