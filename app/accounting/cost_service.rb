module CostService

  def cost(job, status)
    cost_model job.name, status
  end

  def description(_job, status)
    "#{name}: #{status}"
  end

  def charge(job, status)

    (cost job, status).each do |category, amount|

      next unless amount > 0 && budget_id

      row = Account.new(
        user_id: user.id,
        category: category.to_s,
        amount: amount,
        budget_id: budget.id,
        description: description(job, status),
        task_id: id,
        job_id: job.id,
        transaction_type: 'debit'
      )

      row.save

      raise "Could not charge account for #{description job, status}: #{row.errors.full_messages.join(',')}" if row.errors.any?

      row

    end

  end

end
