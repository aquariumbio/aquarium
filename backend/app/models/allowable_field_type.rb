# allowable_field_types table
class AllowableFieldType < ActiveRecord::Base
  # Create an allowable field type
  #
  # @param field_type_id [Int] id of the field type
  # @param allowable_field_type [Hash] the allowable field type
  # @option allowable_field_type[:sample_type_id] [Int] the id of the (allowable) sample type
  # @return true
  def self.create(field_type_id, allowable_field_type)
    sample_type_id = Input.int(allowable_field_type[:sample_type_id])
    sql = "select * from sample_types where id = #{sample_type_id} limit 1"

    if (SampleType.find_by_sql sql)[0]
      allowable_field_type_new = AllowableFieldType.new(
        field_type_id: field_type_id,
        sample_type_id: sample_type_id
      )
      allowable_field_type_new.save
    end

    return true
  end

  # Update an allowable field type
  #
  # @param field_type_id [Int] id of the field type
  # @param allowable_field_type [Hash] the allowable field type
  # @option allowable_field_type[:id] [Int] the id of the allowable field type
  # @option allowable_field_type[:sample_type_id] [Int] the id of the sample type
  # @return id or 0
  def self.update(field_type_id, allowable_field_type)
    # Verify that the sample_type_id is valid
    sample_type_id = Input.int(allowable_field_type[:sample_type_id])
    sql = "select * from sample_types where id = #{sample_type_id} limit 1"
    return 0 if !(SampleType.find_by_sql sql)[0]

    # Find existing allowable_field_type or create new one
    allowable_field_type_id = Input.int(allowable_field_type[:id])
    sql = "select * from allowable_field_types where id = #{allowable_field_type_id} and field_type_id = #{field_type_id} limit 1"
    allowable_field_type_update = (AllowableFieldType.find_by_sql sql)[0] || AllowableFieldType.new

    # Create / update the allowable_field_type
    allowable_field_type_update.field_type_id  = field_type_id
    allowable_field_type_update.sample_type_id = sample_type_id
    allowable_field_type_update.save

    # Return the id
    return allowable_field_type_update.id
  end
end
