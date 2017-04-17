class OperationsController < ApplicationController

  before_filter :signed_in_user

  def active_and_pending_jobs
    job_ids = Operation.pluck(:job_id).uniq.select { |jid| jid }
    { 
      ids: job_ids,
      pending: Job.includes(:predecessors).where(pc: -1, id: job_ids).as_json(methods: :active_predecessors),
      running: Job.where(pc: 0..10000, id: job_ids)
    }    
  end

  def jobs
    render json: active_and_pending_jobs
  end

  def index

    respond_to do |format|
      format.json { render json: Operation.where(status: [ 'pending', 'scheduled', 'running', 'primed' ])
                                          .as_json(methods: [:field_values, :plans, :precondition_value]) }
      format.html { render layout: 'aq2' }
    end
    
  end

  def batch

    ops = params[:operation_ids].collect { |oid| Operation.find(oid) }

    unless ops.empty?
      ot = ops.first.operation_type
      job,operations = ot.schedule(ops, current_user, Group.find_by_name('technicians'))
    end

    render json: { operations: operations, jobs: active_and_pending_jobs }

  end

  def unbatch

    ops = params[:operation_ids].collect { |oid| Operation.find(oid) }

    ops.each do |op|
      job = op.job
      op.job_id = nil
      op.status = 'pending';
      op.save
      if job.reload.operations.length == 0
        job.cancel current_user
      end
    end

    render json: { operations: ops }

  end  

end
