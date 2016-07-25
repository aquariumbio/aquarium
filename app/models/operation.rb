class Operation < ActiveRecord::Base

  include FieldValuer
  include OperationPlanner

  def parent_type # interface with FieldValuer
    operation_type
  end  

  belongs_to :operation_type
  attr_accessible :status

  def set_input name, val
    set_property name, val, "input"
  end

  def set_output name, val
    set_property name, val, "output"
  end

  def inputs
    field_values.select { |ft| ft.role == 'input' }
  end

  def outputs
    field_values.select { |ft| ft.role == 'output' }
  end

  def get_input name
    inputs.find { |i| i.name == name }
  end

  def get_output name
    outputs.find { |o| o.name == name }
  end

  def to_s
    ins = (inputs.collect { |fv| "#{fv.name}: #{fv.child_sample.name}" }).join(", ")
    outs = (outputs.collect { |fv| "#{fv.name}: #{fv.child_sample.name}" }).join(", ")    
    "#{operation_type.name} #{id} ( " + ins + " ) ==> ( " + outs + " )"
  end

end

