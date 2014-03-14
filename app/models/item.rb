class Item < ActiveRecord::Base

  belongs_to :object_type
  belongs_to :sample
  has_many :touches
  has_one :part
  has_many :cart_items

  attr_accessible :location, :quantity, :inuse, :sample_id, :data, :object_type_id, :created_at, :collection_id

  validates :location, :presence => true

  validates :quantity, :presence => true
  validate :quantity_nonneg

  validates :inuse,    :presence => true
  validate :inuse_less_than_quantity

  def quantity_nonneg
    errors.add(:quantity, "Must be non-negative." ) unless
      self.quantity && self.quantity >= -1 
  end

  def inuse_less_than_quantity
    errors.add(:inuse, "must non-negative and not greater than the quantity." ) unless
      self.quantity && self.inuse && self.inuse >= -1 && self.inuse <= self.quantity
  end

end
