# frozen_string_literal: true

# plan_associations table
class PartAssociation < ActiveRecord::Base
  # TODO: add validations
  # - check that row is valid
  # - check that column is valid
  # - check that collection_id is a collection
  # - check that part_id is an item

  # Create a part assocation
  #
  # @param item [Hash] the group
  # @option item[:object_type_id] [Int] the object type id
  # @option item[:sample_id] [Int] the sample id
  # return the item
  def self.create_from(part_association)
    # Read the parameters
    part_id = Input.int(part_association[:part_id])
    collection_id = Input.int(part_association[:collection_id])
    row = Input.int(part_association[:row])
    column = Input.int(part_association[:column])

    part_association_new = PartAssociation.new({
      part_id: part_id,
      collection_id: collection_id,
      row: row,
      column: column
    })

    valid = part_association_new.valid?
    return false, part_association_new.errors if !valid

    part_association_new.save

    return part_association_new, false
  end

end
