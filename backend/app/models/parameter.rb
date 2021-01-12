# frozen_string_literal: true

# parameters table
class Parameter < ActiveRecord::Base

  validates :key,         presence: true
  validates :value,       presence: true
  validates :description, presence: true

  # Return all parameters.
  #
  # @return all parameters
  def self.find_all
    Parameter.order(created_at: :desc)
  end

  # Return a specific parameter.
  #
  # @param id [Int] the id of the parameter
  # @return the parameters
  def self.find_id(id)
    Parameter.find_by(id: id)
  end

  # Create an parameter
  #
  # @param parameter [Hash] the parameter
  # @option parameter[:key] [String] the key
  # @option parameter[:value] [String] the value
  # @option parameter[:description] [String] description - interpreted as Boolen
  # return the parameter
  def self.create(parameter)
    # Read the parameters
    key = Input.text(parameter[:key])
    value = Input.text(parameter[:value])
    description = Input.text(parameter[:description])

    parameter_new = Parameter.new(
      key: key,
      value: value,
      description: description
    )

    valid = parameter_new.valid?
    return false, parameter_new.errors if !valid

    # Save the parameter if it is valid
    parameter_new.save

    return parameter_new, false
  end

  # Update an parameter
  #
  # @param parameter [Hash] the parameter
  # @option parameter[:key] [String] the key
  # @option parameter[:value] [String] the value
  # @option parameter[:description] [String] description - interpreted as Boolen
  # return the parameter
  def update(parameter)
    # Read the parameters
    input_title = Input.text(parameter[:key])
    input_message = Input.text(parameter[:value])
    input_active = Input.text(parameter[:description])

    self.key = input_title
    self.value = input_message
    self.description = input_active

    valid = self.valid?
    return false, self.errors if !valid

    # Save the parameter if it is valid
    self.save

    return self, false
  end

end
