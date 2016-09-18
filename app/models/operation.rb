class Operation < ActiveRecord::Base

  include DataAssociator
  include FieldValuer
  include OperationPlanner
  
  def parent_type # interface with FieldValuer
    operation_type
  end  

  belongs_to :operation_type
  belongs_to :user
  belongs_to :job

  has_many :plan_associations
  has_many :plans, through: :plan_associations

  attr_accessible :status, :user_id, :job_id

  def name
    operation_type.name
  end

  def set_status str
    self.status = str
    self.save
    raise "Could not set status" unless self.errors.empty?
  end

  def plan
    pset = plans
    if pset.length > 0
      pset[0]
    else
      nil
    end
  end

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

  def get_field_value name
    field_values.find { |fv| fv.name == name }
  end

  def recurse &block
    block.call(self)
    inputs.each do |input|
      input.predecessors.each do |pred|
        pred.operation.recurse &block
      end
    end
  end    

  def find name
    ops = []
    recurse do |op|
      if op.operation_type.name == name
        ops << op
      end
    end
    return ops
  end

  def set_status_recursively str
    recurse do |op|
      puts "Setting operation #{op.id} status to #{str}"
      op.status = str
      op.save
    end
  end

  def to_s
    ins = (inputs.collect { |fv| "#{fv.name}: #{fv.child_sample.name}" }).join(", ")
    outs = (outputs.collect { |fv| "#{fv.name}: #{fv.child_sample.name}" }).join(", ")    
    "#{operation_type.name} #{id} ( " + ins + " ) ==> ( " + outs + " )"
  end

  def successors

    ops = []

    outputs.each do |output|
      output.successors.each do |suc|    
        ops << suc.operation
      end
    end

    ops

  end

  def self.step 

    Operation.where(status: "waiting").each do |op|
      if op.ready?
        Rails.logger.info "  Changing operation #{op.id}'s status to pending!"
        op.status = "pending"
        op.save
      end
    end

  end 

  def nominal_cost
    eval(operation_type.code("cost_model").content)
    temp = self.status
    self.status = "done"
    c = cost(self)
    self.status = temp
    c
  end

end

