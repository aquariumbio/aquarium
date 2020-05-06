# typed: false
# frozen_string_literal: true

# @api krill
module FieldValueKrill

  def retrieve
    if child_item_id
      @item = Item.find_by(id: child_item_id)
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
    if object_type && !child_item_id
      @item = Item.make({ quantity: 1, inuse: 0 }, sample: child_sample, object_type: object_type)
      @item.store if @item.location == 'Unknown'
      self.child_item_id = @item.id
      save
    elsif object_type && child_item_id
      Rails.logger.info "Item #{child_item_id} already assigned to field value"
    end

    @item
  end

  def make_collection
    ot = object_type
    raise "Could not find object type: #{object_type}" unless ot

    message = "Cannot make a new collection from object type '#{ot.name}' with handler '#{ot.handler}'"
    raise message if ot.handler != 'collection'

    c = Collection.new_collection(object_type.name)
    c.store if c.location == 'Unknown'
    self.child_item_id = c.id
    save

    c
  end

  def make_part(collection, r, c)
    return unless collection

    collection.set(r, c, child_sample)
    self.child_item_id = collection.id
    self.row = r
    self.column = c
    save
  end

  def info
    si = 'No sample'
    ii = 'No Item'

    if child_sample_id
      sample = Sample.find_by(id: child_sample_id)
      si = if sample
             "#{sample.sample_type.name} #{sample.id} (#{sample.name})"
           else
             "Sample #{child_sample_id} not found!"
           end
    end

    if child_item_id
      item = Item.includes(:object_type).find_by(id: child_item_id)
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
