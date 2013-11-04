require 'net/http'
require 'json'

module Plankton

  class TakeInstruction < Instruction

    attr_reader :item_list, :object_list

    def initialize item_list_expr, options = {}

      @item_list_expr = item_list_expr
      @renderable = true
      super 'take', options

      # TERMINAL 
      @num_taken = 0
      @url = 'http://bioturk.ee.washington.edu:3010/liaison/'

    end

    # RAILS ###########################################################################################

    def pre_render scope, params

      # To render the list of items to be taken, we have to evaluate item_list_expr, in case
      # involves complicated expressions and nost just string constants describing the items.
      # We also have to figure out all the object types associated with those items, so that
      # we have pictures, etc. to show.

      @item_list = []
      @object_list = []

      # make a list of the evaluated expressions for each item in the list to be taken
      @item_list_expr.each do |item_expr|

        if item_expr[:type]
          description = {
            type: (scope.substitute item_expr[:type]),
            quantity: (scope.evaluate item_expr[:quantity]).to_i,
            var: item_expr[:var]
          }
        else 
          description = {}
        end

        # if its a sample
        if item_expr[:name]
          description[:name] =  (scope.substitute item_expr[:name])
          description[:project] = (scope.substitute item_expr[:project])
        end

        # if a particular id is specified
        if item_expr[:id] 
          val = (scope.evaluate item_expr[:id]).to_i
          i = Item.find(val)
          unless i
            raise "Could not find item with id = #{item_expr[:id]} = #{val}. "
          end
          description[:id] = val
          description[:type] = i.object_type.name
          description[:quantity] = 1
          description[:var] = item_expr[:var]
          if i.object_type.handler == 'sample_container'
            unless i.sample
              raise "Item #{val} has object type sample_container, but does not point to a sample"
            end
            description[:name] = i.sample.name
            description[:project] = i.sample.project
          end
        end

        @item_list.push( description )

      end

      # Find the objects associated with the :type specifications in the db
      @item_list.each do |i|

        ob = ObjectType.find_by_name(i[:type])

        # make a new object if one doesn't exist (and we're not in production mode)
        if !ob && Rails.env != 'production'
          ob = ObjectType.new
          ob.save_as_test_type i[:type]
          @flash += "Warning: Created new object type #{i[:type]}.<br />"
        elsif !ob
          raise "In <take>: Could not find object of type '#{@object_type}', which is not okay in production mode."
        end

        @object_list.push( ob )

      end

    end

    def html
      h = "<b>take</b>"
      @item_list_expr.each do |ie|
        if ie[:type]
          h += ie[:type] + ", "
        else 
          h += '[only id specified], '
        end
      end
      return h[0..-3]
    end

    def log var, r, scope, params

      data = []

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'TAKE'
      log.data = { pc: @pc, var: var, items: r }.to_json
      log.save

    end

    def bt_execute scope, params

      # Evalute @object_list in current scope
      pre_render scope, params

      # Get the users choices of particular items
      choices = JSON.parse(params[:choices])

      # Iterate over all items to be taken
      for j in 0..( (@object_list.length) - 1 ) 

        result = [] 

        # Iterate over each choice
        choices[j].each do |k,q| 

          i = k.to_i 
          item = Item.find(i)

          q.times do
            result.push( pdl_item item ) 
          end

          item.inuse += q
          item.save

          # touch the item, for tracking purposes
          t = Touch.new
          t.job_id = params[:job]
          t.item_id = item.id
          t.save

        end

        scope.set( @item_list[j][:var].to_sym, result )
        log @item_list[j][:var], result, scope, params

      end

    end

  end

end
