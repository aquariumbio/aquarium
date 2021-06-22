# frozen_string_literal: true

# samples table
class Sample < ActiveRecord::Base
  # used to validate feild_types
  attr_accessor :field_value_errors

  validates :name,        presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :project,     presence: true
  validate  :sample_type_id?
  validate  :user_id?
  validate  :field_types?

  # Set serach_text
  def self.set_search_text(params)
      wheres = ""
      if id = params[:sample_type_id]
        wheres = "where s.sample_type_id = #{id.to_i}"
      elsif id = params[:sample_id]
        wheres = "where s.id = #{id.to_i}"
      end

    # NOTE: run in background in case it times out
    background = fork do
      sql ="select s.*, st.name as 'sample_type' from samples s inner join sample_types st on st.id = s.sample_type_id #{wheres}"
      samples = Sample.find_by_sql sql

      samples.each do |sample|
        text = []

        # sample name + description
        text << sample.name if sample.name.to_s.length != 0
        text << sample.description if sample.description.to_s.length != 0
        text << sample.sample_type if sample.sample_type.to_s.length != 0

        # field values
        sql= "select * from view_samples where id =#{sample.id} order by ft_sort"
        temp = Sample.find_by_sql sql
        temp.each do |t|
          if t.ft_id
            text << t.ft_name if t.ft_name.to_s.length != 0
            text << t.fv_value if t.fv_value.to_s.length != 0
            text << t.child_sample_name if t.child_sample_name.to_s.length != 0
          end
        end
        sample.search_text = text.join(' ')
        sample.save
      end
    end
    Process.detach(background)
  end

  # Return a specific sample.
  def self.find_id(id)
    Sample.find_by(id: id)
  end

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
    if words[0,2]=="s:"
      # search sample id only
      this_id = words[2,words.length].strip.split(' ')[0]
      if this_id == this_id.to_i.to_s
        ands << "id = #{this_id}"
      else
        ands << "0"
      end
    elsif words[0,2]=="i:"
      # search item id only
      # ignore discarded items in collections (inuse != -1)
      this_id = words[2,words.length].strip.split(' ')[0]
      if this_id == this_id.to_i.to_s
        ands << "
          id in (
            select distinct if(i.sample_id, i.sample_id, ii.sample_id) from items i
            left join part_associations pa on pa.collection_id = i.id
            left join items ii on ii.id = pa.part_id and ii.inuse != -1
            where i.id = #{this_id}
          )
        "
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
        ands << "search_text like '%#{sanitize_sql_like(word)}%'" if word.length > 1
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
          samples << {
            id: sample.id,
            name: sample.name,
            description: sample.description,
            project: sample.project,
            sample_type_id: sample.sample_type_id,
            sample_type: sample.sample_type.upcase,
            user_name: sample.user_name,
            login: sample.login,
            type: sample.ft_type,
            created_at: sample.created_at,
            fields: []
          }

          # set this_id
          this_id = sample.id
        end

        # update fields for current sample
        # NOTE: there is no ft_id if the sample does not have any field values
        if sample.ft_id
          samples[-1][:fields] << {id: sample.ft_id, type: sample.ft_type, name: sample.ft_name, value: sample.fv_value, child_sample_id: sample.child_sample_id, child_sample_name: sample.child_sample_name}
        end
      end

    end
    return { page: page, count: count, pages: (1.0 * count / per_page).ceil(), samples: samples }
  end

  # Return search results
  def self.quick_search(options)

    sample_type_ids = options[:sample_type_ids].to_s.split('.').map!{|id| id.to_i}.join(',')
    text = options[:text].to_s

    if text[0,2] == "s:"
      this_id = text[2,text.length].strip.split(' ')[0]
      this_id = 0 if this_id != this_id.to_i.to_s

      ands = ["id = #{this_id}"]
      ands << "sample_type_id in (#{sample_type_ids})" if sample_type_ids != ""

      sql = "select id, name from samples where #{ands.join(' and ')} limit 1"
      Sample.find_by_sql sql
    else
      ands = []
      ands << "sample_type_id in (#{sample_type_ids})" if sample_type_ids != ""

      ok = false
      words = text.split(' ')
      words.each do |word|
        if word.length > 1
          ands << "name like '%#{sanitize_sql_like(word)}%'"
          ok = true
        end
      end

      return [] if !ok

      sql = "select id, name from samples where #{ands.join(' and ')} order by id desc limit 100"
      Sample.find_by_sql sql
    end
  end

  # Return sample + inventory data
  def self.get_sample(id)
    # get all field values
    sql = "select * from view_samples where id = #{id} order by ft_sort, ft_name, fv_id"
    sample_data = Sample.find_by_sql sql
    return nil, nil if sample_data.length == 0

    # initialize new_sample
    this_sample = sample_data[0]
    sample = {
      id: this_sample.id,
      name: this_sample.name,
      description: this_sample.description,
      project: this_sample.project,
      sample_type_id: this_sample.sample_type_id,
      sample_type: this_sample.sample_type.upcase,
      user_name: this_sample.user_name,
      login: this_sample.login,
      type: this_sample.ft_type,
      created_at: this_sample.created_at,
      fields: []
    }

    # loop through field values and append to sample.fields array
    sample_data.each do |s|
      sample[:fields] << {id: s.ft_id, type: s.ft_type, name: s.ft_name, value: s.fv_value, child_sample_id: s.child_sample_id, child_sample_name: s.child_sample_name}
    end

    # get items + collections from inventory
    # NOTES:
    # - collection_id could appear multilpe times
    # - ignore discarded items in collections (collection_id is null or collection_id is not null and inuse != -1)
    sql = "
      select *
      from view_inventories
      where id = #{id} and (collection_id is null or collection_id is not null and inuse != -1)
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
            collections: [{part_id: s.item_id, row: s.row, column: s.column}],
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
        this_data[:collections] << {part_id: s.item_id, row: s.row, column: s.column}
      end
      inv[this_id] = this_data
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
        wip.merge!({ this_id => { type_id: this_id, type: v[:type], count_inventory: 0, count_deleted: 0, data: [] } })
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

  def self.create_from(obj, user_id)
    # set basic attributes
    sample_type_id = obj[:sample_type_id]
    name = Input.text(obj[:name])
    description = Input.text(obj[:description])
    project = Input.text(obj[:project])

    # create sample object and fill in basic data
    sample = Sample.new({
      user_id: user_id,
      sample_type_id: sample_type_id,
      name: name,
      description: description,
      project: project
    })

    # loop through field types to get field values and check for errors
    field_values, validation_errors = sample.validate_field_types?(obj)
    sample.field_value_errors = validation_errors

    # check if valid
    return nil, sample.errors if !sample.valid?

    # save sample
    sample.save

    # save field values
    # loop through field_values and save each one
    field_values.each do |field_value|
      FieldValue.create({
        parent_id: sample.id,
        parent_class: 'Sample',
        field_type_id: field_value[:field_type_id],
        name: field_value[:name], # name of field type (redundant, should make sure nothing else uses it and remove it)
        value: field_value[:value], # for anything other than samples
        child_sample_id: field_value[:child_sample_id] # for samples
      })
    end

    return sample, nil
  end

  # update sample type
  def update_with(obj, user_id)
    # set basic attributes
    sample_type_id = obj[:sample_type_id]
    name = Input.text(obj[:name])
    description = Input.text(obj[:description])
    project = Input.text(obj[:project])

    # update sample object
    self.user_id = user_id
    self.sample_type_id = sample_type_id
    self.name = name
    self.description = description
    self.project = project

    # loop through field types to get field values and check for errors
    field_values, validation_errors = self.validate_field_types?(obj)
    self.field_value_errors = validation_errors

    # check if valid
    return nil, errors if !valid?

    # save sample
    self.save

    # delete existing field values
    sql = "delete from field_values where parent_id = #{self.id} and parent_class = 'Sample'"
    FieldValue.connection.execute sql

    # save new field values
    # loop through field_values and save each one
    field_values.each do |field_value|
      FieldValue.create({
        parent_id: self.id,
        parent_class: 'Sample',
        field_type_id: field_value[:field_type_id],
        name: field_value[:name], # name of field type (redundant, should make sure nothing else uses it and remove it)
        value: field_value[:value], # for anything other than samples
        child_sample_id: field_value[:child_sample_id] # for samples
      })
    end

    return self, nil
  end

  def validate_field_types?(obj)
    # get field types from sample type details
    # - check required fields
    # - create field_values array and field_value_errors array
    # - if there are no field_value_errors then we can save the field_values later
    field_values = []
    field_value_errors = []

    # loop through inputs for each field type
    # - if the field type is required, verify that there is an input
    # - if the field type is an array, verify that each item in the array is not blank
    details = SampleType.details(sample_type_id)
    details[:field_types].each do |field_type|
      # - NOTE: assume the inputs conform to any restrictions
      if field_type["ftype"] == "sample" or field_type["array"]
        # The inputs should be an array
        inputs = obj["f.#{field_type["id"]}"]

        if field_type["required"] and inputs.length == 0
          field_value_errors << "#{field_type["name"]} required"
        else
          inputs.each_with_index do |input, index|
            temp = Input.text(input)
            if !temp
              field_value_errors << "#{field_type["name"]}[#{index+1}] cannot be blank"
            elsif field_type["ftype"] == "sample"
              field_values << {
                field_type_id: field_type['id'],
                name: field_type['name'],
                field_type_id: field_type['id'],
                child_sample_id: input.to_i
              }
            else
              field_values << {
                field_type_id: field_type['id'],
                name: field_type['name'],
                field_type_id: field_type['id'],
                value: input
              }
            end
          end
        end
      else
        # the input should be a single value
        input = Input.text(obj["f.#{field_type["id"]}"])
        if input
          field_values << {
            field_type_id: field_type['id'],
            name: field_type['name'],
            field_type_id: field_type['id'],
            value: input
          }
        elsif field_type["required"]
          field_value_errors << "#{field_type["name"]} required"
        end
      end
    end
    return field_values, field_value_errors
  end

  private

  def sample_type_id?
    errors.add(:sample_type_id, 'not valid')  if !SampleType.find_by(id: sample_type_id)
  end

  def user_id?
    errors.add(:user_id, 'not valid')  if !User.find_by(id: user_id)
  end

  def field_types?
    field_value_errors.to_a.each do |e|
      errors.add(:field_types, e)
    end
  end

end
