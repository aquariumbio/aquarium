# field_types table
class FieldType < ActiveRecord::Base
  # Create a field type
  #
  # @param field_type [Hash] the field type
  # @option field_type[:name] [String] name
  # @option field_type[:ftype] [String]  ftype
  # @option field_type[:required] [Boolean] required ( <true/false> or <on/off> or <1/0> )
  # @option field_type[:array] [Boolean] array ( <true/false> or <on/off> or <1/0> )
  # @option field_type[:choices] [String] choices
  # @option field_type[:allowable_field_types] [Array] array of allowable field types (for ftype == "sample")
  # @return true
  def self.create_sampletype(parent_id, field_type)
    # Read the parameters
    fname     = Input.text(field_type[:name])
    ftype     = Input.text(field_type[:ftype])
    frequired = Input.boolean(field_type[:required]) ? 1 : nil
    farray    = Input.boolean(field_type[:array]) ? 1 : nil
    fchoices  = Input.text(field_type[:choices])

    field_type_new = FieldType.new(
      parent_id: parent_id,
      name: fname,
      ftype: ftype,
      choices: fchoices,
      array: farray,
      required: frequired,
      parent_class: "SampleType"
    )
    field_type_new.save

    # Save allowable field types if the field type is "sample"
    if ftype == "sample" and field_type[:allowable_field_types].kind_of?(Array)
      field_type[:allowable_field_types].each do |aft|
        AllowableFieldType.create_from(field_type_new.id, aft)
      end
    end

    return true
  end

  # Update or create a new field type (if the id does not exist)
  #
  # @param field_type = [Hash] field type
  # @option field_type[:id] id [Int] the id of the existing field type
  # @option field_type[:name] [String] name
  # @option field_type[:ftype] [String]  ftype
  # @option field_type[:required] [Boolean] required ( <true/false> or <on/off> or <1/0> )
  # @option field_type[:array] [Boolean] array ( <true/false> or <on/off> or <1/0> )
  # @option field_type[:choices] [String] choices
  # @option field_type[:allowable_field_types] [Array] array of allowable field types (for ftype == "sample")
  # @return the id of the field type or 0 (if the id does not exist and the name is blank)
  def self.update_sampletype(parent_id, field_type)
    # List of allowable field type ids for this field_type_id
    # - Used to delete allowable field types that were removed on update
    # - Initialize with id = 0 to generate the appropriate sql query later
    allowable_field_type_ids = [0]

    # Find existing field_type or create new one
    fid = Input.int(field_type[:id])
    sql = "select * from field_types where id = #{fid} and parent_id = #{parent_id} limit 1"
    field_type_update = (FieldType.find_by_sql sql)[0] || FieldType.new

    # Reset fname if it is blank and the id exists
    fname = Input.text(field_type[:name])
    fname = fname || field_type_update.name
    return 0 if !fname

    # Save the field_type
    ftype     = Input.text(field_type[:ftype])
    frequired = Input.boolean(field_type[:required]) ? 1 : nil
    farray    = Input.boolean(field_type[:array]) ? 1 : nil
    fchoices  = Input.text(field_type[:choices])

    field_type_update.parent_id    = parent_id
    field_type_update.name         = fname
    field_type_update.ftype        = ftype
    field_type_update.required     = frequired
    field_type_update.array        = farray
    field_type_update.choices      = fchoices
    field_type_update.parent_class = "SampleType"
    field_type_update.save

    # Set the id
    field_type_id = field_type_update.id

    # Save allowable field types if the field type is "sample"
    if ftype == "sample" and field_type[:allowable_field_types].kind_of?(Array)
      field_type[:allowable_field_types].each do |allowable_field_type|
        # Update the allowable field type and append the id to list of allowable_field_type_ids
        allowable_field_type_ids << AllowableFieldType.update(field_type_id, allowable_field_type)
      end
    end

    # Remove allowable_field_types for this field type that are no loner defined
    # NOTE: Could move this to allowable_field_type.rb but left it here because it is custom to the update
    sql = "delete from allowable_field_types where field_type_id = #{field_type_id} and id not in (#{allowable_field_type_ids.join(",")})"
    AllowableFieldType.connection.execute sql

    return field_type_update.id
  end
end
