class Touch < ActiveRecord::Base
  belongs_to :item
  belongs_to :task
  belongs_to :job
  belongs_to :metacol
end
