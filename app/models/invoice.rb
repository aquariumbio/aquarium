# frozen_string_literal: true

class Invoice < ApplicationRecord

  attr_accessible :budget_id, :month, :user_id, :year, :status, :notes

  validates :status, inclusion: { in: %w[ready approval_requested reconciled] }

  belongs_to :user
  belongs_to :budget

  def self.for(x, y = {})
    invoices = Invoice.where(x)
    if invoices.empty?
      i = Invoice.new(x.merge(y))
      i.save
      i
    else
      invoices[0]
    end
  end

  def rows
    start_date = DateTime.new(year, month).change(offset: '-7:00')
    end_date = start_date.next_month
    Account.includes(first_row_logs: :user, second_row_logs: :user)
           .where(user_id: user_id, budget_id: budget_id)
           .where('? <= created_at AND created_at < ?', start_date, end_date)

  end

  def in_progress
    Date.today < DateTime.new(year, month).end_of_month
  end

end
