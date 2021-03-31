# frozen_string_literal: true

# wizards table
class Wizard < ActiveRecord::Base

  validates :name,        presence: true
  validates :description, presence: true

  # Return all wizards.
  #
  # @return all wizards
  def self.find_all
    Wizard.order(:name)
  end

  # Return all wizards beginning with first letter l ('*' as non-alphanumeric wildcard).
  #
  # @return all wizards beginning with first letter l ('*' as non-alphanumeric wildcard)
  def self.find_by_first_letter(l)
    if l == "*"
      sql = "select * from wizards where (name regexp '^[^a-zA-Z].*') order by name"
    else
      sql = "select * from wizards where name like '#{l}%' order by name"
    end
    Wizard.find_by_sql sql
  end

  # Return a specific wizard.
  #
  # @param id [Int] the id of the wizard
  # @return the wizards
  def self.find_id(id)
    Wizard.find_by(id: id)
  end

  # Create a wizard
  #
  # @param wizard [Hash] the wizard
  # @option wizard[:name] [String] the name
  # @option wizard[:description] [String] the description
  # @option wizard[:specification] [String] the specification
  # return the wizard
  def self.create_from(wizard)
    # Read the parameters
    name = Input.text(wizard[:name])
    description = Input.text(wizard[:description])
    specification = wizard[:specification].to_json

    wizard_new = Wizard.new(
      name: name,
      description: description,
      specification: specification
    )

    valid = wizard_new.valid?
    return false, wizard_new.errors if !valid

    # Save the wizard if it is valid
    wizard_new.save

    return wizard_new, false
  end

  # Update a wizard
  #
  # @param wizard [Hash] the wizard
  # @option wizard[:name] [String] the name
  # @option wizard[:description] [String] the description
  # @option wizard[:specification] [String] the specification
  # return the wizard
  def update(wizard)
    # Read the parameters
    input_name = Input.text(wizard[:name])
    input_description = Input.text(wizard[:description])
    input_specification = wizard[:specification].to_json

    self.name = input_name
    self.description = input_description
    self.specification = input_specification

    valid = self.valid?
    return false, self.errors if !valid

    # Save the wizard if it is valid
    self.save

    return self, false
  end
end
