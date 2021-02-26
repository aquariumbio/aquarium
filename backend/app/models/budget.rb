# budgets table
class Budget < ActiveRecord::Base
  validates :name,        presence: true
  validates :description, presence: true
  validates :contact,     presence: true
  validates :email,       presence: true
  validates :phone,       presence: true

  # Return all budgets.
  #
  # @return all budgets
  def self.find_all
    Budget.order(:name)
  end

  # Return all budgets beginning with first letterl ('*' as non-alphanumeric wildcard).
  #
  # @return all budgets beginning with first letterl ('*' as non-alphanumeric wildcard)
  def self.find_by_first_letter(l)
    if l == "*"
      sql = "select * from budgets where (name regexp '^[^a-zA-Z].*') order by name"
    else
      sql = "select * from budgets where name like '#{l}%' order by name"
    end
    Budget.find_by_sql sql
  end

  # Return a specific budget.
  #
  # @param id [Int] the id of the budget
  # @return the budgets
  def self.find_id(id)
    Budget.find_by(id: id)
  end

  # Create a budget
  #
  # @param budget [Hash] the budget
  # @option budget[:name] [String] the name
  # @option budget[:description] [String] the description
  # @option budget[:contact] [String] the contact
  # @option budget[:email] [String] the email
  # @option budget[:phone] [String] the phone
  # return the budget
  def self.create(budget)
    # Read the parameters
    name = Input.text(budget[:name])
    description = Input.text(budget[:description])
    contact = Input.text(budget[:contact])
    email = Input.text(budget[:email])
    phone = Input.text(budget[:phone])

    budget_new = Budget.new(
      name: name,
      description: description,
      contact: contact,
      email: email,
      phone: phone,
    )

    valid = budget_new.valid?
    return false, budget_new.errors if !valid

    # Save the budget if it is valid
    budget_new.save

    return budget_new, false
  end

  # Update a budget
  #
  # @param budget [Hash] the budget
  # @option budget[:name] [String] the name
  # @option budget[:description] [String] the description
  # @option budget[:contact] [String] the contact
  # @option budget[:email] [String] the email
  # @option budget[:phone] [String] the phone
  # return the budget
  def update(budget)
    # Read the parameters
    input_name = Input.text(budget[:name])
    input_description = Input.text(budget[:description])
    input_contact = Input.text(budget[:contact])
    input_email = Input.text(budget[:email])
    input_phone = Input.text(budget[:phone])

    self.name = input_name
    self.description = input_description
    self.contact = input_contact
    self.email = input_email
    self.phone = input_phone

    valid = self.valid?
    return false, self.errors if !valid

    # Save the budget if it is valid
    self.save

    return self, false
  end
end
