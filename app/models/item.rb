class Item < ActiveRecord::Base

  belongs_to :object_type
  belongs_to :sample
  has_many :touches
  has_one :part
  has_many :cart_items
  has_many :takes

  attr_accessible :location, :quantity, :inuse, :sample_id, :data, :object_type_id,
                  :created_at, :collection_id,
                  :sample_attributes, :object_type_attributes

  accepts_nested_attributes_for :sample, :object_type

  validates :location, :presence => true

  validates :quantity, :presence => true
  validate :quantity_nonneg

  validates :inuse,    :presence => true
  validate :inuse_less_than_quantity

  def self.new_object name

    i = self.new
    olist = ObjectType.where("name = ?", name)
    raise "Could not find object type named '#{spec[:object_type]}'." unless olist.length > 0
    i.object_type_id = olist[0].id
    i.location = olist[0].location_wizard
    i.quantity = 1
    i.inuse = 0
    i.save
    i

  end

  def self.new_sample name, spec

    raise "No Sample Type Specified (with :of)" unless spec[:of]
    raise "No Container Specified (with :in)" unless spec[:as]

    i = self.new

    olist = ObjectType.where("name = ?", spec[:as])
    raise "Could not find container named '#{spec[:as]}'." unless olist.length > 0

    sample_type_id = SampleType.find_by_name(spec[:of])
    raise "Could not find sample type named '#{spec[:of]}'." unless sample_type_id

    slist = Sample.where("name = ? AND sample_type_id = ?", name, sample_type_id)
    raise "Could not find sample named #{name}" unless slist.length > 0

    i.object_type_id = olist[0].id
    i.sample_id = slist[0].id

    i.location = olist[0].location_wizard project: i.sample.project
    i.quantity = 1
    i.inuse = 0
    i.save

    i

  end

  def move loc
    self.location = loc
    self.save
  end

  def set_data d
    self.data = d.to_json
    self.save
  end

  def get_data
    JSON.parse self.data, symbolize_names: true
  end

  def datum
    begin
      JSON.parse self.data, symbolize_names: true
    rescue
      {}
    end
  end

  def datum= d
    self.data = d.to_json
  end

  def quantity_nonneg
    errors.add(:quantity, "Must be non-negative." ) unless
      self.quantity && self.quantity >= -1 
  end

  def inuse_less_than_quantity
    errors.add(:inuse, "must non-negative and not greater than the quantity." ) unless
      self.quantity && self.inuse && self.inuse >= -1 && self.inuse <= self.quantity
  end

  def features
    f = { id: self.id, location: self.location, name: self.object_type.name }
    if self.sample_id
      f = f.merge({ sample: self.sample.name, type: self.sample.sample_type.name })
    end
    f
  end

  def mark_as_deleted
    self.location = 'deleted'
    self.quantity = -1
    self.inuse = -1
    self.save
  end

  def all_attributes

    temp = self.attributes.symbolize_keys

    temp[:object_type] = self.object_type.attributes.symbolize_keys

    if self.sample_id
      temp[:sample] = self. sample.attributes.symbolize_keys
    end

    return temp

  end

  def to_s
    "<a href='/items/#{self.id}' class='aquarium-item' id='#{self.id}'>#{self.id}</a>"
  end

end

