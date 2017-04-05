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

  def virtual?
    false
  end

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

  def input_array name
    inputs.select { |i| i.name == name }.extend(IOList)
  end

  def output_array name
    outputs.select { |o| o.name == name } .extend(IOList)   
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

  def self.step ops=nil

    if !ops
      ops = Operation.where(status: "waiting")
    end

    ops.each do |op|
      begin
        if op.ready?
          op.status = "pending"
          op.save
        end
      rescue Exception => e
        Rails.logger.info "COULD NOT STEP OPERATION #{op.id}"
      end
    end

  end

  def nominal_cost

    begin
      eval(operation_type.code("cost_model").content)
    rescue Exception => e
      raise "Could not evaluate cost function definition: " + e.to_s
    end

    temp = self.status
    self.status = "done"

    begin
      c = cost(self)
    rescue Exception => e
      self.status = temp
      raise "Could not evaluate cost function on the given operation: " + e.to_s
    end

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

  def precondition_value

    rval = true

    begin
      eval(operation_type.code("precondition").content)
      rval = precondition(self)
    rescue Exception => e
      Rails.logger.info "PRECONDITION FOR OPERATION #{id} crashed"
      plan.associate "Precondition Evalution Error", e.message.to_s + ": " + e.backtrace[0].to_s.sub("(eval)","line")
      rval = false # default if there is no precondition or it crashes
    end

    rval

  end

  def add_successor opts

    ot = OperationType.find_by_name(opts[:type])

    op = ot.operations.create(
        status: "waiting",
        user_id: user_id
    )

    plan.plan_associations.create operation_id: op.id

    opts[:routing].each do |r|
      ot.field_types.select { |ft| ft.routing == r[:symbol] }.each do |ft|
        aft = ft.allowable_field_types[0]
        op.set_property ft.name, r[:sample], ft.role, false, aft
      end
    end

    raise "Could not find output #{opts[:from]} of #{operation_type.name}" unless output(opts[:from])
    raise "Could not find input #{opts[:to]} of #{opts[:type]} (inputs = #{op.field_values.inspect})" unless op.input(opts[:to])   
    
    wire = Wire.new(
      from_id: output(opts[:from]).id, 
      to_id: op.input(opts[:to]).id, 
      active: true
    )

    wire.save

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

