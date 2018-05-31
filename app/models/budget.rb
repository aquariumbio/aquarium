

class Budget < ActiveRecord::Base

  has_many :user_budget_associations, dependent: :destroy

  attr_accessible :contact, :name, :overhead, :description, :email, :phone

  validates :name, presence: true
  validates :email,  presence: true
  validates :phone,  presence: true
  validates :contact, presence: true
  validates :description, presence: true

  # validates_numericality_of :overhead, :greater_than_or_equal_to => 0.0, :less_than => 1.0

  def spent(user_id)
    rows = Account.where(budget_id: id, user_id: user_id)
    Account.total rows
  end

  def spent_this_month(user_id)
    start = Date.today.beginning_of_month
    rows = Account.where('created_at >= ? AND budget_id = ? AND user_id = ?', start, id, user_id)
    Account.total rows
  end

end
