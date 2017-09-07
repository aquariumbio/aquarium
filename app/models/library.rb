class Library < ActiveRecord::Base

  include CodeHelper

  attr_accessible :name, :category, :layout

  validates :name, presence: true
  validates :category, presence: true

end