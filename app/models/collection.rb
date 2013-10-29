class Collection < ActiveRecord::Base

  attr_accessible :columns, :name, :object_type_id, :project, :rows

  belongs_to :object_type
  has_many :parts

end
