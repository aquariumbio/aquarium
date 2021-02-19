# groups table
class Group < ActiveRecord::Base
  validates :name,        presence: true
  validates :description, presence: true

  # Return all groups.
  #
  # @return all groups
  def self.find_all
    Group.order(:name)
  end

  # Return all groups beginning with first letterl ('*' as non-alphanumeric wildcard).
  #
  # @return all groups beginning with first letterl ('*' as non-alphanumeric wildcard)
  def self.find_by_first_letter(l)
    if l == "*"
      sql = "select * from groups where (name regexp '^[^a-zA-Z].*') order by name"
    else
      sql = "select * from groups where name like '#{l}%' order by name"
    end
    Group.find_by_sql sql
  end

  # Return a specific group.
  #
  # @param id [Int] the id of the group
  # @return the groups
  def self.find_id(id)
    Group.find_by(id: id)
  end

  # Create a group
  #
  # @param group [Hash] the group
  # @option group[:name] [String] the name
  # @option group[:description] [String] the description
  # return the group
  def self.create(group)
    # Read the parameters
    name = Input.text(group[:name])
    description = Input.text(group[:description])

    group_new = Group.new(
      name: name,
      description: description
    )

    valid = group_new.valid?
    return false, group_new.errors if !valid

    # Save the group if it is valid
    group_new.save

    return group_new, false
  end

  # Update a group
  #
  # @param group [Hash] the group
  # @option group[:name] [String] the name
  # @option group[:description] [String] the description
  # return the group
  def update(group)
    # Read the parameters
    input_name = Input.text(group[:name])
    input_description = Input.text(group[:description])

    self.name = input_name
    self.description = input_description

    valid = self.valid?
    return false, self.errors if !valid

    # Save the group if it is valid
    self.save

    return self, false
  end
end
