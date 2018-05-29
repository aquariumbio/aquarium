# frozen_string_literal: true

module Plankton

  class ModifyInstruction < Instruction

    def initialize(info, options = {})
      @info_expr = info
      @renderable = false
      super 'move', options
    end

    # RAILS ##################################################################################

    def bt_execute(scope, params)

      @info = {}

      begin
        @info[:item] = scope.evaluate @info_expr[:item]
      rescue Exception => e
        raise "Could not evaluate '#{@info_expr[:item]}' in modify block." + e.message
      end

      raise "Item expression '#{@info[:item]}' is not an item hash." if @info[:item].class != Hash || @info[:item][:id].nil?

      if @info_expr[:location]

        begin
          @info[:location] = scope.evaluate @info_expr[:location]
        rescue Exception => e
          raise "Location expression '#{@info_expr[:location]}' did not evaluate correctly."
        end

        raise "Location expression '#{@info_expr[:location]}' did not evaluate to a string." if @info[:location].class != String

      end

      keys = %i[inuse dinuse iinuse quantity dquantity iquantity]

      keys.each do |key|

        next unless @info_expr[key]

        begin
          @info[key] = (scope.evaluate @info_expr[key]).to_i
        rescue Exception => e
          raise "Inuse expression '#{@info_expr[key]}' did not evaluate correctly."
        end

      end

      begin
        item = Item.find(@info[:item][:id])
      rescue Exception => e
        raise "Could not find item with #{@info[:item][:id]}"
      end

      old = { location: item.location, inuse: item.inuse, quantity: item.quantity }

      item.location  = @info[:location] if @info[:location]
      item.inuse     = @info[:inuse] if @info[:inuse]
      item.inuse    -= @info[:dinuse] if @info[:dinuse]
      item.inuse    += @info[:iinuse] if @info[:iinuse]
      item.quantity  = @info[:quantity] if @info[:quantity]
      item.quantity -= @info[:dquantity] if @info[:dquantity]
      item.quantity += @info[:iquantity] if @info[:iquantity]

      item.save

      # Probably should not delete items because then you can't get their histories
      # if item.quantity == 0
      #  item.destroy
      # end

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
