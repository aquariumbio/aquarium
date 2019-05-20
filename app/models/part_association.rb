# frozen_string_literal: true

class PartAssociation < ActiveRecord::Base

  attr_accessible :part_id, :collection_id, :row, :column

  belongs_to :part, foreign_key: :part_id, class_name: "Item"
  belongs_to :collection, foreign_key: :collection_id, class_name: "Item"

  validate

end
