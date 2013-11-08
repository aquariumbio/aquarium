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

      if @info_expr[:inuse]

        begin
          @info[:inuse] = (scope.evaluate @info_expr[:inuse]).to_i
        rescue Exception => e
          raise "Inuse expression '#{@info_expr[:inuse]}' did not evaluate correctly."
        end

      end

      begin
        item = Item.find(@info[:item][:id])
      rescue Exception => e
        raise "Could not find item with #{@info[:item][:id]}"
      end

      old_inuse = item.inuse
      old_location = item.location

      if @info[:location]
        item.location = @info[:location]
      end

      if @info[:inuse]
        item.inuse = @info[:inuse]
      end

      item.save

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'MODIFY'
      log.data = { pc: @pc, item_id: @info[:item][:id], 
                   old: { location: old_location, inuse: old_inuse }, 
                   new: { location: item.location, inuse: item.inuse } }.to_json
      log.save

    end

    def html
      "<b>modify</b> #{@info_expr}"
    end

  end

end
