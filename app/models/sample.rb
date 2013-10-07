class Sample < ActiveRecord::Base

  attr_accessible :field1, :field2, :field3, :field4, :field5, :field6, :name, :user_id, :project, :sample_type_id, :user_id
  belongs_to :sample_type
  belongs_to :user

  validates_uniqueness_of :name, scope: :project, message: ": Samples within the same project must have unique names."

  validates :name, presence: true
  validates :project, presence: true
  validates :user_id, presence: true

end
