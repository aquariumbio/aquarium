class Wire < ActiveRecord::Base

  attr_accessible :from_id, :to_id

  belongs_to :from, class_name: "FieldValue", foreign_key: :from_id
  belongs_to :to,   class_name: "FieldValue", foreign_key: :to_id  

end