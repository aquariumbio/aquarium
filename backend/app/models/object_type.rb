# frozen_string_literal: true

# object_types table
class ObjectType < ActiveRecord::Base
  validates :name,             presence: true, uniqueness: { case_sensitive: false }
  validates :description,      presence: true
  validates :min,              presence: true
  validates :max,              presence: true
  validates :unit,             presence: true
  validates :handler,          presence: true # NOTE: added this
  validate  :custom_validator

  # Return a specific object type.
  #
  # @param id [Int] the id of the object type
  # @return the object types
  def self.find_id(id)
    ObjectType.find_by(id: id)
  end

  # Return all object types.
  #
  # @return all object types
  def self.find_handlers
    sql = "
      select distinct handler from object_types order by handler
    "
    ObjectType.find_by_sql sql
  end

  # Return objects for a specific object types.
  #
  # @return the objects
  def self.find_by_handler(handler)
    wheres = sanitize_sql(['handler = ?', handler])
    sql = "
      select * from object_types where #{wheres} order by name
    "
    ObjectType.find_by_sql sql
  end

  # Create an object type
  #
  # @param object_type [Hash] the object type
  # @option object_type[:name] [String] the name
  # @option object_type[:description] [String] the description
  # @option object_type[:prefix] [String] the prefix
  # @option object_type[:min] [Int] the min value
  # @option object_type[:max] [Int] the max value
  # @option object_type[:unit] [String] the unit
  # @option object_type[:cost] [Float] the cost
  # @option object_type[:handler] [String] the handler
  # @option object_type[:release_method] [String] the release method
  # @option object_type[:rows] [Int] the number of rows (for handler == "collection")
  # @option object_type[:columns] [Int] the number of rows (for handler == "collection")
  # @option object_type[:sample_type_id] [String] the id of the sample type (for handler == "sample_container")
  # @option object_type[:release_description] [String] the release description
  # @option object_type[:safety] [String] the safety information
  # @option object_type[:cleanup] [String] the cleanup information
  # @option object_type[:data] [String] the data
  # @option object_type[:vendor] [String] the vendor information
  # @option object_type[:image] [String] the image (TODO)
  # return the object type
  def self.create_this(object_type)
    name = Input.text(object_type[:name])
    description = Input.text(object_type[:description])
    prefix = Input.text(object_type[:prefix])
    min = Input.int(object_type[:min])
    max = Input.int(object_type[:max])
    unit = Input.text(object_type[:unit])
    cost = Input.float(object_type[:cost])
    handler = Input.text(object_type[:handler])
    if handler == "collection"
      rows = Input.int(object_type[:rows])
      columns = Input.int(object_type[:columns])

      # Set default values if either row or column is negative or zero
      rows = 1 if rows < 1
      columns = 12 if columns < 1
    end
    if handler == "sample_container"
      sample_type_id = Input.text(object_type[:sample_type_id])

      # check the sample_type_id
      sample_type_id = nil if !SampleType.find_by(id: sample_type_id)
    end
    release_method = Input.text(object_type[:release_method])
    release_method = "return" if !["return", "dispose", "query"].index(release_method)
    release_description = Input.text(object_type[:release_description])
    safety = Input.text(object_type[:safety])
    cleanup = Input.text(object_type[:cleanup])
    data = Input.text(object_type[:data])
    vendor = Input.text(object_type[:vendor])
    # TODO: image = Input.text(object_type[:image])

    object_type_new = ObjectType.new(
      name: name,
      description: description,
      prefix: prefix,
      min: min,
      max: max,
      unit: unit,
      cost: cost,
      handler: handler,
      release_method: release_method,
      rows: rows,
      columns: columns,
      sample_type_id: sample_type_id,
      release_description: release_description,
      safety: safety,
      cleanup: cleanup,
      data: data,
      vendor: vendor
    )

    valid = object_type_new.valid?
    return false, object_type_new.errors if !valid

    # Save the object type if it is valid
    object_type_new.save

    return object_type_new, false
  end

  # Update an object type
  # - Any potential errors are handled automatically and silently
  #
  # @param object_type [Hash] the object type
  # @option object_type[:name] [String] the name
  # @option object_type[:description] [String] the description
  # @option object_type[:prefix] [String] the prefix
  # @option object_type[:min] [Int] the min value
  # @option object_type[:max] [Int] the max value
  # @option object_type[:unit] [String] the unit
  # @option object_type[:cost] [Float] the cost
  # @option object_type[:handler] [String] the handler
  # @option object_type[:release_method] [String] the release method
  # @option object_type[:rows] [Int] the number of rows (for handler == "collection")
  # @option object_type[:columns] [Int] the number of rows (for handler == "collection")
  # @option object_type[:sample_type_id] [String] the id of the sample type (for handler == "sample_container")
  # @option object_type[:release_description] [String] the release description
  # @option object_type[:safety] [String] the safety information
  # @option object_type[:cleanup] [String] the cleanup information
  # @option object_type[:data] [String] the data
  # @option object_type[:vendor] [String] the vendor information
  # @option object_type[:image] [String] the image (TODO)
  # return the object type
  def update(object_type)
    # Read and auto-correct parameters
    input_name = Input.text(object_type[:name]) || self.name
    input_description = Input.text(object_type[:description]) || self.description
    input_prefix = Input.text(object_type[:prefix])
    input_min = Input.int(object_type[:min])
    input_max = Input.int(object_type[:max])
    if input_min < 0 or input_max < 0 or input_min > input_max
      input_min = self.min
      input_max = self.max
    end
    input_unit = Input.text(object_type[:unit])
    input_cost = Input.float(object_type[:cost])
    input_cost = self.cost if input_cost < 0.01
    input_handler = Input.text(object_type[:handler]) || self.handler
    if input_handler == "collection"
      input_rows = Input.int(object_type[:rows])
      input_columns = Input.int(object_type[:columns])

      # Set default values if either row or column is negative or zero
      input_rows = 1 if input_rows < 1
      input_columns = 12 if input_columns < 1
    else
      input_rows = nil
      input_columns = nil
    end
    if handler == "sample_container"
      input_sample_type_id = Input.text(object_type[:sample_type_id])

      # check the sample_type_id
      input_sample_type_id = nil if !SampleType.find_by(id: sample_type_id)
    else
      input_sample_type_id = nil
    end
    input_release_method = Input.text(object_type[:release_method])
    input_release_method = self.release_method if !["return", "dispose", "query"].index(release_method)
    input_release_description = Input.text(object_type[:release_description])
    input_safety = Input.text(object_type[:safety])
    input_cleanup = Input.text(object_type[:cleanup])
    input_data = Input.text(object_type[:data])
    input_vendor = Input.text(object_type[:vendor])
    # TODO: image = Input.text(object_type[:image])

    self.name = input_name
    self.description = input_description
    self.prefix = input_prefix
    self.min = input_min
    self.max = input_max
    self.unit = input_unit
    self.cost = input_cost
    self.handler = input_handler
    self.release_method = input_release_method
    self.rows = input_rows
    self.columns = input_columns
    self.sample_type_id = input_sample_type_id
    self.release_description = input_release_description
    self.safety = input_safety
    self.cleanup = input_cleanup
    self.data = input_data
    self.vendor = input_vendor

    # Save the object type if it is valid
    self.save if self.valid?

    return self
  end

  private

  def custom_validator
    errors.add(:min, "min must be greater than or equal to zero") if min < 0
    errors.add(:min, "min must be less than or equal to max") if min > max
    errors.add(:max, "max must be greater than or equal to zero") if max < 0
    errors.add(:cost, "cost must be at least 0.01") if cost < 0.01
  end
end
