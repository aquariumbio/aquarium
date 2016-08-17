class OperationsController < ApplicationController

  def active_and_pending_jobs
    job_ids = Operation.pluck(:job_id).uniq.select { |jid| jid }
    { 
      ids: job_ids,
      pending: Job.where(pc: -1, id: job_ids),
      running: Job.where(pc: 0..10000, id: job_ids)
    }    
  end

  def jobs
    render json: active_and_pending_jobs
  end

  def index

    respond_to do |format|
      format.json { render json: Operation.where(status: [ 'pending', 'scheduled', 'running' ]).as_json(methods: :field_values) }
      format.html { render layout: 'browser' }
    end
    
  end

  def batch

    ops = params[:operation_ids].collect { |oid| Operation.find(oid) }

    unless ops.empty? 
      ot = ops.first.operation_type
      job = ot.schedule(ops, current_user, Group.find_by_name('technicians'))
    end

    render json: { operations: ops, jobs: active_and_pending_jobs }

  end

end
