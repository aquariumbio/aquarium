class ObjectType < ActiveRecord::Base
  attr_accessible :cleanup, :data, :description, :handler, :max, :min, :name, :safety, :vendor

  validates :name, :presence => true
  validates :min, :presence => true
  validates :max, :presence => true
  validates :description, :presence => true
  validate :min_and_max

  def min_and_max
    errors.add(:min, "min must be greater than zero and less than or equal to max") unless
      self.min && self.max && self.min > 0 && self.min <= self.max
  end

  has_many :items, dependent: :destroy

end
