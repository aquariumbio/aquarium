class Touch < ActiveRecord::Base
  belongs_to :item
  belongs_to :job
  # attr_accessible :title, :body
end
