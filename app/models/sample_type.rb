class SampleType < ActiveRecord::Base

  attr_accessible :description, :field1name, :field1type, :field2name, :field2type, :field3name, 
                                :field3type, :field4name, :field4type, :field5name, :field5type, 
                                :field6name, :field6type, 
                                :name

  has_many :samples
  has_many :object_types

  validates :name, presence: true
  validates :description, presence: true

end
