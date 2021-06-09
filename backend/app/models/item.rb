# items table
class Item < ActiveRecord::Base
  validate  :object_type_id?
  validate  :sample_id?

  # Create an item
  #
  # @param item [Hash] the group
  # @option item[:object_type_id] [Int] the object type id
  # @option item[:sample_id] [Int] the sample id
  # return the item
  def self.create_from(item)
    # Read the parameters
    object_type_id = Input.int(item[:object_type_id])
    sample_id = Input.int(item[:sample_id])

    item_new = Item.new(
      object_type_id: object_type_id,
      sample_id: sample_id,
      quantity: 1
    )

    valid = item_new.valid?
    return false, item_new.errors if !valid

    item_new.save

    # add locator information (should be removed from here)
    # TODO: remove locator_id - it is a redundant reference
    # TODO: move location to locator.location
    locator, location = Locator.create_from(item_new)
    if locator
      item_new.locator_id = locator.id
      item_new.location = location
      item_new.save
    end

    return item_new, false
  end

  private

  def object_type_id?
    errors.add(:object_type_id, 'not valid')  if !ObjectType.find_by(id: object_type_id)
  end

  def sample_id?
    errors.add(:sample_id, 'not valid')  if !Sample.find_by(id: sample_id)
  end

end
