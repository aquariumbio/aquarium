class OperationType < ActiveRecord::Base

  include FieldTyper
  include OperationTypePlanner
  include CodeHelper

  has_many :operations
  # has_many :fts, foreign_key: "parent_id", class_name: "FieldType"

  attr_accessible :name, :protocol

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

  def schedule ops, user, group

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
    job.save

    ops.each do |op|
      op.status = "scheduled"
      op.job_id = job.id
      op.save
    end

    job

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

end