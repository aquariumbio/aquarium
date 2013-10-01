class SampleType < ActiveRecord::Base

  attr_accessible :description, :field1name, :field1type, :field2name, :field2type, :field3name, :field3type, :field4name, :field4type, :name

  has_many :samples

  validates :name, presence: true
  validates :description, presence: true

end
