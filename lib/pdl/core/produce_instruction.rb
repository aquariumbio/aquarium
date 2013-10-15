class ProduceInstruction < Instruction

  attr_reader :object_type_name, :quantity, :release, :var, :item
  attr_accessor :sample_expr, :note

  def initialize object_type_expr, quantity_expr, release_expr, var, options = {}

    @object_type_expr = object_type_expr
    @quantity_expr = quantity_expr
    @release_expr = release_expr
    @result_var = var
    @sample_expr = nil

    @renderable = true
    super 'produce', options

    @location = 'B0.000'

  end

  # RAILS ##############################################################################################
 
  def pre_render scope, params

    @object_type_name = scope.substitute @object_type_expr
    @quantity = scope.evaluate @quantity_expr
    @release = ( @release_expr ? ( scope.evaluate @release_expr ) : nil )

    if @release && @release.class != Array 
      raise "Could not release #{@release_expr} because it does not evaluate to an array of items."
    end

    if @sample_expr
      begin
        sample_item = scope.evaluate @sample_expr
        if sample_item.class != Hash || !sample_item[:id]
          raise "In produce #{@sample_expr} does not refer to a single item."
        end
        @sample = Item.find(sample_item[:id]).sample
      rescue Exception => e
        raise "Could not find sample #{@sample_expr} => #{sample_item.to_s} for produce instruction. " + e.message
      end
    end

    # find the object, or report an error
    @object_type = ObjectType.find_by_name(@object_type_name)

    if !@object_type && Rails.env != 'production'
      @object_type = ObjectType.new
      @object_type.save_as_test_type @object_type_name
      @flash += "Warning: Created new object type: #{@object_type_name}.<br />"
    elsif !@object_type
      raise "Could not find object type #{object_type_name}, which is not okay in the production server." 
    end

    if !params[:new_item_id] # this should be true when rendering the first time, but not when pre_render is called from bt_execute
                             # unless render = false

      loc = params['location'] ? params['location'] : @object_type.location_wizard;
      begin
        @item = @object_type.items.create(location: loc, quantity: @quantity)
      rescue Exception => e
        raise "Could not add item of type #{object_type_name}: " + e.message
      end

      if @sample
        @item.sample_id = @sample.id
        @item.save
      end

    else 

      @item = Item.find(params[:new_item_id])

    end

  end

  def bt_execute scope, params

    # evaluate the expressions for object_type and quantity
    pre_render scope, params

    @item.location = params['location'] ? params['location'] : @object_type.location_wizard;
    @item.save

    scope.set( @result_var.to_sym, pdl_item(@item) )

    # touch the item, for tracking purposes
    t = Touch.new
    t.job_id = params[:job]
    t.item_id = @item.id
    t.save

    # release anything that needs to be released
    release_data = []

    if @release
      @release.each do |item|
        y = Item.find_by_id(item[:id])
        raise 'no such object:' + item[:name] if !y 
        y.quantity -= 1
        y.inuse = 0
        if y.quantity <= 0
          y.destroy
        else
          y.save
        end
        release_data.push object_type: item[:name], item_id: item[:id]
      end
    end

    # save relevant information in the log
    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'PRODUCE'
    log.data = { pc: @pc, 
                 item: { location: @item.location, id: @item.id, quantity: 1 }, 
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
