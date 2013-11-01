class Part < ActiveRecord::Base
  attr_accessible :collection_id, :column, :item_id, :row
  belongs_to :item
  belongs_to :collection
end
