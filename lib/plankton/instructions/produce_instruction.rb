module Plankton

  class ProduceInstruction < Instruction

    attr_reader :object_type_name, :quantity, :release, :var, :item, :note, :location
    attr_accessor :sample_expr, :data_expr, :sample_name_expr, :sample_project_expr, :note_expr, :loc_expr, :renderable

    def initialize object_type_expr, quantity_expr, release_expr, var, options = {}

      @object_type_expr = object_type_expr
      @quantity_expr = quantity_expr
      @release_expr = release_expr
      @result_var = var
      @sample_expr = nil
      @data_expr = nil
      @sample_name_expr = nil
      @sample_project_expr = nil

      @renderable = true
      super 'produce', options

      @loc_expr = ""
      @location = ""

    end

    # RAILS ##############################################################################################

    def pre_render scope, params

      # Evaluate arguments
      @object_type_name = scope.evaluate @object_type_expr
      @quantity = scope.evaluate @quantity_expr
      @release = (@release_expr ? (scope.evaluate @release_expr) : nil)
      @note = scope.evaluate @note_expr

      if @release && @release.class != Array
        @release = [@release]
      end

      # If derived from a sample, then figure out which one and put it in @sample
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

      # If a sample name has been provided, figure out which one and put it in @sample
      if @sample_name_expr
        @sample_name = scope.evaluate @sample_name_expr
        begin
          if @sample_name.class != String
            raise "Sample name must be a string"
          end
          @sample = Sample.find_by_name(@sample_name)
          unless @sample
            raise "Could not find sample with name=#{@sample_name}."
          end
        rescue Exception => e
          raise "Could not find sample with name=#{@sample_name}."
        end
      end

      # Parse the data expression
      if @data_expr
        temp = {}
        @data_expr.each do |k, v|
          temp[k] = scope.evaluate v
        end
        @data = temp.to_json
      else
        @data = "{}"
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

      # If pre-render has already been called, just find the item
      if params[:new_item_id]

        @item = Item.find(params[:new_item_id])
        params.delete :new_item_id

      # Otherwise make a new item
      else

        begin
          puts "object_type = #{@object_type.name}"
          puts "sample = #{@sample.name}"
          @item = Item.make({ quantity: @quantity, inuse: 0, data: @data }, sample: @sample, object_type: @object_type)
          puts "errors: #{@item.errors.full_messages.join(',')}"
        rescue Exception => e
          raise "Could not add item of type #{@object_type_name}: " + e.message
        end

        if params['location'] && params['location'] != @item.location
          @item.location = params['location']
          @item.save
          puts "changed location to #{params['location']}"
        end

      end

      @location = scope.evaluate @loc_expr

    end

    def bt_execute scope, params

      # evaluate the expressions to get the item produced when the page was first rendered
      pre_render scope, params

      # change the location if necessary
      if params['location']
        @item.location = params['location']
        @item.save
      elsif @location != ""
        @item.location = @location
        @item.save
      end

      # put the resulting item in the desired variable
      scope.set(@result_var.to_sym, pdl_item(@item))

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
            y.mark_as_deleted
          end

          y.save

          release_data.push object_type: item[:name], item_id: item[:id]
        end
      end

      # save relevant information in the log
      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'PRODUCE'
      log.data = { pc: @pc,
                   item: { location: @item.location, id: @item.id, quantity: 1, data: @data },
                   release: release_data }.to_json
      log.save

    end

    def html
      x = @release ? @release : 'nothing'
      h = "<b>produce</b> #{@quantity_expr} #{@object_type_expr}, releasing #{x}. #{@note_expr}"
    end

  end

end
