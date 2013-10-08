class ProduceInstruction < Instruction

  attr_reader :object_type, :quantity, :release, :var

  def initialize object_type_expr, quantity_expr, release_expr, var

    @object_type_expr = object_type_expr
    @quantity_expr = quantity_expr
    @release_expr = release_expr
    @result_var = var

    @renderable = true
    super 'produce'

    @location = 'B0.000'

  end

  # RAILS ##############################################################################################

  def pre_render scope, params

    @object_type = scope.substitute @object_type_expr
    @quantity = scope.evaluate @quantity_expr
    @release = ( @release_expr ? ( scope.evaluate @release_expr ) : nil )

    # find the object, or report an error
    x = ObjectType.find_by_name(@object_type)
    if !x && Rails.env != 'production'
      x = ObjectType.new
      x.save_as_test_type @object_type
      @flash += "Warning: Created new object type: #{@object_type}.<br />"
    elsif !x
      raise "Could not find object type #{object_type}, which is not okay in the production server." 
    end

  end

  def bt_execute scope, params

    # evaluate the expressions for object_type and quantity
    pre_render scope, params

    x = ObjectType.find_by_name(@object_type)

    # make a new item and save it
    loc = params['location'] ? params['location'] : x.location_wizard;
    begin
      item = x.items.create(location: loc, quantity: @quantity)
    rescue Exception => e
      raise "Could not add item of type #{object_type}: " + e.message
    end

    scope.set( @result_var.to_sym, item )

    # touch the item, for tracking purposes
    t = Touch.new
    t.job_id = params[:job]
    t.item_id = item.id
    t.save

    # release anything that needs to be released
    release_data = []

    if @release
      @release.each do |item|
        x = Item.find_by_id(item[:id])
        raise 'no such object:' + item[:name] if !x 
        x.quantity -= 1
        x.inuse = 0
        x.save
        release_data.push object_type: item[:name], item_id: item[:id]
      end
    end

    # save relevant information in the log
    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'PRODUCE'
    log.data = { pc: @pc, 
                 object: { object_type: @object_type, location: item.location, item_id: item.id, quantity: 1 }, 
                 release: release_data 
                }.to_json
    log.save

  end

  def html
    x = @release ? @release : 'nothing'
    h = "<b>produce</b> #{@quantity_expr} #{@object_type_expr}, releasing #{x}"
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
