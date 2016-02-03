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

  def self.balance uid, bid

    rows = Account.where user_id: uid, budget_id: bid

    amounts = rows.collect { |row| 
      row.transaction_type == "credit" ? row.amount : -row.amount
    }

    amounts.inject(0) { |sum,x| sum+x }

  end

end
