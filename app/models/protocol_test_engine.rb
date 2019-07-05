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
    manager = Krill::Manager.new(@environment.job, true)
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
    manager = Krill::Manager.new(job, true)
    job.operations.make(role: 'input')

    manager
  rescue  Krill::KrillSyntaxError => e
    # TODO: mangle error for response
    raise KrillTestError(e)
  rescue StandardError => e
    # TODO: decide whether to mangle error
    raise KrillTestError(e)
  end

  # Loads the test code.
  #
  # @param code [Code] the test code object
  def load_test(code:)
    # TODO: this should be sandboxed
    code.load(binding: empty_binding, source_name: '(eval)')
    ProtocolTest.new(operation_type, current_user)
  rescue ScriptError, StandardError => e
    # TODO: revisit
    raise KrillTestError.new(e)
  end

  # Runs the test `setup` method.
  #
  # @param test [ProtocolTest] the test object
  def pre_test(test:)
    begin
      test.setup
    rescue SystemStackError, ScriptError, StandardError => e
      raise KrillTestError(e)
    end
    unless test.operations_present?
      raise KrillTestError(message: 'No operations after test setup')
    end
  end

  # Runs the protocol under test.
  #
  # @param test [ProtocolTest] the test object
  def run_test(test:)
    test.run
  rescue SystemStackError, ScriptError, StandardError => e
    raise KrillTestError(e)
  end

  # Runs the test `analyze` method.
  #
  # @param test [ProtocolTest] the test object
  def post_test(test:)
    test.analyze
  rescue Minitest::Analyze => e
    raise e
  rescue SystemStackError, ScriptError, StandardError => e
    raise KrillTestError(e)
  end

  def self.run(operation_type:)
    test = nil

    ActiveRecord::Base.transaction do
      test = load_test(code: operation_type.test)
      pre_test(test: test)
      run_test(test: test)
      post_test(test: test)
      raise ActiveRecord::Rollback
    end

    test
  end

end

class KrillTestError < StandardError
  def initialize(message:)
    super(message)
  end
end