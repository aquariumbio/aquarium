class Library < ActiveRecord::Base

  include CodeHelper

  attr_accessible :name, :category

  validates :name, presence: true
  validates :category, presence: true

end