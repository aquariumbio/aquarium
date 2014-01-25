require 'net/http'
require 'json'

module Plankton

  class TakeEntry

    attr_accessor :var,
                  :quantity_expr,
                  :quantity_value,
                  :item_expr,
                  :item_value,
                  :item_list,
                  :type_expr,
                  :type_value,
                  :object_list

    def initialize x
      x.each_pair do |key, val|
        instance_variable_set('@' + key.to_s, val)
      end
    end

  end


  class TakeInstruction < Instruction

    attr_reader :entry_list, :note
    attr_writer :note_expr

    def initialize entry_list, options = {}

      @note_expr = ""
      @note = ""
      @entry_list = entry_list
      @renderable = true
      super 'take', options

    end # initialize


    def pre_render scope, params

      # Check all evaluations ###################################################################################
      @entry_list.each do |e|

        if e.quantity_expr
          e.quantity_value = scope.evaluate e.quantity_expr
        end

        if e.item_expr

          e.item_value = scope.evaluate e.item_expr

          if e.item_value.class == Fixnum
            e.item_value = [ e.item_value ]
          elsif e.item_value.class == Array
            if (e.item_value.select { |v| v.class != Fixnum }).length > 0
              raise "Item array should be an array of numbers."
            end
          else
            raise "Item value should be an array of numbers or a number but it is an #{e.item_value.class}."
          end

        end

        if e.type_expr

          e.type_value = scope.evaluate e.type_expr

          if e.type_value.class == String
            e.type_value = [ e.type_value ]
            e.quantity_value = [ e.quantity_value ] 
          elsif e.type_value.class == Array
            if (e.type_value.select { |v| v.class != String }).length > 0 ||
               e.quantity_value.class != Array || 
               (e.quantity_value.select { |q| q.class != Fixnum }).length > 0 ||
               e.quantity_value.length != e.type_value.length
              raise "Object type array should be an array of strings with a corresponding quantity array of Fixnums."
            end
          else
            raise "Object type value should be an array of strings or a string but it is an #{e.type_value.class}."
          end

        end

      end

      # Find all items and objects ###################################################################################
      @entry_list.each do |e|

        # Items
        if e.item_value

          e.item_list = []
          e.item_value.each do |item_id|
            i = Item.find(item_id)
            unless i
              raise "Could not find item with id = #{item_id}."
            end
            description = {
              id: item_id,
              objecttype: i.object_type.name,
              quantity: 1, 
              var: e.var,
              location: i.location
            }
            if i.object_type.handler == 'sample_container'
              description[:sample_name] = i.sample.name
              description[:project] = i.sample.project
            end
            e.item_list.push description
          end

        # Objects
        else

          e.object_list = []
          i = 0

          e.type_value.each do |type|

            ob = ObjectType.find_by_name(type)

            # make a new object if one doesn't exist (and we're not in production mode)
            if !ob && Rails.env != 'production'
              ob = ObjectType.new
              ob.save_as_test_type type
              @flash += "Warning: Created new object type #{type}.<br />"
            elsif !ob
              raise "In <take>: Could not find object of type '#{type}', which is not okay in production mode."
            end

            ob[:locations] = ob.items.collect { |i| { id: i.id, loc: i.location } }
            ob[:desired_quantity] = e.quantity_value[i]
            e.object_list.push ob

            i += 1

          end

        end

      end

      # Evaluate the note ###########################################################################################
      @note = scope.substitute @note_expr

    end # pre_render


    def html
      "<b>take</b>" + @entry_list.to_json
    end # html


    def log var, r, scope, params

      data = []

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'TAKE'
      log.data = { pc: @pc, var: var, items: r }.to_json
      log.save

    end # log


    def bt_execute scope, params

      # Evalute @object_list in current scope
      pre_render scope, params

      take = JSON.parse(params[:take],symbolize_names: true );
      puts "TAKE: #{take}"

      i = 0
      @entry_list.each do |e|

        result = []

        # Items
        if e.item_value

          j = 0

          e.item_value.each do |item_id|

            puts "Finding #{take[i][j]}"
            item = Item.find(take[i][j][:id])

            if item.inuse == 0
              result.push( pdl_item item )
              item.inuse += 1
              item.save
            else
              raise "Could not take item #{item.id} because it is in use (was it taken twice?)"
            end

            t = Touch.new
            t.job_id = params[:job]
            t.item_id = item.id
            t.save

            j += 1

          end

        # Objects
        else

          j = 0

          e.type_value.each do |type|

            puts "#{i}, #{j}: #{take[i][j]}, quantity=#{e.quantity_value[j]}"

            item = Item.find(take[i][j][:id])

            if item.quantity - item.inuse > e.quantity_value[j]
              result.push( pdl_item item )
              item.inuse += e.quantity_value[j]
              item.save
            else 
              raise "Could not take #{e.type_value} (item #{item.id}) because it is in use (was it taken twice?)"
            end

            t = Touch.new
            t.job_id = params[:job]
            t.item_id = item.id
            t.save

            j += 1

          end

        end

        scope.set( e.var.to_sym, result )
        log e.var, result, scope, params

        i += 1

    end

    end # bt_execute


  end

end
