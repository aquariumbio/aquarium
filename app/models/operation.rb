class Operation < ActiveRecord::Base

  include FieldValuer

  def parent_type # interface with FieldValuer
    operation_type
  end  

  belongs_to :operation_type

  attr_accessible :status

  def to_s
    fvs = (field_values.collect { |fv| fv.inspect }).join(", ")
    "#{operation_type.name} #{id} (" + fvs + ")"
  end

end