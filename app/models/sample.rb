class Sample < ActiveRecord::Base
  attr_accessible :field1, :field2, :field3, :field4, :name, :owner, :project, :sample_type_id, :user_id
  belongs_to :sample_type
  belongs_to :user
end
