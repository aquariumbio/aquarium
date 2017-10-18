class OperationsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user    

  def active_and_pending_jobs
    job_ids = JobAssociation.joins(:job, :operation).where("pc != -2 && status != 'error'").collect { |ja| ja.job_id }.uniq
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
      jas = op.job_associations.select { |ja| ja.job.pc == Job.NOT_STARTED }
      jobs = jas.collect { |ja| ja.job }
      jas.each { |ja| ja.destroy }
      jobs.each do |job| 
        if job.job_associations.length == 0 
          job.cancel current_user
        end
      end
      op.status = 'pending';
      op.save
      op.step
    end

    render json: { operations: ops }

  end  

  def set_status

    op = Operation.find(params[:id])
    op.status = params[:status]
    op.save

    if op.errors.empty? 
      render json: op
    else
      render json: { errors: op.errors.full_messages }
    end

  end

  def step

    Operation.step
    render json: { result: "ok" }

  end

end
