# items table
class Item < ActiveRecord::Base
  validate  :object_type_id_sample_id?

  # get an item
  def self.get_collection(id)
    sql = "
      select i.*
      from items i
      inner join object_types ot on ot.id = i.object_type_id
      where i.id = #{id.to_i} and ot.handler = 'collection'
      limit 1
    "
    item = (Item.find_by_sql sql)[0]

    object_type = item ? ObjectType.find_by(id: item.object_type_id) : nil

    sql = "
      select pa.row, pa.column, i.id as 'item_id', i.sample_id, s.name
      from part_associations pa
      inner join items i on i.id = pa.part_id
      inner join samples s on s.id = i.sample_id
      where pa.collection_id = #{item.id}
    "
    collection = PartAssociation.find_by_sql sql

    return item, object_type, collection
  end

  # Create an item
  #
  # @param item [Hash] the group
  # @option item[:object_type_id] [Int] the object type id
  # @option item[:sample_id] [Int] the sample id
  # return the item

  # TODO: COLLECTIONS (NEW COLLECTION FROM THE SAMPLES PAGE)
  # - location => bench (NOT SURE HOW TO ASSIGN IT TO A LOCATION LATER)
  # - object_type_id => from form
  # - sample_id => null
  # - data => null
  # - locator_id => null
  # NOTE
  # - assign a sample_id to a selection in a collection => creates a new item and assigns that item (plus adds  the part association)
  def self.create_from(item)
    # Read the parameters
    object_type_id = Input.int(item[:object_type_id])
    sample_id = Input.int(item[:sample_id])
    sample_id = nil if sample_id == 0

    item_new = Item.new(
      object_type_id: object_type_id,
      sample_id: sample_id,
      quantity: 1
    )

    valid = item_new.valid?
    return false, false, item_new.errors if !valid

    item_new.save

    # ideally should not have to redefine this (it is done in the validator)
    object_type = ObjectType.find_by(id: object_type_id)

    if object_type.handler == 'collection'
      # collection - add location = 'Bench'
      item_new.location = 'Bench'
      item_new.save
    else
      # single item - add location, locator_id
      locator, location = Locator.create_from(item_new)
      if locator
        item_new.location = location
        item_new.locator_id = locator.id
        item_new.save
      end
    end

    return item_new, object_type, false
  end

  # discard an item
  def discard
    self.location = "deleted"
    self.inuse = -1
    self.save
  end

  private

  def object_type_id_sample_id?
    object_type = ObjectType.find_by(id: object_type_id)
    errors.add(:object_type_id, 'not valid')  if !object_type

    if object_type.handler == 'collection'
      # sample_id must be null if it is a collection
    else
      # sample_id must be valid if it is not a collection
      errors.add(:sample_id, 'not valid')  if !Sample.find_by(id: sample_id)
    end

  end
end
