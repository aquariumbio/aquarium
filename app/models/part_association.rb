# typed: false
# frozen_string_literal: true

class PartAssociation < ApplicationRecord

  attr_accessible :part_id, :collection_id, :row, :column

  belongs_to :part, class_name: 'Item'
  belongs_to :collection, class_name: 'Item'

  validate

end
