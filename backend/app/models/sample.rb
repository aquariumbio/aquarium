# frozen_string_literal: true

# samples table
class Sample < ActiveRecord::Base
  validates :name,        presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  # Return search results
  def self.search(options)
    # read parameters
    page = options[:page].to_i
    words = options[:words].to_s
    sample_type_id = options[:sample_type_id].to_i
    user_id = options[:user_id].to_i

    # initialize results per page
    per_page = 24

    # Generate ands for sql query
    ands = []
    if words[0,7]=="sample:"
      # search sample id only
      this_id = words[7,words.length].strip.split(' ')[0]
      if this_id == this_id.to_i.to_s
        ands << "id = #{this_id}"
      else
        ands << "0"
      end
    elsif words[0,5]=="item:"
      # search item id only
      this_id = words[5,words.length].strip.split(' ')[0]
      if this_id == this_id.to_i.to_s
        ands << "id = (select sample_id from items where id = #{this_id})"
      else
        ands << "0"
      end
    elsif words[0,2]=="s:"
      # search sample id only
      this_id = words[2,words.length].strip.split(' ')[0]
      if this_id == this_id.to_i.to_s
        ands << "id = #{this_id}"
      else
        ands << "0"
      end
    elsif words[0,2]=="i:"
      # search item id only
      this_id = words[2,words.length].strip.split(' ')[0]
      if this_id == this_id.to_i.to_s
        ands << "id = (select sample_id from items where id = #{this_id})"
      else
        ands << "0"
      end
    else
      ands << "1"

      # sample_type_id
      ands << "sample_type_id = #{sample_type_id}" if sample_type_id != 0

      # user_id
      ands << "user_id = #{user_id}" if user_id != 0

      # seasrch words
      words = words.split(' ')
      words.each do |word|
        ands << "search_text like '%#{word.gsub('\'','\\\'').gsub('_','\\_').gsub('%','\\%')}%'" if word.length > 1
      end
    end

    # Get count, return empty results if count == 0
    sql = "select count(*) from samples where #{ands.join(' and ')}"
    count = Sample.count_by_sql sql
    return { page: 1, count: 0, pages: 0, samples: [] } if count == 0

    # calculate number of pages
    pages = (1.0 * count / per_page).ceil()

    # scope the page
    page = 1 if page < 1
    page = pages if page > pages

    # search samples
    sql = "select id from samples where #{ands.join(' and ')} order by id desc limit #{per_page} offset #{(page-1) * per_page}"
    list = Sample.find_by_sql sql

    if list.length != 0
      ids = []
      list.each do |l|
        ids << l.id
      end
      sql = "select * from view_samples where id in (#{ids.join(',')}) order by id desc, ft_sort, ft_name, fv_id"
      sample_data = Sample.find_by_sql sql

      # loop through results and populate samples data
      samples = []
      this_id = 0
      new_sample = {}
      fields = []
      sample_data.each do |sample|
        if sample.id != this_id
          # initialize new sample
          sids = sample.item_ids
          samples << {
            id: sample.id,
            name: sample.name,
            description: sample.description,
            sample_type: sample.sample_type.upcase,
            user_name: sample.user_name,
            login: sample.login,
            type: sample.ft_type,
            created_at: sample.created_at,
            item_ids: sids[1,sids.length-2].to_s.split("."),
            fields: [],
            fields_urls: [],
            fields_samples: []
          }

          # set this_id
          this_id = sample.id
        end

        # update fields for current sample
        # NOTE: there is no ft_id if the sample does not have any field values
        if sample.ft_id
          if sample.ft_type == "sample"
            samples[-1][:fields_samples] << {type: sample.ft_type, name: sample.ft_name, value: sample.fv_value, child_sample_id: sample.child_sample_id, child_sample_name: sample.child_sample_name}
          elsif sample.ft_type == "url"
            samples[-1][:fields_urls] << {type: sample.ft_type, name: sample.ft_name, value: sample.fv_value, child_sample_id: sample.child_sample_id, child_sample_name: sample.child_sample_name}
          else
            samples[-1][:fields] << {type: sample.ft_type, name: sample.ft_name, value: sample.fv_value, child_sample_id: sample.child_sample_id, child_sample_name: sample.child_sample_name}
          end
        end
      end

    end
    return { page: page, count: count, pages: (1.0 * count / per_page).ceil(), samples: samples }
  end

  # Return sample + inventory data
  def self.get_sample(id)
    # get all field values
    sql = "select * from view_samples where id = #{id} order by ft_sort, ft_name, fv_id"
    sample_data = Sample.find_by_sql sql
    return nil, nil if sample_data.length == 0

    # initialize new_sample
    this_sample = sample_data[0]
    sids = this_sample.item_ids
    sample = {
      id: this_sample.id,
      name: this_sample.name,
      description: this_sample.description,
      sample_type: this_sample.sample_type.upcase,
      user_name: this_sample.user_name,
      login: this_sample.login,
      type: this_sample.ft_type,
      created_at: this_sample.created_at,
      item_ids: sids[1,sids.length-2].to_s.split("."),
      fields: [],
      fields_urls: [],
      fields_samples: []
    }

    # loop through field values and append to sample.fields array
    sample_data.each do |s|
      if s.ft_type == "sample"
        sample[:fields_samples] << {type: s.ft_type, name: s.ft_name, value: s.fv_value, child_sample_id: s.child_sample_id, child_sample_name: s.child_sample_name}
      elsif s.ft_type == "url"
        sample[:fields_urls] << {type: s.ft_type, name: s.ft_name, value: s.fv_value, child_sample_id: s.child_sample_id, child_sample_name: s.child_sample_name}
      else
        sample[:fields] << {type: s.ft_type, name: s.ft_name, value: s.fv_value, child_sample_id: s.child_sample_id, child_sample_name: s.child_sample_name}
      end
    end

    # get items + collections from inventory
    # NOTES:
    # - collection_id could appear multilpe times
    sql = "
      select *
      from view_inventories
      where id = #{id}
      order by collection_id is not null, collection_type, item_type, collection_id, item_id
    "
    inventory_data = Sample.find_by_sql sql

    # create hash of items / collections
    # NOTES:
    # - single row for items
    # - multiple rows for collections (one for each instance in the collection)
    # - create empty array for data_associations (key_values)
    # - counts for type_id (either item or collection)
    ids = [0]
    inv = {}
    this_id = nil
    this_data = nil
    inventory_data.each do |s|
      id = s.collection_id || s.item_id
      if id != this_id
        this_id = id
        if s.collection_id
          ids << s.collection_id
          this_data = {
            item_id: this_id,
            type_id: s.collection_type_id,
            type: s.collection_type,
            location: s.collection_location,
            date: s.collection_date,
            collections: [{row: s.row, column: s.column}],
            key_values: []
          }
        else
          ids << s.item_id
          this_data = {
            item_id: this_id,
            type_id: s.item_type_id,
            type: s.item_type,
            location: s.item_location,
            date: s.item_date,
            key_values: []
          }
        end
      else
        this_data[:collections] << {row: s.row, column: s.column}
      end
      inv = inv.update({this_id => this_data})
    end

    # get data assocations for items/collections
    # NOTES:
    # - for collection ids, sometimes the parent_class is an item, sometimes it is a collection
    #   (see sample 36319 and sample 36382)
    sql = "
      select da.*, u.upload_file_name, u.upload_content_type
      from data_associations da
      left join uploads u on u.id = da.upload_id
      where parent_id in (#{ids.join(',')}) and parent_class in ('Item', 'Collection')
      order by parent_id, updated_at desc
    "
    data_associations = DataAssociation.find_by_sql sql

    # loop through data_associations and set values
    # NOTES
    # - if multiple parent_id / parent_class / key then only take the latest
    this_parent_id = nil
    this_parent_class = nil
    this_key = nil
    data_associations.each do |da|
      if this_parent_id != da.parent_id || this_parent_class != da.parent_class || this_key != da.key
        this_parent_id = da.parent_id
        this_parent_class = da.parent_class
        this_key = da.key

        # add data_associations
        inv[this_parent_id][:key_values] << {uid: da.id, key: this_key, object: da.object, upload_id: da.upload_id, upload_file_name: da.upload_file_name, upload_content_type: da.upload_content_type}
      end
    end

    # roll up lists of data_associations
    wip = {}
    this_type_id = nil
    inv.each do |k,v|
      if this_id != v[:type_id]
        this_id = v[:type_id]
        wip = wip.update({ this_id => { type_id: this_id, type: v[:type], count_inventory: 0, count_deleted: 0, data: [] } })
      end
      wip[this_id][:data] << v
      if v[:location] == 'deleted'
        wip[this_id][:count_deleted] += 1
      else
        wip[this_id][:count_inventory] += 1
      end
    end

    # only return data
    inventory = []
    wip.each do |k,v|
      inventory << v
    end

    return sample, inventory
  end

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
