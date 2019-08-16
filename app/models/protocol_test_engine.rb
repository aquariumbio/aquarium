# frozen_string_literal: true

require 'minitest'

# Controls execution of protocol tests
class ProtocolTestEngine

  # Loads the test code.
  #
  # @param code [Code] the test code object
  def self.load_test(operation_type:, user:)
    # TODO: this should be sandboxed
    operation_type.test.load(binding: empty_binding, source_name: '(eval)')
    ProtocolTest.new(operation_type, user)
  rescue SyntaxError => e
    raise KrillTestSyntaxError.new(error: e, operation_type: operation_type)
  rescue StandardError, NoMemoryError, ScriptError, SecurityError, SystemExit, SystemStackError => e
    raise KrillTestError.new(message: "Error while loading test: #{e.message}", error: e, operation_type: operation_type)
  end

  # Run the test for the given operation type.
  #
  # @param operation_type [OperationType] the operation type
  # @return [ProtocolTestBase] the execution object for the test
  def self.run(operation_type:, user:)
    test = nil
    ActiveRecord::Base.transaction do
      test = load_test(operation_type: operation_type, user: user)
      # TODO: handle runtime errors
      # TODO: allow for user test methods
      begin
        test.setup
        test.run
        test.analyze
      rescue Krill::KrillBaseError => e
        raise e
      rescue SyntaxError => e
        raise KrillTestSyntaxError.new(error: e, operation_type: operation_type)
      rescue StandardError, NoMemoryError, ScriptError, SecurityError, SystemExit, SystemStackError => e
        raise KrillTestError.new(error: e, operation_type: operation_type)
      rescue Minitest::Assertion => e
        raise KrillAssertionError.new(error: e, operation_type: operation_type)
      end
      raise ActiveRecord::Rollback
    end

    test
  end

  # Create an empty binding
  def self.empty_binding
    binding
  end
end

class KrillTestError < Krill::KrillBaseError
  def initialize(message: 'Error during test', error:, operation_type:)
    super(message: message, error: error, operation_type: operation_type)
  end
end

class KrillTestSyntaxError < Krill::KrillBaseError
  def initialize(message: 'Syntax error in test', error:, operation_type:)
    super(message: message, error: error, operation_type: operation_type)
  end
end

class KrillAssertionError < Krill::KrillBaseError
  def initialize(message: 'Assertion failure', error:, operation_type:)
    super(message: message, error: error, operation_type: operation_type)
  end
end
