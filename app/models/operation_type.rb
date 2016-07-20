class OperationType < ActiveRecord::Base

  include FieldTyper

  has_many :operations
  attr_accessible :name

  def add_input name, sample_name, container_name, opts={}
    add_field name, sample_name, container_name, "input", opts
  end

  def add_output name, sample_name, container_name, opts={}
    add_field name, sample_name, container_name, "output", opts   
  end

  def inputs
    field_types.select { |ft| ft.role == 'input' }
  end

  def outputs
    field_types.select { |ft| ft.role == 'output' }
  end

end