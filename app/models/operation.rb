 # Class that represents an operation in the lab
 # Some very important methods include {#input}, {#output}, {#error}, {#pass}

 class Operation < ActiveRecord::Base

  include DataAssociator
  include FieldValuer
  include OperationPlanner
  include OperationStatus
  
  def parent_type # interface with FieldValuer
    operation_type
  end

  belongs_to :operation_type
  belongs_to :user
  has_many :job_associations
  has_many :jobs, through: :job_associations

  has_many :plan_associations
  has_many :plans, through: :plan_associations

  attr_accessible :status, :user_id, :x, :y, :parent_id

  def virtual?
    false
  end

  # @return [String] OperationType name
  def name
    operation_type.name
  end

  # @return [Bool] Whether OperationType is on-the-fly
  def on_the_fly
    operation_type.on_the_fly
  end

  # @return [Plan] The plan that contains this Operation
  def plan
    pset = plans
    if pset.length > 0
      pset[0]
    else
      nil
    end
  end

  # Assigns a Sample to an input
  # @param name [String]
  # @param val [Sample]
  # @param aft [AllowableFieldType]
  def set_input name, val, aft=nil
    set_property name, val, "input", false, aft
  end

  # Assigns a Sample to an output
  # @param name [String]
  # @param val [Sample]
  # @param aft [AllowableFieldType]
  def set_output name, val, aft=nil
    set_property name, val, "output", false, aft
  end

  # Adds a new input to an operation, even if that operation doesn't specify the input
  # in its definition. Useful for example when an operation determines which enzymes it
  # will use once launched.
  # @param name [String]
  # @param sample [Sample]
  # @param container [ObjectType]
  # @example Add input for items to discard
  #   items.each do |i|
  #     items_in_inputs = op.inputs.map { |input| input.item }.uniq
  # 
  #     if not items_in_inputs.include? i
  #       n = "Discard Item #{i.id}"
  #       op.add_input n, i.sample, i.object_type
  #       op.input(n).set item: i
  #     end
  #   end
  def add_input name, sample, container 
    items = Item.where(sample_id: sample.id, object_type_id: container.id).reject { |i| i.deleted? }
    
    if items.any?
        
        item = items.first
   
      ft = FieldType.new(
          name: name,
          ftype: "sample",
          parent_class: "OperationType",
          parent_id: nil
      )
      ft.save
    
      fv = FieldValue.new(
          name: name,
          child_item_id: item.id,
          child_sample_id: sample.id,
          role: 'input',
          parent_class: "Operation",
          parent_id: self.id,
          field_type_id: ft.id)
      fv.save
      
      return item
      
    end
    
    return nil
      
  end  

  # @return [Array<FieldValue>]
  def inputs
    field_values.select { |ft| ft.role == 'input' }
  end

  # (see #inputs)
  def outputs
    field_values.select { |ft| ft.role == 'output' }
  end

  # @param name [String]
  # @return [FieldValue]
  def get_input name
    puts "================= FINDING #{name}"
    inputs.find { |i| i.name == name }
  end

  # (see #get_input)
  def get_output name
    outputs.find { |o| o.name == name }
  end

  # (see #get_input)
  def input name
    get_input name
  end

  # (see #get_input)
  def output name
    get_output name
  end

  # Inputs as Array extended with {#IOList}
  # @param name [String]
  # @return [Array<FieldValue>]
  def input_array name
    inputs.select { |i| i.name == name }.extend(IOList)
  end

  # Outputs as Array extended with {#IOList}
  # @param name [String]
  # @return [Array<FieldValue>]
  def output_array name
    outputs.select { |o| o.name == name } .extend(IOList)   
  end

  # @param name [String]
  # @param role [String]
  # @return [FieldValue]
  def get_field_value name, role="input"
    field_values.find { |fv| fv.name == name && fv.role == role }
  end

  # Passes an input item to an output (alternative to {Krill::OperationList#make})
  # @param input_name [String]
  # @param output_name [String]
  # @return [Operation]
  def pass input_name, output_name=nil

    output_name = input_name unless output_name

    fv_in = input(input_name)
    fv_out = output(output_name)

    raise "Could not find input '#{input_name}' in pass" unless fv_in
    raise "Could not find input '#{output_name}' in pass" unless fv_out

    fv_out.child_sample_id = fv_in.child_sample_id
    fv_out.child_item_id = fv_in.child_item_id
    fv_out.save

    return self

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

  def primed_predecessors

    ops = []

    inputs.each do |input|
      input.predecessors.each do |pred|        
        ops << pred.operation if pred.operation && pred.operation.status == "primed"
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
    set_status "planning"
    outputs.each do |output|
      output.wires_as_source.each do |wire|
        wire.active = true
        wire.save
      end
    end
  end

  def deactivate
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
      ops = Operation.includes(:operation_type)
                     .where("status = 'waiting' OR status = 'deferred' OR status = 'delayed' OR status = 'pending'")
    end

    ops.each do |op|
      op.step
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

  def leaf?

    inputs.each do |i|

      if i.predecessors.count > 0
        i.predecessors.each do |pred|
          if pred.operation.on_the_fly
            return pred.operation.leaf?
          else
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

