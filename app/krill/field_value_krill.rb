# @api krill
module FieldValueKrill

  def retrieve

    if child_item_id

      @item = Item.find_by_id(child_item_id)

    elsif !predecessors.empty?

      # TODO: THIS SHOULD USE THE ACTIVE PREDECESSOR, IN CASE THERE IS MORE THAN ONE
      #       FILTER BY STATUS (e.g. "done")?
      copy_inventory(predecessors[0])

    else

      items = if object_type && !field_type.part
                Item.where(sample_id: child_sample_id, object_type_id: object_type.id).reject(&:deleted?)
              elsif object_type && field_type.part
                Collection.containing(val, object_type).reject(&:deleted?)
              else
                Item.where(sample_id: child_sample_id).reject(&:deleted?)
              end

      unless items.empty?
        @item = items[0]
        self.child_item_id = @item.id
        if @item.class == Collection
          p = @item.position_as_hash child_sample
          self.row = p[:row]
          self.column = p[:column]
        end
        save
      end

    end

    @item

  end

  def make

    if object_type
      @item = Item.make({ quantity: 1, inuse: 0 }, sample: child_sample, object_type: object_type)
      @item.store if @item.location == 'Unknown'
      self.child_item_id = @item.id
      save
    else
      puts "COULD NOT MAKE ITEM FOR FV #{id} BECAUSE object_type = null"
    end

    @item

  end

  def make_collection

    ot = object_type

    if ot && ot.handler == 'collection'
      c = Collection.new_collection(object_type.name)
      c.store if c.location == 'Unknown'
      self.child_item_id = c.id
      save
      c
    elsif ot && ot.handler != 'collection'
      raise "Could not make a new collection from the object type name '#{ot.name}', " \
            "because its handler is '#{ot.handler}', not 'collection'"
    else
      raise "Could not find object type: #{object_type}"
    end

  end

  def make_part(collection, r, c)

    if collection
      collection.set r, c, child_sample
      self.child_item_id = collection.id
      self.row = r
      self.column = c
      save
    end

  end

  def info

    si = 'No sample'
    ii = 'No Item'

    if child_sample_id
      sample = Sample.find_by_id(child_sample_id)
      si = if sample
             "#{sample.sample_type.name} #{sample.id} (#{sample.name})"
           else
             "Sample #{child_sample_id} not found!"
           end
    end

    if child_item_id
      item = Item.includes(:object_type).find_by_id(child_item_id)
      ii = if item
             "#{item.object_type.name} #{item.id} at #{item.location}"
           else
             "Item #{child_item_id} not found!"
           end
    end

    "#{name}: { sample: #{si}, item: #{ii}, array: #{field_type.array ? 'true' : 'false'}, part: #{field_type.part ? [row, column] : '-'} }"

  end

  def part?
    field_type && field_type.part
  end

end
