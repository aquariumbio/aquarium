# SAMPLE_TYPES TABLE
class SampleType < ActiveRecord::Base

  validates :name,        presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

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

  # UPDATE EXISTING SAMPLE TYPE
  # - UPDATE THE SAMPLE TYPE
  # - KEEP ANY EXISTING FIELD TYPES (AND CHANGE THEM AS NECESSARY)
  # - REMOVE ANY FEILD TYPES THAT NO LONGER EXIST
  # - ADD ANY NEW FEILD TYPES
  # - ALSO UPDATE ALLOWABLE FIELD TYPES FOR EACH FIELD TYPE
  # ANY ERRORS ARE HANDLED AUTOMATICALLY AND SILENTLY
  def update(st)
    input_name = Input.text(st[:name])
    input_description = Input.text(st[:description])

    # CHECK FOR DUPLICATES

    # UPDATE NAME AND DESCRIPTION IF NOT BLANK
    self.name = input_name if input_name
    self.description = input_description if input_description

    # UPDATE THE SAMPLE TYPE NAME AND DESCRIPTION IF VALID (OTHERWISE LEAVE AS IS)
    self.save if self.valid?

    # LIST OF FIELD TYPE IDS
    # - USED TO DELETE FIELD TYPES THAT WERE REMOVED ON UPDATE
    # - INITIALIZE WITH ID = 0 TO GENERATE THE APPROPRIATE SQL QUERY LATER
    field_type_ids = [0]

    # SAVE FIELD TYPE IF THERE IS A FIELD NAME
    if st[:field_types].kind_of?(Array)
      st[:field_types].each do |ft|
        # LIST OF ALLOWABLE FIELD TYPE IDS FOR THIS FIELD_TYPE_ID
        # - USED TO DELETE ALLOWABLE FIELD TYPES THAT WERE REMOVED ON UPDATE
        # - INITIALIZE WITH ID = 0 TO GENERATE THE APPROPRIATE SQL QUERY LATER
        allowable_field_type_ids = [0]

        fid       = Input.number(ft[:id])
        fname     = Input.text(ft[:name])
        ftype     = Input.text(ft[:ftype])
        frequired = Input.boolean(ft[:required])
        farray    = Input.boolean(ft[:array])
        fchoices  = Input.text(ft[:choices])

        # FIND EXISTING FEILD_TYPE OR CREATE NEW ONE
        sql = "select * from field_types where id = #{fid} and parent_id = #{self.id} limit 1"

        field_type_update = (FieldType.find_by_sql sql)[0] || FieldType.new

        # SET FNAME IF EXISTS AND INPUT IS NOT BLANK
        # AWKWARD LOGIC, BUT THAT'S HOW IT WORKS IN V2
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

          # APPEND TO LIST OF FIELD_TYPE_IDS
          field_type_id = field_type_update.id
          field_type_ids << field_type_id

          # SAVE ALLOWABLE FIELD TYPES IF THE FIELD TYPE IS "SAMPLE"
          if ftype == "sample" and ft[:allowable_field_types].kind_of?(Array)
            ft[:allowable_field_types].each do |aft|
              # VERIFY THAT THE SAMPLE_TYPE_ID IS VALID
              sample_type_id = Input.number(aft[:sample_type_id])
              sql = "select * from sample_types where id = #{sample_type_id} limit 1"

              if (SampleType.find_by_sql sql)[0]
                # FIND EXISTING ALLOWABLE_FIELD_TYPE OR CREATE NEW ONE
                allowable_field_type_id = Input.number(aft[:id])
                sql = "select * from allowable_field_types where id = #{allowable_field_type_id} and field_type_id = #{field_type_id} limit 1"
                allowable_field_type_update = (AllowableFieldType.find_by_sql sql)[0] || AllowableFieldType.new

                # CREATE / UPDATE THE ALLOWABLE_FIELD_TYPE
                allowable_field_type_update.field_type_id  = field_type_id
                allowable_field_type_update.sample_type_id = sample_type_id
                allowable_field_type_update.save

                # APPEND TO LIST OF ALLOWABLE_FIELD_TYPE_IDS FOR THIS FIELD_TYPE_ID
                allowable_field_type_ids << allowable_field_type_update.id
              end
            end
          end

          # REMOVE ALLOWABLE_FIELD_TYPES FOR THIS FIELD TYPE THAT ARE NO LONER DEFINED
          sql = "delete from allowable_field_types where field_type_id = #{field_type_id} and id not in (#{allowable_field_type_ids.join(",")})"
          AllowableFieldType.connection.execute sql
        end
      end
    end

    # REMOVE FIELD_TYPES THAT ARE NO LONGER DEFINED
    # NOTE: AUTOMATICALLY REMOVES ALLOWABLE FIELD TYPES TIED TO THESE FIELD TYPES USING MYSQL FOREIGN KEY + ONDELETE CASCADE
    sql = "delete from field_types where parent_id = #{self.id} and id not in (#{field_type_ids.join(",")})"
    FieldType.connection.execute sql

    return self
  end

  def delete_sample_type
    # DELETE FIELD_TYPES (THEY DO NOT HAVE FOREIGN KEYS)
    sql = "delete from field_types where parent_class = 'SampleType' and parent_id = #{self.id}"
    FieldType.connection.execute sql

    # DELETE SELF
    self.delete

    return true
  end

end
