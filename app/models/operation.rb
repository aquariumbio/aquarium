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

  def on_the_fly
    operation_type.on_the_fly
  end

  def set_status str
    self.status = str
    self.save
    raise "Could not set status" unless self.errors.empty?
  end

  def error error_type, msg
    set_status "error"
    associate error_type, msg
  end

  def plan
    pset = plans
    if pset.length > 0
      pset[0]
    else
      nil
    end
  end

  def set_input name, val, aft=nil
    set_property name, val, "input", false, aft
  end

  def set_output name, val, aft=nil
    set_property name, val, "output", false, aft
  end

  def inputs
    field_values.select { |ft| ft.role == 'input' }
  end

  def outputs
    field_values.select { |ft| ft.role == 'output' }
  end

  def get_input name
    puts "================= FINDING #{name}"
    inputs.find { |i| i.name == name }
  end

  def get_output name
    outputs.find { |o| o.name == name }
  end

  def input name
    get_input name
  end

  def output name
    get_output name
  end

  def get_field_value name, role="input"
    field_values.find { |fv| fv.name == name && fv.role == role }
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
    ins = (inputs.collect { |fv| "#{fv.name}: #{fv.child_sample ? fv.child_sample.name : 'NO SAMPLE'}" }).join(", ")
    outs = (outputs.collect { |fv| "#{fv.name}: #{fv.child_sample ? fv.child_sample.name : 'NO SAMPLE'}" }).join(", ")    
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

  def predecessors

    ops = []

    inputs.each do |input|
      input.predecessors.each do |pred|
        ops << pred.operation
      end
    end

    ops

  end

  def siblings

    ops = outputs.collect do |output|
      output.wires_as_source.collect do |wire|
        wire.to.predecessors.collect { |pred| pred.operation }
      end
    end

    ops.flatten

  end

  def activate
    puts "Activating operation #{id}"
    set_status "planning"
    outputs.each do |output|
      output.wires_as_source.each do |wire|
        wire.active = true
        wire.save
      end
    end
  end

  def deactivate
    puts "Deactivating operation #{id}"    
    set_status "unplanned"
    outputs.each do |output|
      output.wires_as_source.each do |wire|
        wire.active = false
        wire.save
      end
    end
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

  def child_data child_name, child_role, data_name
    fv = get_input(child_name) if child_role == 'input'
    fv = get_output(child_name) if child_role == 'output'
    fv ? fv.child_data(data_name) : nil
  end

  def input_data input_name, data_name
    child_data input_name, 'input', data_name
  end

  def output_data input_name, data_name
    child_data input_name, 'output', data_name
  end

  def set_child_data child_name, child_role, data_name, value
    fv = get_input(child_name) if child_role == 'input'
    fv = get_output(child_name) if child_role == 'output'
    fv ? fv.set_child_data(data_name,value) : nil
  end

  def set_input_data input_name, data_name, value
    set_child_data input_name, 'input', data_name, value
  end

  def set_output_data input_name, data_name, value
    set_child_data input_name, 'output', data_name, value
  end  

  ###################################################################################################
  # STARTING PLANS

  def start_on_the_fly

    puts "======== CONSIDERING #{id} (#{status})"

    if on_the_fly && leaf?

      puts "=============== Setting op #{id} to 'primed'"
      set_status "primed"
      return true

    else

      start = on_the_fly

      inputs.each do |input|
        input.predecessors.each do |pred|          
          if pred.operation.status == "planning"
            start = pred.operation.start_on_the_fly && start
          end
        end
      end

      if start
        puts "=============== Setting op #{id} to 'primed'"
        set_status "primed"
        return true
      else 
        puts "=============== No start on the fly for op #{id}"
        return false
      end

    end

  end

  def start
    recurse do |op|
      if op.status == "planning" && !op.on_the_fly
        op.set_status(op.leaf? ? "pending" : "waiting")
        puts "=================== set op #{op.id} to #{op.status}"
      else
        puts "=================== skipped #{op.id} because its 'on the fly'"
      end
    end
  end

  def leaf?

    inputs.each do |i|

      if i.predecessors.count > 0
        i.predecessors.each do |pred|
          if pred.operation.status != "primed"
            return false
          end
        end
      end

    end

    return true

  end  

  def temporary
    @temporary ||= {}
    @temporary
  end

end

