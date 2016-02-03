class Budget < ActiveRecord::Base

  has_many :tasks

  attr_accessible :contact, :name, :overhead, :description

  validates :name,  presence: true
  validates :contact,  presence: true  
  validates :description,  presence: true  

  # validates_numericality_of :overhead, :greater_than_or_equal_to => 0.0, :less_than => 1.0 

end
