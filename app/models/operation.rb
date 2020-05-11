# typed: false
# frozen_string_literal: true

# Class that represents an operation in the lab
# Some very important methods include {#input}, {#output}, {#error}, {#pass}
# @api krill

class Operation < ActiveRecord::Base

  include DataAssociator
  include FieldValuer
  include OperationPlanner
  include OperationStatus

  belongs_to :operation_type
  belongs_to :user
  has_many :job_associations
  has_many :jobs, through: :job_associations

  has_many :plan_associations
  has_many :plans, through: :plan_associations

  attr_accessible :status, :user_id, :x, :y, :parent_id

  before_destroy :destroy_field_values

  def destroy_field_values
    msg = "Cannot destroy operation #{id} because it has jobs associated with it"
    raise msg unless JobAssociation.where(operation_id: id).empty?

    fvs = FieldValue.where(parent_class: 'Operation', parent_id: id)
    fvs.each do |fv|
      Wire.where("from_id = #{fv.id} OR to_id = #{fv.id}").each do |wire|
        wire.destroy
      end
      fv.destroy
    end
  end

  def parent_type # interface with FieldValuer
    operation_type
  end

  def virtual?
    false
  end

  # @return [String] OperationType name
  delegate :name, to: :operation_type

  # @return [Bool] Whether OperationType is on-the-fly
  delegate :on_the_fly, to: :operation_type

  # @return [Plan] The plan that contains this Operation
  def plan
    plans[0] unless plans.empty?
  end

  # Methods used for building operations for testing via vscode

  # Assigns a Sample to an input, choosing an appropriate allowable_field_type.
  #
  # @param name [String]
  # @param sample [Sample]
  # @return [Operation] this operation
  def with_input(name, sample)
    ft = operation_type.input(name)
    aft = ft.choose_aft_for(sample)
    set_input(name, sample, aft)

    self
  end

  # Assigns a Sample to an output, choosing an appropriate allowable_field_type.
  #
  # @param name [String]
  # @param sample [Sample]
  def with_output(name, sample)
    ft = operation_type.output(name)
    aft = ft.choose_aft_for(sample)
    set_output(name, sample, aft)

    self
  end

  # Assigns a value to an input parameter
  # @param name [String]
  # @param value
  def with_property(name, value)
    set_property(name, value, 'input', false, nil)
  end

  # end methods used for testing via vs code

  # Assigns a Sample to an input
  # @param name [String]
  # @param val [Sample, Item, Number]
  # @param aft [AllowableFieldType]
  def set_input(name, val, aft = nil)
    set_property(name, val, 'input', false, aft)
  end

  # Assigns a Sample to an output
  # @param name [String]
  # @param val [Sample]
  # @param aft [AllowableFieldType]
  def set_output(name, val, aft = nil)
    set_property(name, val, 'output', false, aft)
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
  def add_input(name, sample, container)
    items = Item.where(sample_id: sample.id, object_type_id: container.id).reject(&:deleted?)
    return nil if items.empty?

    item = items.first
    create_input(name: name, item: item, sample: sample)

    item
  end

  def create_input(name:, item:, sample:)
    field_type = create_field_type(name)
    field_type.save

    field_value = create_field_value(name, item, sample, field_type)
    field_value.save
  end

  # TODO: this belongs elsewhere
  def create_field_type(name)
    FieldType.new(
      name: name,
      ftype: 'sample',
      parent_class: 'OperationType',
      parent_id: nil
    )
  end

  def create_field_value(name, item, sample, field_type)
    FieldValue.new(
      name: name,
      child_item_id: item.id,
      child_sample_id: sample.id,
      role: 'input',
      parent_class: 'Operation',
      parent_id: id,
      field_type_id: field_type.id
    )
  end

  # @return [Array<FieldValue>]
  def inputs
    field_values.select { |ft| ft.role == 'input' }
  end

  # @return [Array<FieldValue>]
  def outputs
    field_values.select { |ft| ft.role == 'output' }
  end

  # @param name [String]
  # @return [FieldValue]
  def get_input(name)
    inputs.find { |i| i.name == name }
  end

  # @param name [String]
  # @return [FieldValue]
  def get_output(name)
    outputs.find { |o| o.name == name }
  end

  # @param name [String]
  # @return [FieldValue]
  def input(name)
    get_input(name)
  end

  # @param name [String]
  # @return [FieldValue]
  def output(name)
    get_output name
  end

  # Inputs as Array extended with {#IOList}
  # @param name [String]
  # @return [Array<FieldValue>]
  def input_array(name)
    inputs.select { |i| i.name == name }.extend(IOList)
  end

  # Outputs as Array extended with {#IOList}
  # @param name [String]
  # @return [Array<FieldValue>]
  def output_array(name)
    outputs.select { |o| o.name == name } .extend(IOList)
  end

  # @param name [String]
  # @param role [String]
  # @return [FieldValue]
  def get_field_value(name, role = 'input')
    field_values.find { |fv| fv.name == name && fv.role == role }
  end

  # Passes an input item to an output (alternative to {Krill::OperationList#make})
  # @param input_name [String]
  # @param output_name [String]
  # @return [Operation]
  def pass(input_name, output_name = nil)

    output_name ||= input_name

    fv_in = input(input_name)
    fv_out = output(output_name)

    raise "Could not find input '#{input_name}' in pass" unless fv_in
    raise "Could not find input '#{output_name}' in pass" unless fv_out

    fv_out.child_sample_id = fv_in.child_sample_id
    fv_out.child_item_id = fv_in.child_item_id
    fv_out.save

    self

  end

  def recurse(&block)
    block.call(self)
    inputs.each do |input|
      input.predecessors.each do |predecessor|
        predecessor.operation.recurse(&block)
      end
    end
  end

  def find(name)
    ops = []
    recurse do |op|
      ops << op if op.operation_type.name == name
    end
    ops
  end

  def set_status_recursively(str)
    recurse do |op|
      op.status = str
      op.save
    end
  end

  def to_s
    ins = (inputs.collect { |fv| "#{fv.name}: #{fv.child_sample ? fv.child_sample.name : 'NO SAMPLE'}" }).join(', ')
    outs = (outputs.collect { |fv| "#{fv.name}: #{fv.child_sample ? fv.child_sample.name : 'NO SAMPLE'}" }).join(', ')
    "#{operation_type.name} #{id} ( " + ins + ' ) ==> ( ' + outs + ' )'
  end

  def successors
    successor_list = []
    outputs.each do |output|
      output.successors.each do |suc|
        successor_list << suc.operation
      end
    end

    successor_list
  end

  def predecessors
    predecessor_list = []
    inputs.each do |input|
      input.predecessors.each do |predecessor|
        predecessor_list << predecessor.operation
      end
    end

    predecessor_list
  end

  def primed_predecessors
    ops = []
    inputs.each do |input|
      input.predecessors.each do |predecessor|
        ops << predecessor.operation if predecessor.operation && predecessor.operation.primed?
      end
    end

    ops
  end

  def siblings
    ops = outputs.collect do |output|
      output.wires_as_source.collect do |wire|
        wire.to.predecessors.collect(&:operation)
      end
    end

    ops.flatten
  end

  def activate
    set_status 'planning'
    outputs.each do |output|
      output.wires_as_source.each do |wire|
        wire.active = true
        wire.save
      end
    end
  end

  def deactivate
    set_status 'unplanned'
    outputs.each do |output|
      output.wires_as_source.each do |wire|
        wire.active = false
        wire.save
      end
    end
  end

  def self.step(ops = nil)
    ops ||= Operation.includes(:operation_type)
                     .where("status = 'waiting' OR status = 'deferred' OR status = 'delayed' OR status = 'pending'")

    ops.each(&:step)
  end

  def nominal_cost
    begin
      operation_type.cost_model.load(binding: empty_binding)
    rescue ScriptError, StandardError => e
      raise "Error loading cost function for #{operation_type.name}: " + e.to_s
    end

    temp = status
    self.status = 'done'

    begin
      c = cost(self)
    rescue SystemStackError, ScriptError, StandardError => e
      self.status = temp
      raise "Error evaluating cost function for #{operation_type.name}: " + e.to_s
    end

    self.status = temp
    c
  end

  def input_data(input_name, data_name)
    fv = input(input_name)
    fv.child_data(data_name) if fv
  end

  def output_data(output_name, data_name)
    fv = output(output_name)
    fv.child_data(data_name) if fv
  end

  def set_input_data(input_name, data_name, value)
    fv = input(input_name)
    fv.set_child_data(data_name, value) if fv
  end

  def set_output_data(output_name, data_name, value)
    fv = output(output_name)
    fv.set_child_data(data_name, value) if fv
  end

  def precondition_value
    result = true

    begin
      operation_type.precondition.load(binding: empty_binding)
    rescue ScriptError, StandardError => e
      # Raise "Error loading precondition for #{operation_type.name}: " + e.to_s
      Rails.logger.info "Error loading precondition for #{operation_type.name} (id: #{id})"
      plan.associate 'Precondition load error', e.message.to_s + ': ' + e.backtrace[0].to_s.sub('(eval)', 'line')
    end

    begin
      result = precondition(self)
    rescue SystemStackError, ScriptError, StandardError => e
      Rails.logger.info "PRECONDITION FOR OPERATION #{id} CRASHED"
      plan.associate 'Precondition Evaluation Error', e.message.to_s + ': ' + e.backtrace[0].to_s.sub('(eval)', 'line')
      result = false # default if there is no precondition or it crashes
    end

    result
  end

  def add_successor(opts)
    ot = OperationType.find_by(name: opts[:type])

    op = ot.operations.create(
      status: 'waiting',
      user_id: user_id
    )

    plan.plan_associations.create(operation_id: op.id)

    opts[:routing].each do |r|
      ot.field_types.select { |ft| ft.routing == r[:symbol] }.each do |ft|
        aft = ft.allowable_field_types[0]
        op.set_property(ft.name, r[:sample], ft.role, false, aft)
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
      next unless i.predecessors.count > 0

      i.predecessors.each do |pred|
        return pred.operation.leaf? if pred.operation.on_the_fly

        return false
      end
    end

    true
  end

  def temporary
    @temporary ||= {}
    @temporary
  end

  private

  # Create an empty binding
  def empty_binding
    binding
  end
end
