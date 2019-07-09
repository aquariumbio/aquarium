# frozen_string_literal: true

# Controls execution of protocol tests

class ProtocolTestEngine
  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def build_plans
    plans = []
    @environment.operations do |operation|
      plans << build_plan(operation: operation, user_id: @environment.current_user)
    end

    plans
  end

  def build_plan(operation:, user_id:)
    plan = Plan.new(user_id: user_id, budget_id: Budget.all.first.id)
    plan.save
    pa = PlanAssociation.new(operation_id: operation.id, plan_id: plan.id)
    pa.save

    plan
  end

  def execute
    plans = build_plans
    @environment.job = make_job(
      operation_type: @environment.operation_type,
      operations: @environment.operations,
      user: @environment.current_user
    )
    manager = load
    manager.start
    # reload backtrace???
  end

  def load
    manager = Krill::DebugManager.new(@environment.job)
    @environment.operations.make(role: 'input')
  end

  def make_job(operation_type:, operations:, user:)
    operations.extend(Krill::OperationList)
    job, _newops = operation_type.schedule(
      operations,
      user,
      Group.find_by_name('technicians')
    )

    job
  end

  #### code based on TestController

  def load_job(job:)
    manager = Krill::DebugManager.new(job)
    job.operations.make(role: 'input')

    manager
  end

  # Loads the test code.
  #
  # @param code [Code] the test code object
  def self.load_test(operation_type:, user:)
    # TODO: this should be sandboxed
    operation_type.test.load(binding: empty_binding, source_name: '(eval)')
    ProtocolTest.new(operation_type, user)
  rescue ScriptError, StandardError => e
    # TODO: revisit
    raise KrillTestError.new(message: "Error while loading test: #{e.message}", error: e)
  end

  # Runs the test `setup` method.
  #
  # @param test [ProtocolTest] the test object
  def self.pre_test(test:)
    begin
      test.setup
    rescue ScriptError => e
      message = if e.message.match(/^\(eval\):\d+: .+$/)
                  line_number, message = e.message.match(
                    /^\(eval\):(\d+): (.+)$/
                  ).captures
                  "Test line #{line_number}: #{message}"
                else
                  "Error during setup: #{e.class} #{e.message}"
                end
      raise KrillTestError.new(
        message: message,
        error_type: 'test_error',
        error: e
      )
    rescue SystemStackError, StandardError => e
      raise KrillTestError.new(message: 'Error in setup', error: e)
    end
    raise KrillTestError.new(message: 'No operations after test setup') unless test.operations_present?
  end

  # Runs the protocol under test.
  #
  # @param test [ProtocolTest] the test object
  def self.run_test(test:)
    test.run
  rescue ScriptError => e
    message = if e.message.match(/^\(eval\):\d+: .+$/)
                line_number, message = e.message.match(
                  /^\(eval\):(\d+): (.+)$/
                ).captures
                "Test line #{line_number}: #{message}"
              else
                "Error while running protocol: #{e.class} #{e.message}"
              end
    raise KrillTestError.new(
      message: message,
      error_type: 'test_error',
      error: e
    )
  rescue Krill::KrillError => e
    raise e
  rescue SystemStackError, StandardError => e
    raise KrillTestError.new(message: 'Error running protocol', error: e)
  end

  # Runs the test `analyze` method.
  #
  # @param test [ProtocolTest] the test object
  def self.post_test(test:)
    test.analyze
  rescue Minitest::Analyze => e
    raise e
  rescue ScriptError => e
    message = if e.message.match(/^\(eval\):\d+: .+$/)
                line_number, message = e.message.match(
                  /^\(eval\):(\d+): (.+)$/
                ).captures
                "Test line #{line_number}: #{message}"
              else
                "Error during analysis: #{e.class} #{e.message}"
              end
    raise KrillTestError.new(
      message: message,
      error_type: 'test_error',
      error: e
    )
  rescue SystemStackError, StandardError => e
    raise KrillTestError(e)
  end

  # Run the test for the given operation type.
  #
  # @param operation_type [OperationType] the operation type
  # @return [ProtocolTestBase] the execution object for the test
  def self.run(operation_type:, user:)
    test = nil
    ActiveRecord::Base.transaction do
      test = load_test(operation_type: operation_type, user: user)
      pre_test(test: test)
      run_test(test: test)
      post_test(test: test)
      raise ActiveRecord::Rollback
    end

    test
  end

  private

  # TODO: decide what to do with rest

  # Creates an `AqResponse` object for an error that occur in a test.
  # Filters backtrace to include errors that occur within an `(eval)`.
  #
  # @param error [StandardError, ScriptError, SystemStackError] the exception object
  # @return [AqResponse] object with error message, and backtrace.
  def handle_error(error:, phase_name: nil, logs: [])
    resp = AqResponse.new
    error_trace = filter_backtrace(backtrace: error.backtrace)
                  .map { |message| translate_trace(message: message) }
    error_message = if error_trace[-1].present?
                      "Error in #{error_trace[-1]}: #{error}"
                    elsif error.is_a?(ScriptError) && error.message.match(/^\(eval\):\d+: .+$/)
                      line_number, message = error.message.match(
                        /^\(eval\):(\d+): (.+)$/
                      ).captures
                      "Test line #{line_number}: #{message}"
                    elsif phase_name.present?
                      "Error during #{phase_name}: #{error.message}"
                    else
                      "Error #{error.class} #{error.message}"
                    end
    resp.error(error_message)
        .more(
          error_type: 'test_error',
          exception_backtrace: error_trace,
          backtrace: [], log: logs
        )

    resp
  end

  # Filters the given backtrace for error messages that occur within an `(eval)`.
  #
  # @param backtrace [Array<String>] the backtrace to filter
  # @return [Array<String>] the filtered backtrace
  def filter_backtrace(backtrace:)
    backtrace.reject { |msg| msg.match(/^\(eval\):\d+:in `.+'$/).nil? }.uniq
  end

  # Translates an error message of the form
  #   (eval):10:in `method'
  # to a message with just the method name and line number.
  #
  # @param message [String] the error message matching `eval` error pattern
  # @return [String] object containing the method name and line number
  def translate_trace(message:)
    line_number, method = message.match(/^\(eval\):(\d+):in `(.+)'$/).captures

    "`#{method}` (line #{line_number})"
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
