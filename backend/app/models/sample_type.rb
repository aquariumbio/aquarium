# sample_types table
class SampleType < ActiveRecord::Base

  validates :name,        presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  # Return all sample types.
  #
  # @return all sample types
  def self.find_all
    SampleType.order(:name)
  end

  # Return a specific sample type.
  #
  # @param id [Int] the id of the sample type
  # @return the sample types
  def self.find_id(id)
    SampleType.find_by(id: id)
  end

  # Return details for a specific sample type.
  #
  # @param id [Int] the id of the sample type
  # @return the sample type details
  def self.details(id)
    # Get feild types
    sql = "
      select *, null as 'allowable_field_types'
      from field_types ft
      where ft.parent_class = 'SampleType' and ft.parent_id = #{id}
      order by ft.name
    "
    field_types = FieldType.find_by_sql sql

    # Get sample_options for field_type == "sample"
    # Makes <n> calls to the db but <n> should not be large
    field_types.each do |ft|
      if ft.ftype == "sample"
        sql = "
          select aft.id, aft.field_type_id, aft.sample_type_id, st.name
          from allowable_field_types aft
          inner join sample_types st on st.id = aft.sample_type_id
          where aft.field_type_id = #{ft.id}
          order by st.name
        "
        allowable_field_types = AllowableFieldType.find_by_sql sql

        ft = ft.update( {allowable_field_types: allowable_field_types} )
      end
    end

    # Get inventory
    # Todo -- implement this when implement inventory
    inventory = 0

    # Get object types (containers)
    sql = "
      select * from object_types where sample_type_id = #{id} order by name
    "
    object_types = ObjectType.find_by_sql sql

    return { field_types: field_types, inventory: inventory, object_types: object_types }
  end

  # Create a sample types.
  #
  # @param sample_type [Hash] the sample type
  # @option sample_type[:name] [String] the name of the sample type
  # @option sample_type[:description] [String] the description of the sample type
  # @option sample_type[:field_types] [Hash] the field_type attributes associated with the sample type
  # @return the sample type
  def self.create(sample_type)
    name = Input.text(sample_type[:name])
    description = Input.text(sample_type[:description])

    # Create the sample type
    sample_type_new = SampleType.new
    sample_type_new.name = name
    sample_type_new.description = description

    valid = sample_type_new.valid?
    return false, sample_type_new.errors if !valid

    # Save the sample type if it is valid
    sample_type_new.save

    # Save each field type if the name is not blank
    if sample_type[:field_types].kind_of?(Array)
      sample_type[:field_types].each do |field_type|
        fname = Input.text(field_type[:name])
        FieldType.create_sampletype(sample_type_new.id, field_type) if fname != ""
      end
    end

    return sample_type_new, false
  end

  # Update a sample type
  # - Keeps any existing field types (and changes them as necessary)
  # - Removes any feild types that no longer exist
  # - Adds any new feild types
  # - Also updates allowable field types for each field type
  # - Any potential errors are handled automatically and silently
  #
  # @param sample_type [Hash] the sample type
  # @option sample_type[:name] [String] the name of the sample type
  # @option sample_type[:description] [String] the description of the sample type
  # @option sample_type[:field_types] [Hash] the field_type attributes associated with the sample type
  # @return the sample type
  def update(sample_type)
    input_name = Input.text(sample_type[:name])
    input_description = Input.text(sample_type[:description])

    # Update name and description if not blank
    self.name = input_name if input_name
    self.description = input_description if input_description

    # Update the sample type name and description if valid (otherwise leave as is)
    self.save if self.valid?

    # List of field type ids
    # - Used to delete field types that were removed on update
    # - Initialize with id = 0 to generate the appropriate sql query later
    field_type_ids = [0]

    # Update the field type and append the id to field_type_ids
    if sample_type[:field_types].kind_of?(Array)
      sample_type[:field_types].each do |field_type|
        field_type_ids << FieldType.update_sampletype(self.id, field_type)
      end
    end

    # Remove field_types that are no longer defined
    # NOTE: also automatically removes allowable field types tied to these field types using mysql foreign key + ondelete cascade
    # NOTE: Could move this to ield_type.rb but left it here because it is custom to the update
    sql = "delete from field_types where parent_id = #{self.id} and id not in (#{field_type_ids.join(",")})"
    FieldType.connection.execute sql

    return self
  end

  def delete_sample_type
    # Delete field_types (they do not have foreign keys)
    sql = "delete from field_types where parent_class = 'SampleType' and parent_id = #{self.id}"
    FieldType.connection.execute sql

    # Delete self
    self.delete

    return true
  end

end
