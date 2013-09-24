class MoveInstruction < Instruction

  def initialize item_expr, location_expr
    @item_expr = item_expr
    @location_expr = location_expr
    @renderable = false
    super 'move'
  end

  # RAILS ##################################################################################

  def bt_execute

    # TODO: Fix error slient-produce.pdl
    #       Make a return var to hold the new item
    #       Make sure only the quantity in the specified item is moved, not the whole item

    item_hash = scope.evaluate @item_expr

    unless item_hash[:id] 
      raise "Could not <move> #{@item_expr} to #{@location_expr}"
    end

    begin
      item = Item.find(item_hash[:id])
    rescue Exception => e
      raise "Could not find item with #{item[:id]}"
    end

    item.location = scope.evaluate @location_expr
    item.save

  end

  def html
    "<b>move</b> #{@item_expr} to #{@location_expr}"
  end

end
