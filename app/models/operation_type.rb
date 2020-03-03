# frozen_string_literal: true

# Defines a type of lab procedure, with the input-types, output-types, and the instructions for converting inputs into outputs.
# Executable unit {Operation}s can be instantiated from an OperationType, and specific inputs and outputs are then given.
# @api krill
class OperationType < ActiveRecord::Base

  include FieldTyper
  include OperationTypePlanner
  include CodeHelper
  include OperationTypeExport
  include OperationTypeWorkflow
  include OperationTypeRandom
  include HasTiming
  include DataAssociator

  has_many :operations
  # has_many :fts, foreign_key: "parent_id", class_name: "FieldType"

  attr_accessible :deployed, :on_the_fly

  # Gets name of OperationType.
  #
  # @return [String]  the name of the OperationType, as in "Rehydrate Primer"
  attr_accessible :name

  # Gets category of OperationType.
  #
  # @return [String]  the category of the OperationType, as in "Cloning"
  attr_accessible :category

  validates :name, presence: true
  validates :name, uniqueness: {
    scope: :category,
    case_sensitive: false,
    message: 'OperationType names must be unique within a given category. When importing, consider first moving existing operation types to a different category'
  }
  validates :category, presence: true

  def add_io(name, sample_name, container_name, role, opts)
    add_field(name, sample_name, container_name, role, opts)
  end

  def add_input(name, sample_name, container_name, opts = {})
    add_field(name, sample_name, container_name, 'input', opts)
  end

  def add_output(name, sample_name, container_name, opts = {})
    add_field(name, sample_name, container_name, 'output', opts)
  end

  def add_parameter(name:, type:, choices:)
    add_field(name, nil, nil, 'input', ftype: type, choices: choices)
  end

  # The input types of this OperationType.
  #
  # @return [Array<FieldType>]  meta definitions of the inputs
  #           that would be required to instantiate an operation of this type.
  def inputs
    field_types.select { |ft| ft.role == 'input' }
  end

  # Returns the input of this OperationType with the given name.
  #
  # @param name [String] the name of the input
  def input(name)
    inputs.select { |field_type| field_type[:name] == name }.first
  end

  # The output types of this OperationType.
  #
  # @return [Array<FieldType>]  meta definitions of the outputs
  #           that could be produced by a successful operation of this type
  def outputs
    field_types.select { |ft| ft.role == 'output' }
  end

  # Returns the output of this OperationType with the given name.
  #
  # @param name [String] the name of the input
  # @return [FieldType] the named output
  def output(name)
    outputs.select { |field_type| field_type[:name] == name }.name
  end

  def waiting
    operations.where(status: 'waiting')
  end

  def pending
    operations.where(status: 'pending')
  end

  def done
    operations.where(status: 'done')
  end

  def protocol
    code('protocol')
  end

  def add_protocol(content:, user:)
    if protocol
      protocol.commit(content, user)
    else
      new_code('protocol', content, user)
    end
  end

  def defined_methods
    source.defined_methods
  end

  def defined_classes
    source.defined_classes
  end

  def defined_modules
    source.defined_modules
  end

  def referenced_libraries
    source.referenced_libraries
  end

  def referenced_modules
    source.referenced_modules
  end

  def cost_model
    code('cost_model')
  end

  def add_cost_model(content:, user:)
    if cost_model
      cost_model.commit(content, user)
    else
      new_code('cost_model', content, user)
    end
  end

  def precondition
    code('precondition')
  end

  def add_precondition(content:, user:)
    if precondition
      precondition.commit(content, user)
    else
      new_code('precondition', content, user)
    end
  end

  def documentation
    code('documentation')
  end

  def test
    code('test')
  end

  def add_test(content:, user:)
    if test
      test.commit(content, user)
    else
      new_code('test', content, user)
    end
  end

  #
  # Update Methods for Field Types from Front End Start Here
  #

  def add_new_allowable_field_type(ft, new_type)
    st = (SampleType.find_by(name: new_type[:sample_type][:name]) if new_type[:sample_type])
    ot = (ObjectType.find_by(name: new_type[:object_type][:name]) if new_type[:object_type] && new_type[:object_type][:name] != '')

    ft.allowable_field_types.create(
      sample_type_id: st ? st.id : nil,
      object_type_id: ot ? ot.id : nil
    )
  end

  def update_allowable_field_type(old_aft, new_aft)
    if new_aft[:sample_type]
      st = SampleType.find_by(name: new_aft[:sample_type][:name])
      old_aft.sample_type_id = st.id if st
    else
      old_aft.sample_type_id = nil
    end

    if new_aft[:object_type] && new_aft[:object_type][:name] != ''
      ot = ObjectType.find_by(name: new_aft[:object_type][:name])
      old_aft.object_type_id = ot.id if ot
    else
      old_aft.sample_type_id = nil
    end

    old_aft.save
  end

  def add_new_field_type(new_type)
    if new_type[:allowable_field_types]

      sample_type_names = new_type[:allowable_field_types].collect do |aft|
        aft[:sample_type] ? aft[:sample_type][:name] : nil
      end

      container_names = new_type[:allowable_field_types]
                        .select { |aft| aft[:object_type] && aft[:object_type][:name] && aft[:object_type][:name] != '' }
                        .collect do |aft|
        raise "Object type '#{aft[:object_type][:name]}' not defined by browser for #{ft[:name]}." unless ObjectType.find_by(name: aft[:object_type][:name])

        aft[:object_type][:name]
      end
    else
      sample_type_names = []
      container_names = []
    end

    add_io(
      new_type[:name],
      sample_type_names,
      container_names,
      new_type[:role],
      array: new_type[:array],
      part: new_type[:part],
      routing: new_type[:routing],
      ftype: new_type[:ftype],
      choices: new_type[:choices]
    )

    field_types.where(name: new_type[:name], role: new_type[:role])[0]
  end

  def update_field_type(old_type:, new_type:)
    keepers = []
    old_type.name = new_type[:name]

    if old_type.sample?
      old_type.routing = new_type[:routing]
      old_type.array = new_type[:array]
      old_type.part = new_type[:part]
      old_type.preferred_operation_type_id = new_type[:preferred_operation_type_id]
      old_type.preferred_field_type_id = new_type[:preferred_field_type_id]

      puts "PREF(#{old_type.name}): #{new_type[:preferred_field_type_id]}"

      if new_type[:allowable_field_types]
        new_type[:allowable_field_types].each do |newaft|
          matching_types = old_type.allowable_field_types.select { |aft| aft.id == newaft[:id] }
          if matching_types.length == 1
            oldaft = matching_types[0]
            keepers << oldaft
            update_allowable_field_type oldaft, newaft
          elsif matching_types.empty?
            keepers << add_new_allowable_field_type(old_type, newaft)
          else
            raise 'More than one allowable field type matched.'
          end
        end
      end

    else
      old_type.ftype = new_type[:ftype]
      old_type.choices = new_type[:choices]
    end

    old_type.save

    old_type.allowable_field_types.reject { |aft| keepers.include? aft }.each(&:destroy) unless keepers.empty?
  end

  def update_field_types(fts)
    keepers = []

    if fts
      fts.each do |new_ft|
        matching_fts = field_types.select { |field_type| field_type.id == new_ft[:id] && field_type.role == new_ft[:role] }
        if matching_fts.length == 1
          old_ft = matching_fts[0]
          keepers << old_ft
          update_field_type(old_type: old_ft, new_type: new_ft)
        elsif matching_fts.empty?
          keepers << add_new_field_type(new_ft)
        else
          raise "Multiple inputs (or outputs) named #{new_ft[:name]}"
        end
      end
    end

    field_types.reject { |ft| keepers.include? ft }.each do |ft|
      puts "DELETING FT #{ft.name}/#{ft.role}"
      ft.destroy
    end

    error_out_obsolete_operations
  end

  def error_out_obsolete_operations
    Operation.where(operation_type_id: id, status: %w[pending scheduled]).each do |op|
      op.field_values.each do |fv|
        if !fv.field_type || !fv.allowable_field_type
          puts("ERRORING OUT OP #{op.id}")
          op.error(:obsolete, 'The operation type definition for this operation has changed too much since it was created.')
        end
      end
    end
  end

  def stats
    r = { 'done' => 0, 'error' => 0 }

    operations.each do |op|
      r[op.status] ||= 0
      r[op.status] = r[op.status] + 1
    end

    r['success'] = if r['done'] + r['error'] != 0
                     r['done'].to_f / (r['done'] + r['error'])
                   else
                     0.0
                   end

    unless operations.empty?
      r['first_run'] = operations[0].updated_at
      r['last_run'] = operations.last.updated_at
    end

    r
  end

  def self.numbers(user = nil)
    q = if user.nil?
          "
            SELECT   status, operation_type_id, COUNT(status)
            FROM     operations
            GROUP BY operation_type_id, status
          "
        else
          "
            SELECT   status, operation_type_id, COUNT(status)
            FROM     operations
            WHERE    user_id = #{user.id}
            GROUP BY operation_type_id, status
          "
        end

    r = ActiveRecord::Base.connection.execute(q).entries

    result = {}
    r.each do |status, ot_id, count|
      result[ot_id] ||= { planning: 0, waiting: 0, pending: 0, delayed: 0, deferred: 0, primed: 0, scheduled: 0, running: 0, error: 0, done: 0 }
      result[ot_id][status] = count
      result[ot_id][:waiting] = count if status == 'primed'
    end

    result
  end

end
