class TaskPrototype < ActiveRecord::Base
  attr_accessible :description, :name, :prototype
  has_many :tasks
end
