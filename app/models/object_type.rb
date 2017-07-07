class ObjectType < ActiveRecord::Base

  attr_accessible :cleanup, :data, :description, :handler, :max, :min, :name, :safety, 
                  :vendor, :unit, :image, :cost, :release_method, :release_description,
                  :sample_type_id, :created_at, :prefix

  belongs_to :sample_type

  validates :name, :presence => true
  validates :unit, :presence => true
  validates :min, :presence => true
  validates :max, :presence => true
  validates :release_method, :presence => true
  validates :description, :presence => true
  validate :min_and_max
  validates :cost, :presence => true
  validate :pos
  validate :proper_release_method
  validates_uniqueness_of :name

  def rows
    if handler == 'collection'
      read_attribute(:rows) ? read_attribute(:rows) : 1
    else
      nil
    end
  end

  def columns
    if handler == 'collection'
      read_attribute(:columns) ? read_attribute(:columns) : 12
    else
      nil
    end
  end

  def rows=(value)
    write_attribute :rows, value
  end

  def columns=(value)
    write_attribute :columns, value
  end

  def min_and_max
    errors.add(:min, "min must be greater than zero and less than or equal to max") unless
      self.min && self.max && self.min >= 0 && self.min <= self.max
  end

  def pos
    errors.add(:cost, "must be at least $0.01" ) unless
      self.cost && self.cost >= 0.01
  end

  def proper_release_method
    errors.add(:release_method, "must be either return, dispose, or query") unless
      self.release_method && ( self.release_method == 'return'  || 
                               self.release_method == 'dispose' || 
                               self.release_method == 'query' )
  end

  has_many :items, dependent: :destroy
  belongs_to :sample_type

  def quantity
    q = 0
    self.items.each { |i|
      if i.quantity >= 0 
        q += i.quantity
      end
    }
    return q
  end

  def in_use
    q = 0
    self.items.each { |i|
      q += i.inuse
    }
    return q
  end

  def save_as_test_type name

    self.name = name
    self.handler = "temporary"
    self.unit = 'object'
    self.min = 0
    self.max = 100
    self.safety = "No safety information"
    self.cleanup = "No cleanup information"
    self.data = "No data"
    self.vendor = "No vendor information"
    self.cost = 0.01
    self.release_method = "return"
    self.description = "An object type made on the fly."
    self.save
    i = self.items.new
    i.quantity = 1000
    i.inuse = 0
    i.location = 'A0.000'
    i.save

  end

  def export
    attributes
  end 

  def default_dimensions # for collections

    if self.handler == "collection"
      begin
        h = JSON.parse(self.data,symbolize_names: true)
      rescue Exception => e
        raise "Could not parse data field '#{self.data}' of object type #{self.id}. Please go to " + 
              "<a href='/object_types/#{self.id}/edit'>Object Type #{self.id}</a> and edit the data " +
              "field so that it reads something like { \"rows\": 10, \"columns\": 10 }"
      end
      if h[:rows] && h[:columns]
        [h[:rows],h[:columns]]
      else
        [1,1]
      end
    else
      raise "Tried to get dimensions of a container that is not a collection"
    end

  end  

  def to_s
    "<a href='/object_types/#{self.id}' class='aquarium-item' id='#{self.id}'>#{self.id}</a>"
  end

  def data_object
    begin
      result = JSON.parse(data,symbolize_names: true)
    rescue Exception => e
      result = {}
    end
    return result
  end

  def sample_type_name
    sample_type ? sample_type.name : nil
  end

  def self.compare_and_upgrade raw_ots

    parts = [ :cleanup, :data, :description, :handler, :max, :min, :name, :safety, 
              :vendor, :unit, :cost, :release_method, :release_description, :prefix ]
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

    if !icons.any?
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
      notes << "Could not create required container(s) due to type definition inconsistencies."
    end

    { notes: notes, inconsistencies: icons }

  end

end
