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

  # The input types of this OperationType.
  #
  # @return [Array<FieldType>]  meta definitions of the inputs
  #           that would be required to instantiate an operation of this type.
  def inputs
    field_types.select { |ft| ft.role == 'input' }
  end

  # The output types of this OperationType.
  #
  # @return [Array<FieldType>]  meta definitions of the outputs
  #           that could be produced by a successful operation of this type
  def outputs
    field_types.select { |ft| ft.role == 'output' }
  end

  def waiting
    operations.where status: 'waiting'
  end

  def pending
    operations.where status: 'pending'
  end

  def done
    operations.where status: 'done'
  end

  def protocol
    code('protocol')
  end

  def cost_model
    code 'cost_model'
  end

  def precondition
    code('precondition')
  end

  def documentation
    code('documentation')
  end

  def test
    code('test')
  end

  def schedule_aux(ops, user, group, opts = {})
    job = Job.new

    job.path = 'operation.rb'
    job.pc = Job.NOT_STARTED
    job.set_arguments(operation_type_id: id)
    job.group_id = group.id
    job.submitted_by = user.id
    job.desired_start_time = Time.now
    job.latest_start_time = Time.now + 1.hour
    job.successor_id = opts[:successor].id if opts[:successor]
    job.save

    ops.each do |op|
      if opts[:defer]
        op.defer
      else
        op.schedule
      end
      JobAssociation.create job_id: job.id, operation_id: op.id
      op.save
    end

    job
  end

  def primed(operations)
    p = []

    operations.each do |op|
      op.inputs.each do |input|
        input.predecessors.each do |pred|
          p << pred.operation if pred.operation.status == 'primed'
        end
      end
    end

    p
  end

  def schedule(operations, user, group, opts = {})
    ops_to_schedule = []
    ops_to_defer = []

    operations.each do |op|
      pps = op.primed_predecessors
      if !pps.empty?
        ops_to_schedule += pps
        ops_to_defer << op
      else
        ops_to_schedule << op
      end
    end

    schedule_aux ops_to_defer, user, group, opts.merge(defer: true)
    job = schedule_aux ops_to_schedule, user, group, opts

    [job, ops_to_schedule]
  end

  #
  # Update Methods for Field Types from Front End Start Here
  #

  def add_new_allowable_field_type(ft, newaft)

    st = (SampleType.find_by_name(newaft[:sample_type][:name]) if newaft[:sample_type])

    ot = (ObjectType.find_by_name(newaft[:object_type][:name]) if newaft[:object_type] && newaft[:object_type][:name] != '')

    ft.allowable_field_types.create(
      sample_type_id: st ? st.id : nil,
      object_type_id: ot ? ot.id : nil
    )

  end

  def update_allowable_field_type(old_aft, new_aft)

    if new_aft[:sample_type]
      st = SampleType.find_by_name(new_aft[:sample_type][:name])
      old_aft.sample_type_id = st.id if st
    else
      old_aft.sample_type_id = nil
    end

    if new_aft[:object_type] && new_aft[:object_type][:name] != ''
      ot = ObjectType.find_by_name(new_aft[:object_type][:name])
      old_aft.object_type_id = ot.id if ot
    else
      old_aft.sample_type_id = nil
    end

    old_aft.save

  end

  def add_new_field_type(newft)

    if newft[:allowable_field_types]

      sample_type_names = newft[:allowable_field_types].collect do |aft|
        aft[:sample_type] ? aft[:sample_type][:name] : nil
      end

      container_names = newft[:allowable_field_types]
                        .select { |aft| aft[:object_type] && aft[:object_type][:name] && aft[:object_type][:name] != '' }
                        .collect do |aft|
        raise "Object type '#{aft[:object_type][:name]}' not defined by browser for #{ft[:name]}." unless ObjectType.find_by_name(aft[:object_type][:name])

        aft[:object_type][:name]
      end

    else

      sample_type_names = []
      container_names = []

    end

    add_io(
      newft[:name],
      sample_type_names,
      container_names,
      newft[:role],
      array: newft[:array],
      part: newft[:part],
      routing: newft[:routing],
      ftype: newft[:ftype],
      choices: newft[:choices]
    )

    field_types.where(name: newft[:name], role: newft[:role])[0]

  end

  def update_field_type(oldft, newft)

    oldft.name = newft[:name]
    if oldft.ftype == 'sample'
      oldft.routing = newft[:routing]
      oldft.array = newft[:array]
      oldft.part = newft[:part]
      oldft.preferred_operation_type_id = newft[:preferred_operation_type_id]
      oldft.preferred_field_type_id = newft[:preferred_field_type_id]

      puts "PREF(#{oldft.name}): #{newft[:preferred_field_type_id]}"

      keepers = []
      if newft[:allowable_field_types]
        newft[:allowable_field_types].each do |newaft|
          matching_afts = oldft.allowable_field_types.select { |aft| aft.id == newaft[:id] }
          if matching_afts.length == 1
            oldaft = matching_afts[0]
            keepers << oldaft
            update_allowable_field_type oldaft, newaft
          elsif matching_afts.empty?
            keepers << add_new_allowable_field_type(oldft, newaft)
          else
            raise 'More than one allowable field type matched.'
          end
        end
      end
    else
      oldft.ftype = newft[:ftype]
      oldft.choices = newft[:choices]
    end

    oldft.save

    oldft.allowable_field_types.reject { |aft| keepers.include? aft }.each(&:destroy)
  end

  def update_field_types(fts)

    keepers = []

    if fts
      fts.each do |newft|
        matching_fts = field_types.select { |oldft| oldft.id == newft[:id] && oldft.role == newft[:role] }
        if matching_fts.length == 1
          oldft = matching_fts[0]
          keepers << oldft
          update_field_type oldft, newft
        elsif matching_fts.empty?
          keepers << add_new_field_type(newft)
        else
          raise "Multiple inputs (or outputs) named #{newft[:name]}"
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
          puts "ERRORING OUT OP #{op.id}"
          op.error :obsolete, 'The operation type definition for this operation has changed too much since it was created.'
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
