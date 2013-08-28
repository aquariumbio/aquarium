class ProduceInstruction < Instruction

  attr_reader :object_type, :quantity, :release

  def initialize object_type_expr, quantity_expr, release_expr

    @object_type_expr = object_type_expr
    @quantity_expr = quantity_expr
    @release_expr = release_expr

    @renderable = true
    super 'produce'

    @location = 'B0.000'

  end

  # RAILS ##############################################################################################

  def pre_render scope, params
    @object_type = scope.substitute @object_type_expr
    @quantity = scope.evaluate @quantity_expr
    @release = ( @release_expr ? ( scope.evaluate @release_expr ) : nil )
  end

  def bt_execute scope, params

    # evaluate the expressions for object_type and quantity
    pre_render scope, params

    # find the object, or report an error
    x = ObjectType.find_by_name(@object_type)
    if !x && Rails.env != 'production'
      x = ObjectType.new
      x.save_as_test_type @object_type
    elsif !x
      raise "Could not find object type #{object_type}, which is not okay in the production server." 
    end

    # make a new item and save it
    begin
      item = x.items.create(location: params['location'], quantity: @quantity)
    rescue Exception => e
      raise "Could not add item of type #{object_type}: " + e.message
    end

    release_data = []
    # release anything that needs to be released
    if @release
      @release.each do |pi|
        x = Item.find_by_id(pi[:item][:id])
        raise 'no such object:' + pi[:object][:name] if !x 
        x.quantity -= x.inuse
        x.inuse = 0
        x.save
        release_data.push object_type: pi[:object][:name], item_id: pi[:item][:id]
      end
    end

    # save relevant information in the log
    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'PRODUCE'
    log.data = { pc: @pc, object: { object_type: @object_type, location: item.location, item_id: item.id, quantity: 1 }, release: release_data }.to_json
    log.save

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
