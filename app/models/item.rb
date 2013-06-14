class Item < ActiveRecord::Base
  belongs_to :object_type
  attr_accessible :location, :quantity
end
