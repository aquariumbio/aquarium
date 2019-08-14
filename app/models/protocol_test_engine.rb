# frozen_string_literal: true

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
    line_number, message = e.message.match(/^\(eval\):(\d+): (.+)$/m).captures
    message = "#{operation_type.category}/#{operation_type.name}: line #{line_number}: #{message}".strip
    raise KrillTestSyntaxError.new(message: message, error: e)
  rescue StandardError, NoMemoryError, ScriptError, SecurityError, SystemExit, SystemStackError => e
    raise KrillTestError.new(message: "Error while loading test: #{e.message}", error: e)
  end

  # Run the test for the given operation type.
  #
  # @param operation_type [OperationType] the operation type
  # @return [ProtocolTestBase] the execution object for the test
  def self.run(operation_type:, user:)
    test = nil
    ActiveRecord::Base.transaction do
      test = load_test(operation_type: operation_type, user: user)
      test.setup
      test.run
      test.analyze
      raise ActiveRecord::Rollback
    end

    test
  end

  # Create an empty binding
  def self.empty_binding
    binding
  end
end

class KrillTestError < StandardError
  attr_reader :error

  def initialize(message:, error:)
    @error = error
    super(message)
  end
end

class KrillTestSyntaxError < StandardError
  attr_reader :error

  def initialize(message:, error:)
    @error = error
    super(message)
  end
end
