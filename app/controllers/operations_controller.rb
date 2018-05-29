class OperationsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def active_and_pending_jobs
    job_ids = JobAssociation.joins(:job, :operation).where("pc != -2 && status != 'error'").collect(&:job_id).uniq
    {
      ids: job_ids,
      pending: Job.includes(:predecessors).where(pc: -1, id: job_ids).as_json(methods: :active_predecessors),
      running: Job.where(pc: 0..10_000, id: job_ids)
    }
  end

  def jobs
    render json: active_and_pending_jobs
  end

  def index

    respond_to do |format|
      format.json do
        render json: Operation.where(status: %w[pending scheduled running primed])
                              .as_json(methods: %i[field_values plans precondition_value])
      end
      format.html { render layout: 'aq2' }
    end

  end

  def batch

    ops = params[:operation_ids].collect { |oid| Operation.find(oid) }

    unless ops.empty?
      ot = ops.first.operation_type
      job, operations = ot.schedule(ops, current_user, Group.find_by(name: 'technicians'))
    end

    render json: { operations: operations, jobs: active_and_pending_jobs }

  end

  def unbatch

    ops = params[:operation_ids].collect { |oid| Operation.find(oid) }

    ops.each do |op|
      jas = op.job_associations.select { |ja| ja.job.pc == Job.NOT_STARTED }
      jobs = jas.collect(&:job)
      jas.each(&:destroy)
      jobs.each do |job|
        job.cancel current_user if job.job_associations.empty?
      end
      op.status = 'pending'
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

  def retry

    op = Operation.find(params[:id])
    op.retry
    Operation.step op.plan.operations.select { |op| op.status != 'done' && op.status != 'error' }

    render json: { status: op.status }

  end

  def step

    Operation.step
    render json: { result: 'ok' }

  end

  def manager_list

    ops = Operation.where(params[:criteria])
    ops = ops.limit(params[:options][:limit])   if params[:options] && params[:options][:limit] && params[:options][:limit].to_i > 0
    ops = ops.offset(params[:options][:offset]) if params[:options] && params[:options][:offset] && params[:options][:offset].to_i > 0
    ops = ops.order('created_at DESC')          if params[:options] && params[:options][:reverse]
    ops = ops.as_json

    op_ids = ops.collect { |op| op['id'] }
    user_ids = ops.collect { |op| op['user_id'] }

    jas = JobAssociation.includes(:job).where(operation_id: op_ids).as_json(include: 'job')
    users = User.where(id: user_ids).collect { |u| { name: u.name, id: u.id, login: u.login } }.as_json
    pas = PlanAssociation.includes(:plan).where(operation_id: op_ids).as_json(include: 'plan')
    das = DataAssociation.where(parent_class: 'Operation', parent_id: op_ids).as_json
    fvs = FieldValue.where(parent_class: 'Operation', parent_id: op_ids).as_json

    item_ids = fvs.collect { |fv| fv['child_item_id'] }
    sample_ids = fvs.collect { |fv| fv['child_sample_id'] }
    items = Item.includes(:object_type, locator: :wizard).where(id: item_ids).as_json(include: 'object_type')
    samples = Sample.includes(:sample_type).where(id: sample_ids).as_json(include: 'sample_type')

    fvs.each do |fv|
      fv['item'] = items.find { |i| i['id'] == fv['child_item_id'] }
      fv['sample'] = samples.find { |s| s['id'] == fv['child_sample_id'] }
    end

    ops.each do |op|
      op['jobs'] = jas.select { |ja| op['id'] == ja['operation_id'] }.collect { |ja| ja['job'] }
      op['user'] = users.find { |u| u['id'] == op['user_id'] }
      op['plans'] = pas.select { |pa| op['id'] == pa['operation_id'] }.collect { |pa| pa['plan'] }
      op['field_values'] = fvs.select { |fv| op['id'] == fv['parent_id'] }
      op['data_associations'] = das.select { |da| op['id'] == da['parent_id'] }
    end

    render json: ops

  end

end
