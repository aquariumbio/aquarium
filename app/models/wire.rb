# typed: false
# frozen_string_literal: true

class Wire < ApplicationRecord

  attr_accessible :from_id, :to_id, :active

  belongs_to :from, class_name: 'FieldValue'
  belongs_to :to,   class_name: 'FieldValue'

  def to_op
    Operation.find(to.parent_id)
  end

  def from_op
    Operation.find(from.parent_id)
  end

end
