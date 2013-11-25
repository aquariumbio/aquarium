module Plankton

  class ModifyInstruction < Instruction

    def initialize info, options = {}
      @info_expr = info
      @renderable = false
      super 'move', options
    end

    # RAILS ##################################################################################

    def bt_execute scope, params

      @info = {}

      begin
        @info[:item] = scope.evaluate @info_expr[:item]
      rescue Exception => e
        raise "Could not evaluate '#{@info_expr[:item]}' in modify block." + e.message
      end

      if @info[:item].class != Hash || @info[:item][:id] == nil
        raise "Item expression '#{@info[:item]}' is not an item hash."
      end

      if @info_expr[:location]

        begin
          @info[:location] = scope.evaluate @info_expr[:location]
        rescue Exception => e
          raise "Location expression '#{@info_expr[:location]}' did not evaluate correctly."
        end

        if @info[:location].class != String
          raise "Location expression '#{@info_expr[:location]}' did not evaluate to a string."
        end

      end

      keys = [ :inuse, :dinuse, :iinuse, :quantity, :dquantity, :iquantity ]

      keys.each do |key|

        if @info_expr[key]

          begin
            @info[key] = (scope.evaluate @info_expr[key]).to_i
          rescue Exception => e
            raise "Inuse expression '#{@info_expr[key]}' did not evaluate correctly."
          end

        end

      end

      begin
        item = Item.find(@info[:item][:id])
      rescue Exception => e
        raise "Could not find item with #{@info[:item][:id]}"
      end

      old = { location: item.location, inuse: item.inuse, quantity: item.quantity }

      if @info[:location];  item.location  = @info[:location];  end
      if @info[:inuse];     item.inuse     = @info[:inuse];     end
      if @info[:dinuse];    item.inuse    -= @info[:dinuse];    end
      if @info[:iinuse];    item.inuse    += @info[:iinuse];    end
      if @info[:quantity];  item.quantity  = @info[:quantity];  end
      if @info[:dquantity]; item.quantity -= @info[:dquantity]; end
      if @info[:iquantity]; item.quantity += @info[:iquantity]; end

      item.save

      # Probably should not delete items because then you can't get their histories
      #if item.quantity == 0
      #  item.destroy
      #end

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'MODIFY'
      log.data = { pc: @pc, item_id: @info[:item][:id], 
                   old: old.to_json, 
                   new: { location: item.location, inuse: item.inuse, quantity: item.quantity } }.to_json
      log.save

    end

    def html
      "<b>modify</b> #{@info_expr}"
    end

  end

end
