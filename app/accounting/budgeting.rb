module Budgeting

  def budget_ids
    balance_sheet.collect { |row| row.budget_id }.uniq
  end

  def balance_sheet
    @balance_sheet ||= Account.where user_id: self.id
    @balance_sheet
  end

  def balance bid

    amounts = balance_sheet
      .select { |row| row.budget_id == bid }
      .collect { |row| 
        row.transaction_type == "credit" ? row.amount : -row.amount
      }

    amounts.inject { |sum,x| sum+x }

  end

  def budget_info

    budget_ids.collect { |bid| 
      {
        budget: Budget.find(bid),
        balance: balance(bid)
      }
    }

  end

end