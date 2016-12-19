class SampleType < ActiveRecord::Base

  include FieldTyper

  after_destroy :destroy_fields

  attr_accessible :description, :name

  has_many :samples
  has_many :object_types

  validates :name, presence: true
  validates :description, presence: true

  def export
    attributes
  end

end
