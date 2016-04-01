class Invoice < ActiveRecord::Base

  attr_accessible :budget_id, :month, :user_id, :year, :status, :notes

  validates_inclusion_of :status, :in => [ "ready", "approval_requested", "reconciled" ]  

  belongs_to :user
  belongs_to :budget

  def self.for x
    invoices = Invoice.where(x)
    if invoices.length == 0
      i = Invoice.new(x)
      i.save
      i
    else 
      invoices[0]
    end
  end

  def rows
    start_date = DateTime.new(year,month)
    end_date = start_date.next_month        
    Account.where("user_id = ? AND budget_id = ? AND ? <= created_at AND created_at < ?",
      user_id, budget_id, start_date, end_date)  
  end

  def in_progress
    Date.today < DateTime.new(year,month).end_of_month 
  end

end
