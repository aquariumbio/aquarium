# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Krill::Manager do
  let!(:test_user) { create(:user) }
  let(:simple_protocol) do
    create(
      :operation_type,
      name: 'simple',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' }; end end',
      user: test_user
    )
  end
  let(:op_show_protocol) do
    create(
      :operation_type,
      name: 'op_show',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.name } end end',
      user: test_user
    )
  end

  def run_protocol(protocol:, user:, debug: true)
    operations = make_operations_list(
      operation_type: protocol,
      user_id: user.id
    )
    plans = build_plan(operations: operations, user_id: user.id)
    job = make_job(
      operation_type: protocol,
      operations: operations,
      user: user
    )
    expect(job).to be_pending
    manager = Krill::Manager.new(job.id, debug)
    expect(manager.protocol).to respond_to(:debug, :input, :jid, :show, :operations)
    expect(manager.protocol.debug).to eq(true)

    execute(operations: operations, manager: manager)

    job.reload
  end

  it 'expect simple protocol to have code' do
    # sanity check on factory
    expect(simple_protocol.protocol).not_to be_nil
    expect(simple_protocol.cost_model).not_to be_nil
    expect(simple_protocol.precondition).not_to be_nil
  end

  it 'expect simple protocol to run without error' do
    job = run_protocol(protocol: simple_protocol, user: test_user)
    expect(job).not_to be_error
    job.operations.each {|operation| expect(operation.status).to eq('done')}
    expect(job).to be_done
    expect(job.backtrace[1][:content]).to eq([{title: 'blah'}])
  end

  it 'expect  protocol w/operations ref to have code' do
    # sanity check on factory
    expect(op_show_protocol.protocol).not_to be_nil
    expect(op_show_protocol.cost_model).not_to be_nil
    expect(op_show_protocol.precondition).not_to be_nil
  end

  it 'expect protocol with operations ref in show to run without error' do
    job = run_protocol(protocol: op_show_protocol, user: test_user)
    expect(job).not_to be_error
    job.operations.each {|operation| expect(operation.status).to eq('done')}
    expect(job).to be_done
    expect(job.backtrace[1][:content]).to eq([{title: 'blah'}, {note: op_show_protocol.name}])
  end
end

def build_plan(operations:, user_id:)
  plans = []
  operations.each do |op|
    plan = Plan.new(user_id: user_id, budget_id: Budget.all.first.id)
    plan.save
    plans << plan
    pa = PlanAssociation.new(operation_id: op.id, plan_id: plan.id)
    pa.save
  end

  plans
end

def make_operations_list(operation_type:, user_id:)
  operation = operation_type.operations.create(
    status: 'pending',
    user_id: user_id
  )

  [operation]
end

def make_job(operation_type:, operations:, user:)
  job, _newops = operation_type.schedule(
    operations,
    user,
    Group.find_by_name('technicians')
  )

  job
end

def execute(operations:, manager:)
  # TODO: see ProtocolTestBase.execute
  operations.extend(Krill::OperationList)
  operations.make(role: 'input')
  operations.each(&:run)
  manager.start
  operations.each(&:reload)
end
