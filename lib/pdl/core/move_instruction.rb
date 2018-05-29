# frozen_string_literal: true

class MoveInstruction < Instruction

  def initialize(item_expr, location_expr, var, options = {})
    @item_expr = item_expr
    @location_expr = location_expr
    @renderable = false
    @var = var
    super 'move', options
  end

  # RAILS ##################################################################################

  def bt_execute(scope, params)

    begin
      item_hash = scope.evaluate @item_expr
      location = scope.evaluate @location_expr
    rescue Exception => e
      raise 'Move: item and/or location expressions did not evaluate correctly. The item should be an item returned by produce, for example. The location should evaluate to a string (you might need quotes around string constants). Check the syntax. ' + e.message
    end

    c = item_hash.class
    console "Attempting move #{item_hash} to #{@location_expr}"

    raise "#{@item_expr} evaluates to #{item_hash}, which is not a Hash describing an item." unless item_hash.class == Hash

    raise "Could not <move> #{@item_expr} to #{@location_expr}" unless item_hash[:id]

    raise "#{@location_expr} evaluates to #{location_expr}, which is not a String" unless location.class == String

    begin
      item = Item.find(item_hash[:id])
    rescue Exception => e
      raise "Could not find item with #{item[:id]}"
    end

    old_location = item.location
    item.location = scope.evaluate @location_expr
    item.save

    scope.set(@var.to_sym, pdl_item(item))

    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'MOVE'
    log.data = { pc: @pc, item_id: item_hash[:id], from: old_location, to: item.location }.to_json
    log.save

  end

  def html
    "<b>move</b> #{@item_expr} to #{@location_expr}"
  end

end
