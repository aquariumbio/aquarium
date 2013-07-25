require 'net/http'
require 'json'

class TakeInstruction < Instruction

  attr_reader :item_list, :object_list

  def initialize item_list_expr

    @item_list_expr = item_list_expr
    @renderable = true
    super 'take'

    # TERMINAL 
    @num_taken = 0
    @url = 'http://bioturk.ee.washington.edu:3010/liaison/'

  end

  # RAILS ###########################################################################################

  def pre_render scope, params

    # Evaluate expressions to get actual values
    @item_list = []
    @object_list = []

    @item_list_expr.each do |item_expr|
      @item_list.push( { type: (scope.substitute item_expr[:type]),
        quantity: (scope.evaluate item_expr[:quantity]).to_i,
        var: item_expr[:var] } )
    end

    # Find the actual objects in the db
    @item_list.each do |i|
      ob = ObjectType.find_by_name(i[:type])
      unless ob
        raise "In <take>: Could not find object of type '#{@object_type}'"
      end
      @object_list.push( ob )
    end
  end

  def log var, r, scope, params

    data = []

    r.each do |ob|
      data.push object_type: ob[:object][:name], item_id: ob[:item][:id], quantity: 1
    end

    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'TAKE'
    log.data = { pc: @pc, var: var, objects: data }.to_json
    log.save

  end

  def bt_execute scope, params

    pre_render scope, params

    result = []
    asd = ""

    params.each do |k,v|

      asd += k + ", "

      if k[0] == 'i'

        str = String.new(k)
        str[0] = ''
        i = str.to_i

        if params["q#{i}"].to_i > 0
      
          @item = Item.find(params["i#{i}"])
          if !@item
            raise "In <take>: Could not find item of type " + params["i#{i}"]
          end

          q = params["q#{i}"].to_i

          (1..q).each do |x|
            result.push( { 
              object: @object.attributes.symbolize_keys, 
              item: @item.attributes.symbolize_keys,
              quantity: 1 } ) 
          end

          @item.inuse += params["q#{i}"].to_i
          @item.save
      
        end

      end
      
    end

    scope.set( @var.to_sym, result )
    log var, result, scope, params

  end

  # TERMINAL ########################################################################################

  def render scope

    # ask btor for object info
    @object_type = scope.substitute @object_type
    @obj = liaison 'info', { name: @object_type }

    if @obj[:error]
      raise @obj[:error]
    end

    # show all the locations and quantities
    puts "Locations for object type #{@object_type}"
    puts "-------------------------------------------"
    puts "   \tLocation\tQuantity Available"
    n = 0
    @obj[:inventory].each do |item| 
      available = item[:quantity]-item[:inuse]
      if available > 0 
        n += 1
        puts "  #{n}.\t#{item[:location]}\t\t#{available} "
      end
    end
    puts "-------------------------------------------"

    puts "Scope in render of take is: "
    puts scope
    
    puts "In render:: quantity = "
    @quantity = scope.evaluate( scope.substitute( @quantity.to_s ) )
    puts @quantity

    # prompt the user for which location(s) they want to use
    if ( n > 0 )
      puts "You need #{@quantity - @num_taken} more"
      print "Choose the location from which you will take one more item and press return: "
    else
      raise "not enough items of type #{@object_type} available"
    end

  end

  def execute scope

    scope.set @var.to_sym, []

    begin

      # wait for input
      location = gets.to_i - 1

      # take the object
      @item = liaison 'take', { id: @obj[:inventory][location][:id], quantity: 1 }

      if @item[:error]
        raise @item[:error]
      end    

      # add a PdlItem to scope
      v = scope.get( @var.to_sym )
      scope.set( @var.to_sym, v.push( PdlItem.new( @obj, @item ) ) )

    #@quantity = scope.evaluate( scope.substitute( @quantity ) )
    puts "In execute:: quantity = "
    puts @quantity

      # update number taken
      @num_taken += 1
      if @num_taken < @quantity
        render scope
      end

    end while @num_taken < @quantity

    # if only one object, return it instead of an array containing it
    #if @quantity == 1 
    #  scope.set( @var.to_sym, scope.get(@var.to_sym).first )
    #end

  end  

end
