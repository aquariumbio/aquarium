module JobOperations # included in Job model

  def set_op_status str, force = false
    operations.each do |op|
      if op.status != "error" || force
        Rails.logger.info "#{op.id}: SETTING STATUS FROM #{op.status} to #{str}"
        op.set_status str
      else
        Rails.logger.info "#{op.id}: DID NOT SET STATUS BECUASE IT WAS ALREADY 'error'"
      end
    end
  end

  def cancel_plans
    plans = operations.collect { |op| op.plan }.uniq
    plans.each do |plan|
      plan.error "All operations in this plan were canceled because job number #{id} crashed."
    end
  end

  def charge

    labor_rate = Parameter.get_float("labor rate")
    markup_rate = Parameter.get_float("markup rate")

    operations.each do |op|

      c = {}

      begin
        c = op.nominal_cost.merge(labor_rate: labor_rate, markup_rate: markup_rate)
      rescue Exception => e
        op.associate :cost_error, e.to_s
      else
        if op.plan && op.plan.budget_id

          materials = Account.new(
            user_id: op.user_id,
            category: "materials",
            amount: c[:materials],
            budget_id: op.plan.budget_id,
            description: "Materials",
            labor_rate: labor_rate,
            markup_rate: markup_rate,
            operation_id: op.id,
            job_id: id,
            transaction_type: "debit"
          )

          materials.save

          op.associate :cost_error, materials.errors.full_messages.join(', ') unless materials.errors.empty?

          labor = Account.new(
            user_id: op.user_id,
            category: "labor",
            amount: c[:labor] * labor_rate,
            budget_id: op.plan.budget_id,
            description: "Labor: #{c[:labor]} minutes @ $#{labor_rate}/min",
            labor_rate: labor_rate,
            markup_rate: markup_rate,
            operation_id: op.id,
            job_id: id,
            transaction_type: "debit"
          )

          labor.save

          op.associate :cost_error, labor.errors.full_messages.join(', ') unless labor.errors.empty?

        end
      end

    end

  end

  def start
    if self.pc == Job.NOT_STARTED
      self.pc = 0
      save
      operations.each do |op|
        op.run
      end
    end
  end

  def stop status = "done"
    if self.pc >= 0
      self.pc = Job.COMPLETED
      save
      if status == 'done'
        charge
        operations.each do |op|
          op.finish
        end
      else
        operations.each do |op|
          op.change_status "error"
        end
      end
    end
  end

  def all_operations

    all_ops = []
    operations.collect { |o| o.plan }.uniq.each do |plan|
      all_ops.concat plan.operations
    end
    all_ops

  end

end
