module CostService

  def cost job, status
    cost_model job.name, status
  end

  def description job, status
    "#{self.name}: #{status}"
  end

  def charge job, status

    (cost job, status).each do |category,amount|

      if amount > 0 && self.budget_id

        row = Account.new(
          user_id: self.user.id, 
          category: category.to_s, 
          amount: amount, 
          budget_id: self.budget.id,
          description: self.description(job, status),
          task_id: self.id,
          job_id: job.id,
          transaction_type: "debit"
        )

        row.save

        if row.errors.any?
          raise "Could not charge account for #{self.description job, status}: #{row.errors.full_messages.join(',')}" 
        end

      end

    end

  end

end
