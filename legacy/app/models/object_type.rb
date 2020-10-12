# typed: false
# frozen_string_literal: true

# Defines the type of physical object that would be represented in an {Item}
# @api krill
class ObjectType < ActiveRecord::Base

  attr_accessible :cleanup, :data, :description, :max, :min, :safety,
                  :vendor, :unit, :image, :cost, :release_method, :release_description,
                  :sample_type_id, :created_at, :prefix, :rows, :columns

  # Gets name of ObjectType.
  #
  # @return [String]  the name of the ObjectType, as in "1 L Bottle"
  attr_accessible :name

  # Gets handler of ObjectType.
  #
  # @return [String] the name of the category that classifies the object type,
  #               as in "liquid_media". The special handler "collection" is used to
  #               show that items with this given object type are collections
  attr_accessible :handler

  # Gets SampleType for this ObjectType.
  #
  # @return [SampleType] type of Sample that is allowed to exist in an item with this
  #             ObjectType as its container
  belongs_to :sample_type

  validates :name, presence: true
  validates :unit, presence: true
  validates :min, presence: true
  validates :max, presence: true
  validates :release_method, presence: true
  validates :description, presence: true
  validate :min_and_max
  validates :cost, presence: true
  validate :pos
  validate :proper_release_method
  validates :name, uniqueness: true

  def collection_type?
    handler == 'collection'
  end

  def sample?
    handler == 'sample_container'
  end

  def rows
    return unless collection_type?

    self[:rows] || 1
  end

  def columns
    return unless collection_type?

    self[:columns] || 12
  end

  def rows=(value)
    self[:rows] = value
  end

  def columns=(value)
    self[:columns] = value
  end

  def min_and_max
    errors.add(:min, 'min must be greater than zero and less than or equal to max') unless
      min && max && T.must(min) >= 0 && T.must(min) <= T.must(max)
  end

  def pos
    errors.add(:cost, 'must be at least $0.01') unless
      cost && T.must(cost) >= 0.01
  end

  def proper_release_method
    errors.add(:release_method, 'must be either return, dispose, or query') unless
      release_method && (release_method == 'return' ||
                               release_method == 'dispose' ||
                               release_method == 'query')
  end

  has_many :items, dependent: :destroy
  belongs_to :sample_type

  # used in views/search/search.html.erb
  def quantity
    q = 0
    items.each do |i|
      q += T.must(i.quantity) if T.must(i.quantity) >= 0
    end
    q
  end

  # TODO: dead code
  def in_use
    q = 0
    items.each do |i|
      q += T.must(i.inuse)
    end
    q
  end

  # TODO: dead code
  def save_as_test_type(name)

    self.name = name
    self.handler = 'temporary'
    self.unit = 'object'
    self.min = 0
    self.max = 100
    self.safety = 'No safety information'
    self.cleanup = 'No cleanup information'
    self.data = 'No data'
    self.vendor = 'No vendor information'
    self.cost = 0.01
    self.release_method = 'return'
    self.description = 'An object type made on the fly.'
    save
    i = items.new
    i.quantity = 1000
    i.inuse = 0
    i.location = 'A0.000'
    i.save

  end

  # used by item.export
  def export
    attributes
  end

  # TODO: dead code?
  def default_dimensions # for collections
    raise 'Tried to get dimensions of a container that is not a collection' unless collection_type?

    begin
      h = JSON.parse(T.must(data), symbolize_names: true)
    rescue JSON::ParserError
      raise "Could not parse data field '#{data}' of object type #{id}. Please go to " \
            "<a href='/object_types/#{id}/edit'>Object Type #{id}</a> and edit the data " \
            'field so that it reads something like { "rows": 10, "columns": 10 }'
    end
    if h[:rows] && h[:columns]
      [h[:rows], h[:columns]]
    else
      [1, 1]
    end
  end

  # TODO: this shouldn't have view details, probably dead code
  def to_s
    "<a href='/object_types/#{id}' class='aquarium-item' id='#{id}'>#{id}</a>"
  end

  # used in object_type views
  def data_object
    begin
      result = JSON.parse(T.must(data), symbolize_names: true)
    rescue StandardError
      result = {}
    end
    result
  end

  # TODO: dead code
  def sample_type_name
    sample_type&.name
  end

  # used by compare_and_upgrade
  def self.create_from(raw_type)
    attributes = %i[cleanup data description handler max min name safety
                    vendor unit cost release_method release_description prefix]
    ot = ObjectType.new
    attributes.each do |attribute|
      ot[attribute] = raw_type[attribute]
    end

    if ot.collection_type?
      ot[:rows] = raw_type[:rows]
      ot[:columns] = raw_type[:columns]
    end

    ot
  end

  # used in app/planner/operation_type_export
  def self.compare_and_upgrade(raw_types)
    parts = %i[cleanup data description handler max min name safety
               vendor unit cost release_method release_description prefix]
    inconsistencies = []
    notes = []

    raw_types.each do |raw_type|
      type = ObjectType.find_by(name: raw_type[:name])

      if type
        parts.each do |part|
          inconsistencies << "Container '#{raw_type[:name]}': field #{part} differs from imported object type's corresponding field." unless type[part] == raw_type[part]
        end
        notes << "Container '#{raw_type[:name]}' matches existing object type." unless inconsistencies.any?
        next
      end

      next if inconsistencies.any?

      type = ObjectType.create_from(raw_type)
      type.save
      if type.errors.any?
        inconsistencies << "Could not create '#{raw_type[:name]}': #{type.errors.full_messages.join(', ')}"
      else
        notes << "Created new object type '#{raw_type[:name]}' with id #{type.id}"
      end
    end

    notes << 'Could not create required object type(s) due to type definition inconsistencies.' if inconsistencies.any?

    { notes: notes, inconsistencies: inconsistencies }
  end

  # used in app/planner/operation_type_export
  def self.clean_up_sample_type_links(raw_object_types)
    raw_object_types.each do |rot|
      ot = ObjectType.find_by(name: rot[:name])
      st = SampleType.find_by(name: rot[:sample_type_name])
      if st && ot
        ot.sample_type_id = st.id
        ot.save
      end
    end
  end

  # scopes for searching ObjectTypes
  def self.container_types(sample_type:)
    where(sample_type_id: sample_type.id).where.not(name: '__Part')
  end

  def self.part_type
    find_by(name: '__Part')
  end

end
