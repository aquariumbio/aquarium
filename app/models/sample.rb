class Sample < ActiveRecord::Base
  attr_accessible :field1, :field2, :field3, :field4, :name, :owner, :project, :sample_type_id
  belongs_to :sample_type
end
