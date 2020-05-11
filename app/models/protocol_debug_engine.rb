# typed: false
# frozen_string_literal: true

class ProtocolDebugEngine

  # from krill_controller
  def self.debug_job(job:, user_id:)
    errors = []
    # if not running, then start
    if job.not_started?
      job.user_id = user_id
      job.save

      errors = run_job(job: job)
    end

    Operation.step(job.operations.collect { |op| op.plan.operations }.flatten)

    errors
  end

  # from plan_controller
  def self.debug_plan(plan:, current_user:)
    errors = []

    # find all pending operations
    pending = plan.operations.select { |o| o.pending? && o.precondition_value }

    # group them by operation type
    # type_ids = pending.collect(&:operation_type_id).uniq
    type_ids = pending.group_by(&:operation_type)

    # batch each group and run a job
    # type_ids.each do |ot_id|
    type_ids.each do |_operation_type, ops|
      # ops = pending.select { |op| op.operation_type_id == ot_id }
      # operation_type = OperationType.find(ot_id)

      job = Job.schedule(
        operations: ops,
        user: current_user
      )

      errors = run_job(job: job)
    end # type_ids.each

    Operation.step(plan.operations.select { |op| op.waiting? || op.deferred? })

    errors
  end

  # TODO: how does this overlap with test engine?
  def self.run_job(job:)
    errors = []
    begin
      manager = Krill::DebugManager.new(job)
      manager.start
    rescue Krill::KrillSyntaxError, Krill::KrillError => e
      errors << e.error.message
      job.operations.each do |op|
        op.plan.error("Could not debug job: #{e}", :job_start)
      end
    end

    errors
  end

  private_class_method :run_job

end
