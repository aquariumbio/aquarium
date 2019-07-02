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
    manager = Krill::Manager.new(@environment.job.id, true)
    @environment.operations.make(role: 'input')
  end

  def make_job(operation_type:, operations:, user:)
    job, _newops = operation_type.schedule(
      operations,
      user,
      Group.find_by_name('technicians')
    )

    job
  end

  #### code based on TestController

  def load_job(job:)
    manager = Krill::Manager.new(job.id, true)
    job.operations.make(role: 'input')

    manager
  rescue  Krill::KrillSyntaxError => e
    # TODO: mangle error for response
    raise KrillTestError(e)
  rescue StandardError => e
    # TODO: decide whether to mangle error
    raise KrillTestError(e)
  end

  def pre_test(test:)
  end

  def run_test(test:)
  end

  def post_test(test:)
  end


end
