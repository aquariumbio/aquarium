class ObjectType < ActiveRecord::Base

  attr_accessible :cleanup, :data, :description, :handler, :max, :min, :name, :safety, 
                  :vendor, :unit, :image, :cost, :release_method, :release_description,
                  :sample_type_id, :created_at, :prefix

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
      h = JSON.parse(self.data,symbolize_names: true)
      if h[:rows] && h[:columns]
        [h[:rows],h[:columns]]
      else
        [1,1]
      end
    else
      raise "Tried to get dimensions of a container that is not a collection"
    end

  end  

end


 
