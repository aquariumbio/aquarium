# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProtocolDebugEngine do
  let!(:job_user) { create(:user) }
  let!(:debug_user) { create(:user, name: 'A Tech', login: 'a_technician') }
  let(:simple_protocol) do
    create(
      :operation_type,
      name: 'simple',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' }; end end',
      user: job_user
    )
  end
  let(:op_show_protocol) do
    create(
      :operation_type,
      name: 'op_show',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.name } end end',
      user: job_user
    )
  end
  let(:raise_protocol) do
    create(
      :operation_type,
      name: 'raise_exception',
      category: 'testing',
      protocol: 'class Protocol; def main; raise \'the_exception\' end end',
      user: job_user
    )
  end

  it 'expect singleton job of simple protocol to debug without error' do
    operation_list = make_operations_list(
      operation_type: simple_protocol,
      user_id: job_user.id
    )
    job = make_job(
      operations: operation_list,
      user: job_user
    )
    expect(job).to be_pending
    errors = debug_job(job)
    expect(job).not_to be_pending
    expect(errors).to be_empty
  end

  it 'expect job with two simple protocols to debug without error' do
    operation_list = make_operations_list(
      operation_type: simple_protocol,
      user_id: job_user.id,
      count: 2
    )
    job = make_job(
      operations: operation_list,
      user: job_user
    )
    expect(job).to be_pending
    errors = debug_job(job)
    expect(job).not_to be_pending
    expect(errors).to be_empty
  end

  it 'expect singleton job of op show protocol to debug without error' do
    operation_list = make_operations_list(
      operation_type: op_show_protocol,
      user_id: job_user.id
    )
    job = make_job(
      operations: operation_list,
      user: job_user
    )
    expect(job).to be_pending
    errors = debug_job(job)
    expect(job).not_to be_pending
    expect(errors).to be_empty
  end

  it 'expect job with two op show protocols to debug without error' do
    operation_list = make_operations_list(
      operation_type: op_show_protocol,
      user_id: job_user.id,
      count: 2
    )
    job = make_job(
      operations: operation_list,
      user: job_user
    )
    expect(job).to be_pending
    errors = debug_job(job)
    expect(job).not_to be_pending
    expect(errors).to be_empty
  end

  it 'expect singleton job of exception protocol to debug without error' do
    operation_list = make_operations_list(
      operation_type: raise_protocol,
      user_id: job_user.id
    )
    job = make_job(
      operations: operation_list,
      user: job_user
    )
    expect(job).to be_pending
    errors = debug_job(job)
    expect(job).not_to be_pending
    expect(errors).to eq(['the_exception'])
  end

  it 'expect job with two exception protocols to debug without error' do
    operation_list = make_operations_list(
      operation_type: raise_protocol,
      user_id: job_user.id,
      count: 2
    )
    job = make_job(
      operations: operation_list,
      user: job_user
    )
    expect(job).to be_pending
    errors = debug_job(job)
    expect(job).not_to be_pending
    expect(errors).to eq(['the_exception'])
  end

  it 'expect plan with non-failing protocols to debug without error' do
    simple_operation_list = make_operations_list(
      operation_type: simple_protocol,
      user_id: job_user.id,
      count: 2
    )
    show_operation_list = make_operations_list(
      operation_type: op_show_protocol,
      user_id: job_user.id,
      count: 2
    )
    operations_list = simple_operation_list + show_operation_list
    operations_list.each { |op| op.status = 'pending' }
    plan = build_plan(
      operations: operations_list,
      user_id: debug_user.id
    )
    errors = debug_plan(plan)
    expect(errors).to be_empty

  end

  def build_plan(operations:, user_id:)
    plan = Plan.new(user_id: user_id, budget_id: Budget.all.first.id)
    plan.save

    operations.each do |op|
      pa = PlanAssociation.new(operation_id: op.id, plan_id: plan.id)
      pa.save
    end

    plan
  end

  def make_operation(operation_type:, user_id:)
    operation_type.operations.create(
      status: 'pending',
      user_id: user_id
    )
  end

  def make_operations_list(operation_type:, user_id:, count: 1)
    operation_list = []
    (1..count).each do |_|
      operation = make_operation(
        operation_type: operation_type,
        user_id: user_id
      )
      operation_list << operation
    end

    operation_list
  end

  def make_job(operations:, user:)
    build_plan(operations: operations, user_id: user.id)
    Job.schedule(
      operations: operations,
      user: user
    )
  end

  def debug_job(job)
    ProtocolDebugEngine.debug_job(job: job, user_id: debug_user.id)
  end

  def debug_plan(plan)
    ProtocolDebugEngine.debug_plan(plan: plan, current_user: debug_user)
  end
end
