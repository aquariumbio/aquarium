# frozen_string_literal: true

class ProtocolDebugEngine

  # from krill_controller
  def self.debug_job(job)
    errors = []
    # if not running, then start
    if job.pc == Job.NOT_STARTED
      job.user_id = current_user.id
      job.save

      errors = run_job(job: job)
    end

    Operation.step @job.operations.collect { |op| op.plan.operations }.flatten

    errors
  end

  # TODO: how does this overlap with test engine?
  def run_job(job:)
    errors = []
    begin
      manager = Krill::DebugManager(job, true)
      manager.start
    rescue Krill::KrillSyntaxError, Krill::KrillError => e
      errors << e.message
      ops.each do |op|
        op.plan.error("Could not start job: #{e}", :job_start)
      end
    end

    errors
  end

  # TODO: consolidate with code in protocol test engine
  def make_job(operation_type:, operations:, user:)
    operations.extend(Krill::OperationList)
    job, _newops = operation_type.schedule(
      operations,
      user,
      Group.find_by_name('technicians')
    )

    job
  end

  # from plan_controller
  def debug_plan(plan)
    errors = []

    # find all pending operations
    pending = plan.operations.select { |o| o.status == 'pending' && o.precondition_value }

    # group them by operation type
    # type_ids = pending.collect(&:operation_type_id).uniq
    type_ids = pending.group_by(&:operation_type)

    # batch each group and run a job
    # type_ids.each do |ot_id|
    type_ids.each do |operation_type, ops|
      # ops = pending.select { |op| op.operation_type_id == ot_id }
      # operation_type = OperationType.find(ot_id)

      job = make_job(
        operation_type: operation_type,
        operations: ops,
        user: current_user
      )

      errors = run_job(job: job)
    end # type_ids.each

    Operation.step(plan.operations.select { |op| op.status == 'waiting' || op.status == 'deferred' })

    errors
  end

end
