# typed: false
# frozen_string_literal: true

module Budgeting

  def budget_ids
    balance_sheet.collect(&:budget_id).uniq
  end

  def balance_sheet
    @balance_sheet ||= Account.where user_id: id
    @balance_sheet
  end

  def balance(bid)

    amounts = balance_sheet
              .select { |row| row.budget_id == bid }
              .collect do |row|
      row.transaction_type == 'credit' ? row.amount : -row.amount
    end

    amounts.inject { |sum, x| sum + x }

  end

  def budget_info

    user_budget_associations.collect do |uba|
      b = Budget.find_by(id: uba.budget_id)
      next unless b

      {
        budget: b,
        quota: uba.quota,
        spent_this_month: b.spent_this_month(uba.user_id)
      }
    end.select { |bi| bi }

  end

end
