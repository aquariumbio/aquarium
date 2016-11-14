class OperationType < ActiveRecord::Base

  include FieldTyper
  include OperationTypePlanner
  include CodeHelper
  include OperationTypeExport
  include OperationTypeWorkflow

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
      op.status = "scheduled"
      op.job_id = job.id
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

    scheduled_ops = ops
    job = schedule_aux ops, user, group, opts

    primed_list = primed ops

    unless primed_list.empty?
      ot = primed_list.first.operation_type
      j,more_ops = ot.schedule primed_list, user, group, successor: job
      scheduled_ops += more_ops
    end

    [job,scheduled_ops]

  end

end
