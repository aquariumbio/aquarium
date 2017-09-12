class Account < ActiveRecord::Base

  belongs_to :user
  belongs_to :budget
  belongs_to :task
  belongs_to :job
  belongs_to :operation
  has_many :first_row_logs,  class_name: "AccountLog", foreign_key: :row1
  has_many :second_row_logs, class_name: "AccountLog", foreign_key: :row2

  attr_accessible :user_id, :budget_id, :amount, :category, :transaction_type, :description, :job_id, :operation_id, :labor_rate, :markup_rate

  validates :user,  presence: true
  validates :budget,  presence: true 
  validates :description,  presence: true   

  validates_numericality_of :amount, :greater_than_or_equal_to => 0.0
  validates_inclusion_of :transaction_type, :in => [ "credit", "debit" ]
  validates_inclusion_of :category, :in => [ nil, "materials", "labor", "overhead", "credit" ]

  after_create do |row|
    row.labor_rate = Parameter.get_float("labor rate")
    row.markup_rate = Parameter.get_float("markup rate")
    row.save
  end

  def self.total rows, markup=true
    amounts = rows.collect { |row| 
      m = markup ? (row.markup_rate+1.0) : 1.0
      if row.transaction_type == "credit" 
        -row.amount
      else
        row.amount*m
      end
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
      accounts = Account.where("? <= created_at AND created_at < ? AND user_id = ?", start_date, end_date, user.id)
    else  
      accounts = Account.where("? <= created_at && created_at < ?", start_date, end_date)
    end

    a = accounts.collect { |account| {
            user_id: account.user_id,
            budget_id: account.budget_id
          }
        }.uniq

    a.collect { |x| 

      invoice = Invoice.for(x.merge({year:year, month:month}), { status:"ready", notes: "" }) 

      {
        user: User.find(x[:user_id]),
        budget: Budget.find(x[:budget_id]),
        invoice: invoice,
        spent_materials: Account.total(invoice.rows.select { |row| row.category == "materials"}, false),
        spent_labor: Account.total(invoice.rows.select { |row| row.category == "labor" }, false),
        spent: Account.total(invoice.rows)
      }

    }

  end

end
