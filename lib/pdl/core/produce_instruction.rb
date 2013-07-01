class ProduceInstruction < Instruction

  def initialize object_type_name, location
    @object_type_name = object_type_name
    @location = location
    super 'produce'
  end

  def execute scope

    result = liaison 'produce', { name: @object_type_name, location:( scope.substitute @location ) }

    if result[:error]
      raise result[:error]
    end

  end

end
