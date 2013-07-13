class ProduceInstruction < Instruction

  attr_reader :object_type, :quantity

  def initialize object_type_expr, quantity_expr

    @object_type_expr = object_type_expr
    @quantity_expr = quantity_expr
    @renderable = true
    super 'produce'

    @location = 'B0.000'

  end

  # TERMINAL ###########################################################################################

  def pre_render scope, params
    @object_type = scope.substitute @object_type_expr
    @quantity = scope.evaluate @quantity_expr
  end

  def bt_execute scope, params

    pre_render scope, params

    begin
      x = ObjectType.find_by_name(@object_type)
    rescue Exception => e
      raise "Could not find object type #{object_type}: " + e.message
    end

    begin
      x.items.create(location: params['location'], quantity: @quantity)
    rescue Exception => e
      raise "Could not add item of type #{object_type}: " + e.message
    end

  end

  # TERMINAL ###########################################################################################

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
