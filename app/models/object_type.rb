class ObjectType < ActiveRecord::Base

  attr_accessible :cleanup, :data, :description, :handler, :max, :min, :name, :safety, :vendor, :unit, :image, :cost, :release_method, :release_description

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "150x150>" }, 
                    :default_url => "/images/:style/no-image.png"

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

  def min_and_max
    errors.add(:min, "min must be greater than zero and less than or equal to max") unless
      self.min && self.max && self.min >= 0 && self.min <= self.max
  end

  def pos
    errors.add(:cost, "must be at least $0.01" ) unless
      self.cost && self.cost >= 0.01
  end

  def proper_release_method
    errros.add(:release_method, "must be either return, dispose, or query") unless
      self.release_method && ( self.release_method == 'return'  || 
                               self.release_method == 'dispose' || 
                               self.release_method == 'query' )
  end

  has_many :items, dependent: :destroy

  def quantity
    q = 0
    self.items.each { |i|
      q += i.quantity
    }
    return q
  end

end
