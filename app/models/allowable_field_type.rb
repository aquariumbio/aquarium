
class AllowableFieldType < ActiveRecord::Base

  attr_accessible :sample_type_id, :object_type_id

  belongs_to :field_type   # the field type to which this record refers
  belongs_to :sample_type  # the sample type that is allowed (if any)
  belongs_to :object_type  # the container that is allowed (if any)

  def as_json(options={})
    super include: [ :sample_type, :object_type ]
  end

end 
