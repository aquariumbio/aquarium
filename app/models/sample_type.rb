class SampleType < ActiveRecord::Base

  include FieldTyper

  after_destroy :destroy_fields

  attr_accessible :description, :name, :datatype

  has_many :samples
  has_many :object_types

  validates :name, presence: true
  validates :description, presence: true

  validate :proper_choices # deprecated

  def export
    attributes
  end

end
