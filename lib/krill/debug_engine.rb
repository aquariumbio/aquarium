class DebugEngine

  # from krill_controller
  def self.debug_job(job)
    errors = []
     # if not running, then start
     if job.pc == Job.NOT_STARTED
      job.user_id = current_user.id
      job.save

      begin
        manager = Krill::Manager.new(job, true)
      rescue Krill::KrillSyntaxError => e
        error = e
      end

      if error
        errors << error
      else
        begin
          manager.start
        rescue Krill::KrillError => e
          errors << e.message
        end
      end
    end

    Operation.step @job.operations.collect { |op| op.plan.operations }.flatten

    errors
  end

  # from plan_controller
  def debug_plan(plan)
    errors = []

    # find all pending operations
    pending = plan.operations.select { |o| o.status == 'pending' && o.precondition_value }

    # group them by operation type
    # type_ids = pending.collect(&:operation_type_id).uniq
    type_ids = pending.group_by { |operation| operation.operation_type }

    # batch each group and run a job
    # type_ids.each do |ot_id|
    type_ids.each do |operation_type, ops|
      # ops = pending.select { |op| op.operation_type_id == ot_id }
      # operation_type = OperationType.find(ot_id)

      # TODO: protocol test engine
      job, _newops = operation_type.schedule(
        ops,
        current_user,
        Group.find_by_name('technicians')
      )

      error = nil

      # ????
      job.user_id = current_user.id
      job.save
      # ????

      begin
        manager = Krill::Manager.new(job, true)
      rescue Exception => e
        error = e.to_s
      end

      if error
        errors << error

        ops.each do |op|
          op.plan.error("Could not start job: #{error}", :job_start)
        end
      else
        begin
          ops.extend(Krill::OperationList)
          ops.each(&:run)

          manager.start
        rescue Exception => e
          errors << 'Bug encountered while testing: ' + e.message + ' at ' + e.backtrace.join("\n") + '. '
        end # begin
      end # if
    end # type_ids.each

    Operation.step(plan.operations.select { |op| op.status == 'waiting' || op.status == 'deferred' })

    errors
  end

end