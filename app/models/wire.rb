class Wire < ActiveRecord::Base

  attr_accessible :from_id, :to_id, :active

  belongs_to :from, class_name: "FieldValue", foreign_key: :from_id
  belongs_to :to,   class_name: "FieldValue", foreign_key: :to_id

  def to_op
    Operation.find(to.parent_id)
  end

  def from_op
    Operation.find(from.parent_id)
  end

end