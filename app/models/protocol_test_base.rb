# frozen_string_literal: true

class ProtocolTestBase

  include MiniTest::Assertions

  attr_accessor :assertions, :logs, :backtrace, :job, :plans

  def initialize(operation_type, current_user)
    @assertions = 0
    @operation_type = operation_type
    # TODO: could this be initialized as a Krill::OperationsList ??
    @operations = []
    @current_user = current_user
    @job = nil
    @plans = []
  end

  def log(msg)
    @logs ||= []
    @logs << msg
  end

  def add_random_operations(num)
    @operations = @operation_type.random(num)
  end

  def add_operation
    op = @operation_type
         .operations
         .create(status: 'pending', user_id: @current_user.id)
    @operations ||= []
    @operations << op
    op
  end

  def add_operations(operations)
    operations.each(&:save)
    @operations.concat(operations)
  end

  def build_plans(operations:, user:)
    plans = []
    operations.each do |operation|
      plans << build_plan(operation: operation, user: user)
    end

    plans
  end

  def build_plan(operation:, user:)
    plan = Plan.new(user_id: user.id, budget_id: Budget.all.first.id)
    plan.save
    pa = PlanAssociation.new(operation_id: operation.id, plan_id: plan.id)
    pa.save

    plan
  end

  def execute(job:)
    manager = Krill::DebugManager.new(job)
    # TODO: could this be initialize?
    @operations.extend(Krill::OperationList)
    @operations.make(role: 'input')
    @operations.each(&:run)
    manager.start
    @operations.each(&:reload)
  end

  def run
    @plan = build_plans(operations: @operations, user: @current_user)
    @job = Job.schedule(
      operations: @operations,
      user: @current_user
    )
    execute(job: @job)
    @backtrace = @job.reload.backtrace
  end

  def operations_present?
    @operations.present?
  end

  def error?
    @job.error?
  end

  def error_message
    @job.error_message
  end

  def error_backtrace
    @job.error_backtrace
  end

  def find_display_by_title(title)
    displays_with_content.find { |d| d[:content][0][:title] == title }
  end

  def displays_with_content
    displays.select { |d| d[:content].present? && d[:content][0].is_a?(Hash) }
  end

  def displays
    @backtrace.select { |b| b[:operation] == 'display' }
  end
end
