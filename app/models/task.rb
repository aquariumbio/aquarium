class Task < ActiveRecord::Base
  attr_accessible :name, :specification, :status, :task_prototype_id
  belongs_to :task_prototype
end
