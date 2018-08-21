
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
  validates_uniqueness_of :name

  def rows
    if handler == 'collection'
      read_attribute(:rows) ? read_attribute(:rows) : 1
    end
  end

  def columns
    if handler == 'collection'
      read_attribute(:columns) ? read_attribute(:columns) : 12
    end
  end

  def rows=(value)
    write_attribute :rows, value
  end

  def columns=(value)
    write_attribute :columns, value
  end

  def min_and_max
    errors.add(:min, 'min must be greater than zero and less than or equal to max') unless
      min && max && min >= 0 && min <= max
  end

  def pos
    errors.add(:cost, 'must be at least $0.01') unless
      cost && cost >= 0.01
  end

  def proper_release_method
    errors.add(:release_method, 'must be either return, dispose, or query') unless
      release_method && (release_method == 'return' ||
                               release_method == 'dispose' ||
                               release_method == 'query')
  end

  has_many :items, dependent: :destroy
  belongs_to :sample_type

  def quantity
    q = 0
    items.each do |i|
      q += i.quantity if i.quantity >= 0
    end
    q
  end

  def in_use
    q = 0
    items.each do |i|
      q += i.inuse
    end
    q
  end

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

  def export
    attributes
  end

  def default_dimensions # for collections

    if handler == 'collection'
      begin
        h = JSON.parse(data, symbolize_names: true)
      rescue Exception => e
        raise "Could not parse data field '#{data}' of object type #{id}. Please go to " \
              "<a href='/object_types/#{id}/edit'>Object Type #{id}</a> and edit the data " \
              'field so that it reads something like { "rows": 10, "columns": 10 }'
      end
      if h[:rows] && h[:columns]
        [h[:rows], h[:columns]]
      else
        [1, 1]
      end
    else
      raise 'Tried to get dimensions of a container that is not a collection'
    end

  end

  def to_s
    "<a href='/object_types/#{id}' class='aquarium-item' id='#{id}'>#{id}</a>"
  end

  def data_object
    begin
      result = JSON.parse(data, symbolize_names: true)
    rescue Exception => e
      result = {}
    end
    result
  end

  def sample_type_name
    sample_type ? sample_type.name : nil
  end

  def self.compare_and_upgrade(raw_ots)

    parts = %i[cleanup data description handler max min name safety
               vendor unit cost release_method release_description prefix]
    icons = []
    notes = []
    make = []

    raw_ots.each do |raw_ot|

      ot = ObjectType.find_by_name raw_ot[:name]
      i = []

      if ot
        parts.each do |part|
          icons << "Container '#{raw_ot[:name]}': field #{part} differs from imported container's corresponding field." unless ot[part] == raw_ot[part]
        end
        notes << "Container '#{raw_ot[:name]}' matches existing container type." unless icons.any?
      else
        make << raw_ot
      end

    end

    if icons.none?
      make.each do |raw_ot|
        ot = ObjectType.new
        parts.each do |part|
          ot[part] = raw_ot[part]
        end
        ot.save
        if ot.errors.any?
          icons << "Could not create '#{raw_ot[:name]}': #{ot.errors.full_messages.join(', ')}"
        else
          notes << "Created new container '#{raw_ot[:name]}' with id #{ot.id}"
        end
      end
    else
      notes << 'Could not create required container(s) due to type definition inconsistencies.'
    end

    { notes: notes, inconsistencies: icons }

  end

  def self.clean_up_sample_type_links(raw_object_types)
    raw_object_types.each do |rot|
      ot = ObjectType.find_by_name rot[:name]
      st = SampleType.find_by_name rot[:sample_type_name]
      if st && ot
        ot.sample_type_id = st.id
        ot.save
      end
    end
  end

end
