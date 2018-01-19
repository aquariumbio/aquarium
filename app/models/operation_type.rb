class OperationType < ActiveRecord::Base

  include FieldTyper
  include OperationTypePlanner
  include CodeHelper
  include OperationTypeExport
  include OperationTypeWorkflow
  include OperationTypeRandom
  include HasTiming

  has_many :operations
  # has_many :fts, foreign_key: "parent_id", class_name: "FieldType"

  attr_accessible :name, :category, :deployed, :on_the_fly

  validates :name, presence: true
  validates :category, presence: true

  def add_io name, sample_name, container_name, role, opts
    add_field name, sample_name, container_name, role, opts
  end

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

  def waiting
    operations.where status: "waiting"
  end

  def pending
    operations.where status: "pending"
  end

  def done
    operations.where status: "done"
  end  

  def protocol
    self.code "protocol"
  end

  def cost_model
    self.code "cost_model"
  end

  def precondition
    self.code "precondition"
  end  

  def documentation
    self.code "documentation"
  end

  def schedule_aux ops, user, group, opts={}

    job = Job.new
    
    job.path = "operation.rb"
    job.sha = nil # lame, but this is how I signal to the krill manager
                  # that this is job is associated with an operation type

    job.pc = Job.NOT_STARTED
    job.set_arguments({ operation_type_id: id})
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

  def primed ops

    p = []

    ops.each do |op|
      op.inputs.each do |input|
        input.predecessors.each do |pred|
          if pred.operation.status == "primed"
            p << pred.operation
          end
        end
      end
    end

    p

  end

  def schedule ops, user, group, opts={}

    ops_to_schedule = []
    ops_to_defer = []

    ops.each do |op|

      pps = op.primed_predecessors

      if pps.length > 0
        ops_to_schedule = ops_to_schedule + pps
        ops_to_defer << op
      else 
        ops_to_schedule << op
      end

    end

    deferred_job = schedule_aux ops_to_defer, user, group, opts.merge(defer: true)
    job = schedule_aux ops_to_schedule, user, group, opts

    [job,ops_to_schedule]
    
  end


  #
  # Update Methods for Field Types from Front End Start Here
  #

  def add_new_allowable_field_type ft, newaft

    if newaft[:sample_type]
      st = SampleType.find_by_name(newaft[:sample_type][:name])
    else
      st = nil
    end

    if newaft[:object_type] && newaft[:object_type][:name] != ""
      ot = ObjectType.find_by_name(newaft[:object_type][:name])
    else
      ot = nil
    end   

    ft.allowable_field_types.create(
      sample_type_id: st ? st.id : nil,
      object_type_id: ot ? ot.id : nil
    )

  end 

  def update_allowable_field_type oldaft, newaft

    if newaft[:sample_type]
      st = SampleType.find_by_name(newaft[:sample_type][:name])
      oldaft.sample_type_id = st.id if st
    else
      oldaft.sample_type_id = nil
    end

    if newaft[:object_type] && newaft[:object_type][:name] != ""
      ot = ObjectType.find_by_name(newaft[:object_type][:name])
      oldaft.object_type_id = ot.id if ot
    else
      oldaft.sample_type_id = nil
    end   

    oldaft.save

  end

  def add_new_field_type newft

    if newft[:allowable_field_types]

      sample_type_names = newft[:allowable_field_types].collect { |aft| 
        aft[:sample_type] ? aft[:sample_type][:name] : nil
      }

      container_names =  newft[:allowable_field_types]
        .select { |aft| aft[:object_type] && aft[:object_type][:name] && aft[:object_type][:name] != "" }
        .collect { |aft|            
          raise "Object type '#{aft[:object_type][:name]}' not definied by browser for #{ft[:name]}." unless ObjectType.find_by_name(aft[:object_type][:name])
          aft[:object_type][:name]
      }          

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

    return field_types.where(name: newft[:name], role: newft[:role])[0]

  end

  def update_field_type oldft, newft

    if oldft.ftype == 'sample'

      oldft.name = newft[:name]
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
          elsif matching_afts.length == 0
            keepers << add_new_allowable_field_type(oldft, newaft)
          else
            raise "More than one allowable field type matched."
          end

        end

      end

    else

      oldft.name = newft[:name]
      oldft.ftype = newft[:ftype]
      oldft.choices = newft[:choices]

    end

    oldft.save

    oldft.allowable_field_types.reject { |aft| keepers.include? aft }.each do |aft|
      aft.destroy
    end

  end

  def update_field_types fts

    keepers = []

    if fts
      fts.each do |newft|
        matching_fts = field_types.select { |oldft| oldft.id == newft[:id] && oldft.role == newft[:role] }
        if matching_fts.length == 1
          oldft = matching_fts[0]
          keepers << oldft
          update_field_type oldft, newft
        elsif matching_fts.length == 0
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

    Operation.where(operation_type_id: id, status: ["pending", "scheduled"]).each do |op|

      op.field_values.each do |fv|

        if !fv.field_type || !fv.allowable_field_type
          puts "ERRORING OUT OP #{op.id}" 
          op.error :obsolete, "The operation type definition for this operation has changed too much since it was created."
        end

      end

    end

  end

  def stats 

    r = { "done" => 0, "error" => 0 }

    operations.each do |op|
      r[op.status] ||= 0
      r[op.status] = r[op.status] + 1
    end

    if r["done"] + r["error"] != 0 
      r["success"] = r["done"].to_f / ( r["done"] + r["error"] )
    else 
      r["success"] = 0.0
    end

    if operations.length > 0
      r["first_run"] = operations[0].updated_at
      r["last_run"] = operations.last.updated_at    
    end

    r

  end

  def self.numbers user=nil

    if user == nil
      q = "
        SELECT   status, operation_type_id, COUNT(status)
        FROM     operations
        GROUP BY operation_type_id, status
      "
    else
      q = "
        SELECT   status, operation_type_id, COUNT(status)
        FROM     operations
        WHERE    user_id = #{user.id}
        GROUP BY operation_type_id, status
      "
    end

    r = ActiveRecord::Base.connection.execute(q).entries

    result = {}
    r.each do |status,ot_id,count|
      result[ot_id] ||= { planning: 0, waiting: 0, pending: 0, delayed: 0, deferred: 0, primed: 0, scheduled: 0, running: 0, error: 0, done: 0 }
      result[ot_id][status] = count
    end

    result

  end

end










