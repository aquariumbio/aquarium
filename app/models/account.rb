class Account < ActiveRecord::Base

  belongs_to :user
  belongs_to :budget
  belongs_to :task
  belongs_to :job

  attr_accessible :user_id, :budget_id, :amount, :category, :transaction_type, :description, :job_id, :task_id

  validates :user,  presence: true
  validates :budget,  presence: true 
  validates :description,  presence: true   

  validates_numericality_of :amount, :greater_than_or_equal_to => 0.0
  validates_inclusion_of :transaction_type, :in => [ "credit", "debit" ]
  validates_inclusion_of :category, :in => [ nil, "materials", "labor", "overhead" ]

  def self.total rows
    amounts = rows.collect { |row| 
      row.transaction_type == "credit" ? -row.amount : row.amount
    }
    amounts.inject(0) { |sum,x| sum+x }
  end

  def self.balance uid, bid
    rows = Account.where user_id: uid, budget_id: bid
    -(self.total rows)
  end

  def self.users_and_budgets year, month, user=nil

    start_date = DateTime.new(year,month).change(:offset => "-7:00")
    end_date = start_date.next_month

    if user

      a = Account.where("? <= created_at AND created_at < ? AND user_id = ?", start_date, end_date, user.id)
             .collect { |a| { 
                  user_id: a.user_id,
                  budget_id: a.budget_id
                } 
              }
             .uniq

    else  

      a = Account.where("? <= created_at && created_at < ?", start_date, end_date)
             .collect { |a| { 
                  user_id: a.user_id,
                  budget_id: a.budget_id
                } 
              }
             .uniq

    end

    a.collect { |x| {
        user: User.find(x[:user_id]),
        budget: Budget.find(x[:budget_id]),
        invoice: Invoice.for(x.merge(year:year, month:month, status:"ready", notes: ""))
      }
    }

  end

end
