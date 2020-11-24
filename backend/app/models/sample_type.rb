# sample_types table
class SampleType < ActiveRecord::Base

  validates :name,        presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  # Return all sample types.
  #
  # @return all sample types
  def self.find_all
    sql = "
      select * from sample_types order by name
    "
    SampleType.find_by_sql sql
  end

  def self.find_id(id)
    sql = "
      select * from sample_types where id = #{id} limit 1
    "
    (SampleType.find_by_sql sql)[0]
  end

  # Return details for a specific sample types.
  #
  # @param id [Int] the id of the sample type
  #
  # @return the sample types
  def self.details(id)
    # GET FEILD TYPES
    sql = "
      select *, null as 'allowable_field_types'
      from field_types ft
      where ft.parent_class = 'SampleType' and ft.parent_id = #{id}
      order by ft.name
    "
    field_types = FieldType.find_by_sql sql

    # GET SAMPLE_OPTIONS FOR FIELD_TYPE == "SAMPLE"
    # MAKES <N> CALLS TO THE DB BUT <N> SHOULD NOT BE LARGE
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

    # GET INVENTORY
    # TODO -- IMPLEMENT THIS WHEN IMPLEMENT INVENTORY
    inventory = 0

    # GET OBJECT TYPES (CONTAINERS)
    sql = "
      select * from object_types where sample_type_id = #{id} order by name
    "
    object_types = ObjectType.find_by_sql sql

    return { field_types: field_types, inventory: inventory, object_types: object_types }
  end

  # Create a sample types.
  #
  # @param st [Hash] the sample type
  #
  # @option st[:name] [String] the name of the sample type
  # @option st[:description] [String] the description of the sample type
  # @option st[:field_types] [Hash] the field_type attributes associated with the sample type
  #
  # feild_types = {
  #   name [String] name
  #   ftype [String]  ftype
  #   required [String] required - interpreted as Boolen
  #   array [String] array - interpreted as Boolean
  #   choices [String] choices
  #   allowable_field_types [Array] array of allowable field types (for ftype = "sample")
  # }
  #
  # allowable_field_type = {
  #   sample_type_id [Int] id of the allowable field type
  # }
  #
  # @return the sample type
  def self.create(st)
    name = Input.text(st[:name])
    description = Input.text(st[:description])

    # CREATE TEH SAMPLE TYPE
    sample_type_new = SampleType.new
    sample_type_new.name = name
    sample_type_new.description = description

    valid = sample_type_new.valid?
    return false, sample_type_new.errors if !valid

    # SAVE THE SAMPLE TYPE IF IT IS VALID
    sample_type_new.save

    # SAVE FIELD TYPE IF THERE IS A FIELD NAME
    if st[:field_types].kind_of?(Array)
      st[:field_types].each do |ft|
        fname     = Input.text(ft[:name])
        ftype     = Input.text(ft[:ftype])
        frequired = Input.boolean(ft[:required])
        farray    = Input.boolean(ft[:array])
        fchoices  = Input.text(ft[:choices])

        if fname != ""
          field_type_new  = FieldType.new

          field_type_new.parent_id    = sample_type_new.id
          field_type_new.name         = fname
          field_type_new.ftype        = ftype
          field_type_new.choices      = fchoices
          field_type_new.array        = farray
          field_type_new.required     = frequired
          field_type_new.parent_class = "SampleType"
          field_type_new.save

          # SAVE ALLOWABLE FIELD TYPES IF THE FIELD TYPE IS "SAMPLE"
          if ftype == "sample" and ft[:allowable_field_types].kind_of?(Array)
            ft[:allowable_field_types].each do |aft|
              sample_type_id = Input.number(aft[:sample_type_id])
              sql = "select * from sample_types where id = #{sample_type_id} limit 1"

              if (SampleType.find_by_sql sql)[0]
                allowable_field_type_new  = AllowableFieldType.new

                allowable_field_type_new.field_type_id  = field_type_new.id
                allowable_field_type_new.sample_type_id = sample_type_id
                allowable_field_type_new.save
              end
            end
          end
        end
      end
    end

    return sample_type_new, false

  end

  # Update existing sample type
  # - Keeps any existing field types (and changes them as necessary)
  # - Removes any feild types that no longer exist
  # - Adds any new feild types
  # - Also updates allowable field types for each field type
  # - Any potential errors are handled automatically and silently
  #
  # @param st [Hash] the sample type
  #
  # @option st[:id] [Int] the id of the sample type
  # @option st[:name] [String] the name of the sample type
  # @option st[:description] [String] the description of the sample type
  # @option st[:field_types] [Hash] the field_type attributes associated with the sample type
  #
  # feild_types = {
  #   id [Int] the id of the existing field type <or> nil if it is new
  #   name [String] name
  #   ftype [String]  ftype
  #   required [String] required - interpreted as Boolen
  #   array [String] array - interpreted as Boolean
  #   choices [String] choices
  #   allowable_field_types [Array] array of allowable field types (for ftype = "sample")
  # }
  #
  # allowable_field_type = {
  #   id [Int] the id of the existing allowable field type <or> nil if it is new
  #   sample_type_id [Int] id of the allowable field type
  # }
  #
  # @return the sample type
  def update(st)
    input_name = Input.text(st[:name])
    input_description = Input.text(st[:description])

    # Update name and description if not blank
    self.name = input_name if input_name
    self.description = input_description if input_description

    # Update the sample type name and description if valid (otherwise leave as is)
    self.save if self.valid?

    # List of field type ids
    # - Used to delete field types that were removed on update
    # - Initialize with id = 0 to generate the appropriate sql query later
    field_type_ids = [0]

    # Save field type if there is a field name
    if st[:field_types].kind_of?(Array)
      st[:field_types].each do |ft|
        # List of allowable field type ids for this field_type_id
        # - Used to delete allowable field types that were removed on update
        # - Initialize with id = 0 to generate the appropriate sql query later
        allowable_field_type_ids = [0]

        fid       = Input.number(ft[:id])
        fname     = Input.text(ft[:name])
        ftype     = Input.text(ft[:ftype])
        frequired = Input.boolean(ft[:required])
        farray    = Input.boolean(ft[:array])
        fchoices  = Input.text(ft[:choices])

        # Find existing feild_type or create new one
        sql = "select * from field_types where id = #{fid} and parent_id = #{self.id} limit 1"

        field_type_update = (FieldType.find_by_sql sql)[0] || FieldType.new

        # Set fname if exists and input is not blank
        # Awkward logic, but that's how it works in v2
        fname = fname || field_type.name

        if fname != ""
          field_type_update.parent_id    = self.id
          field_type_update.name         = fname
          field_type_update.ftype        = ftype
          field_type_update.choices      = fchoices
          field_type_update.array        = farray
          field_type_update.required     = frequired
          field_type_update.parent_class = "SampleType"
          field_type_update.save

          # Append to list of field_type_ids
          field_type_id = field_type_update.id
          field_type_ids << field_type_id

          # Save allowable field types if the field type is "sample"
          if ftype == "sample" and ft[:allowable_field_types].kind_of?(Array)
            ft[:allowable_field_types].each do |aft|
              # Verify that the sample_type_id is valid
              sample_type_id = Input.number(aft[:sample_type_id])
              sql = "select * from sample_types where id = #{sample_type_id} limit 1"

              if (SampleType.find_by_sql sql)[0]
                # Find existing allowable_field_type or create new one
                allowable_field_type_id = Input.number(aft[:id])
                sql = "select * from allowable_field_types where id = #{allowable_field_type_id} and field_type_id = #{field_type_id} limit 1"
                allowable_field_type_update = (AllowableFieldType.find_by_sql sql)[0] || AllowableFieldType.new

                # Create / update the allowable_field_type
                allowable_field_type_update.field_type_id  = field_type_id
                allowable_field_type_update.sample_type_id = sample_type_id
                allowable_field_type_update.save

                # Append to list of allowable_field_type_ids for this field_type_id
                allowable_field_type_ids << allowable_field_type_update.id
              end
            end
          end

          # Remove allowable_field_types for this field type that are no loner defined
          sql = "delete from allowable_field_types where field_type_id = #{field_type_id} and id not in (#{allowable_field_type_ids.join(",")})"
          AllowableFieldType.connection.execute sql
        end
      end
    end

    # Remove field_types that are no longer defined
    # Note: automatically removes allowable field types tied to these field types using mysql foreign key + ondelete cascade
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
