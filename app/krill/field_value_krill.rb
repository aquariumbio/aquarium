module FieldValueKrill

  def retrieve

    if child_item_id
      @item = Item.find_by_id(child_item_id)
    else
      if object_type
        items = Item.where(sample_id: child_sample_id, object_type_id: object_type.id).reject { |i| i.deleted? }
      else
        items = Item.where(sample_id: child_sample_id).reject { |i| i.deleted? }
      end
      unless items.empty?
        @item = items[0]
        self.child_item_id = @item.id
        self.save
      end
    end

    @item

  end

  def make

    if object_type
      @item = Item.make( { quantity: 1, inuse: 0 }, sample: child_sample, object_type: object_type )
      @item.store if @item.location == "Unknown"
      self.child_item_id = @item.id
      self.save
    end

    @item

  end

  def info

    si = "No sample"
    ii = "No Item"

    if child_sample_id
      sample = Sample.find_by_id(child_sample_id)
      if sample
        si = "#{sample.sample_type.name} #{sample.id} (#{sample.name})"
      else
        si = "Sample #{child_sample_id} not found!"
      end
    end

    if child_item_id
      item = Item.includes(:object_type).find_by_id(child_item_id)
      if item
        ii = "#{item.object_type.name} #{item.id} at #{item.location}"
      else
        ii = "Item #{child_item_id} not found!"
      end
    end

    "#{name}: { sample: #{si}, item: #{ii}, array: #{field_type.array ? 'true' : 'false' } }"

  end

end