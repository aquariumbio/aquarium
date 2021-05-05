# samples table
class Sample < ActiveRecord::Base
#   validates :name,        presence: true, uniqueness: { case_sensitive: false }
#   validates :description, presence: true
#
#   # Return all samples.
#   #
#   # @return all samples
#   def self.find_all
#     Sample.order(:name)
#   end
#
#   # Return a specific sample.
#   #
#   # @param id [Int] the id of the sample
#   # @return the samples
#   def self.find_id(id)
#     Sample.find_by(id: id)
#   end
#
#   # Return details for a specific sample.
#   #
#   # @param id [Int] the id of the sample
#   # @return the sample details
#   def self.details(id)
#     # Get feild types
#     sql = "
#       select *, null as 'allowable_field_types'
#       from field_types ft
#       where ft.parent_class = 'Sample' and ft.parent_id = #{id}
#       order by ft.name
#     "
#     field_types = FieldType.find_by_sql sql
#
#     # Get sample_options for field_type == "sample"
#     # Makes <n> calls to the db but <n> should not be large
#     field_types.each do |ft|
#       if ft.ftype == "sample"
#         sql = "
#           select aft.id, aft.field_type_id, aft.sample_id, st.name
#           from allowable_field_types aft
#           inner join samples st on st.id = aft.sample_id
#           where aft.field_type_id = #{ft.id}
#           order by st.name
#         "
#         allowable_field_types = AllowableFieldType.find_by_sql sql
#
#         ft = ft.update({ allowable_field_types: allowable_field_types })
#       end
#     end
#
#     # Get inventory
#     # Todo -- implement this when implement inventory
#     inventory = 0
#
#     # Get object types (containers)
#     sql = "
#       select * from object_types where sample_id = #{id} order by name
#     "
#     object_types = ObjectType.find_by_sql sql
#
#     return { field_types: field_types, inventory: inventory, object_types: object_types }
#   end
#
#   # Create a samples.
#   #
#   # @param sample [Hash] the sample
#   # @option sample[:name] [String] the name of the sample
#   # @option sample[:description] [String] the description of the sample
#   # @option sample[:field_types] [Hash] the field_type attributes associated with the sample
#   # @return the sample
#   def self.create_from(sample)
#     name = Input.text(sample[:name])
#     description = Input.text(sample[:description])
#
#     # Create the sample
#     sample_new = Sample.new
#     sample_new.name = name
#     sample_new.description = description
#
#     valid = sample_new.valid?
#     return false, sample_new.errors if !valid
#
#     # Save the sample if it is valid
#     sample_new.save
#
#     # Save each field type if the name is not blank
#     if sample[:field_types].kind_of?(Array)
#       sample[:field_types].each do |field_type|
#         fname = Input.text(field_type[:name])
#         FieldType.create_sampletype(sample_new.id, field_type) if fname
#       end
#     end
#
#     return sample_new, false
#   end
#
#   # Update a sample
#   # - Keeps any existing field types (and changes them as necessary)
#   # - Removes any feild types that no longer exist
#   # - Adds any new feild types
#   # - Also updates allowable field types for each field type
#   # - Any potential errors are handled automatically and silently
#   #
#   # @param sample [Hash] the sample
#   # @option sample[:name] [String] the name of the sample
#   # @option sample[:description] [String] the description of the sample
#   # @option sample[:field_types] [Hash] the field_type attributes associated with the sample
#   # @return the sample
#   def update(sample)
#     input_name = Input.text(sample[:name])
#     input_description = Input.text(sample[:description])
#
#     # Update name and description if not blank
#     self.name = input_name if input_name
#     self.description = input_description if input_description
#
#     # Update the sample name and description if valid (otherwise leave as is)
#     self.save if self.valid?
#
#     # List of field type ids
#     # - Used to delete field types that were removed on update
#     # - Initialize with id = 0 to generate the appropriate sql query later
#     field_type_ids = [0]
#
#     # Update the field type and append the id to field_type_ids
#     if sample[:field_types].kind_of?(Array)
#       sample[:field_types].each do |field_type|
#         field_type_ids << FieldType.update_sampletype(self.id, field_type)
#       end
#     end
#
#     # Remove field_types that are no longer defined
#     # NOTE: also automatically removes allowable field types tied to these field types using mysql foreign key + ondelete cascade
#     # NOTE: Could move this to ield_type.rb but left it here because it is custom to the update
#     sql = "delete from field_types where parent_id = #{self.id} and id not in (#{field_type_ids.join(",")})"
#     FieldType.connection.execute sql
#
#     return self
#   end
#
#   def delete_sample
#     # Delete field_types (they do not have foreign keys)
#     sql = "delete from field_types where parent_class = 'Sample' and parent_id = #{self.id}"
#     FieldType.connection.execute sql
#
#     # Delete self
#     self.delete
#
#     return true
#   end
end
