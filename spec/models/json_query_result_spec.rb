# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonController::JsonQueryResult do
  let!(:test_user) { create(:user) }
  let!(:test_group) { create(:group) }
  let(:dummy_sample_type) { create(:sample_type, name: 'DummySampleType') }
  let(:dummy_sample) { create(:sample, name: 'DummySample', sample_type: dummy_sample_type) }
  let(:dummy_object_type) { create(:object_type, name: 'DummyObjectType') }
  let(:io_protocol) do
    create(
      :operation_type,
      name: 'io protocol',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end;',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user
    )
  end
  let!(:dummy_item) do
    create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id)
  end
  let!(:dummy_operations) do
    operations = []
    operations.append(io_protocol.operations.create(status: 'waiting', user_id: test_user.id))
    operations.append(io_protocol.operations.create(status: 'waiting', user_id: test_user.id))
    operations.append(io_protocol.operations.create(status: 'waiting', user_id: test_user.id))
    operations.append(io_protocol.operations.create(status: 'waiting', user_id: test_user.id))

    operations
  end
  let!(:dummy_job) do
    Job.create_from(
      operations: dummy_operations,
      user: test_user,
      group: test_group
    )
  end

  it 'should fail on bad model' do
    expect { JsonController::JsonQueryResult.create_from(model: 'baad') }.to raise_error(NameError)
  end

  it 'should raise error if valid model with no method' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job') }.to raise_error('Query method expected')
  end

  it 'all should return the dummy_job' do
    jobs = JsonController::JsonQueryResult.create_from(model: 'Job', method: 'all')
    expect(jobs).not_to be_empty
    expect(jobs.last['id']).to eq(dummy_job.id)
  end

  it 'including bad association should raise error' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'all', include: 'bad') }.to raise_error('Invalid include: bad')
  end

  it 'where with no argument should raise error' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where') }.not_to raise_error
  end

  it 'include non-association method' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', arguments: 'pc >= 0') }.not_to raise_error
  end

  it 'where with no argument should raise error' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', include: 'operations') }.not_to raise_error
  end

  it 'include non-association method' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', arguments: 'pc >= 0', include: 'operations') }.not_to raise_error
  end

  it 'include non-association name with association' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', arguments: 'pc >= 0', include: %w[operations user]) }.not_to raise_error
  end

  it 'include manager query' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', arguments: 'pc >= 0', include: [{ operations: { include: :operation_type } }, :user]) }.not_to raise_error
  end

  it 'manager query should return something without crashing' do
    expect(JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', arguments: 'pc >= 0', options: { offset: -1, limit: -1, reverse: false }, include: [{ operations: { include: :operation_type } }, :user])).not_to be_nil
  end

  # it 'invoice query should not crash' do
  #   expect(AccountLog.all).not_to be_empty
  #   expect(JsonController::JsonQueryResult.create_from(model: 'AccountLog', method: 'where', arguments: { row1: [72, 73] }, options: { offset: -1, limit: -1, reverse: false }, include: 'user')).to be_empty
  #   expect(JsonController::JsonQueryResult.create_from(model: 'AccountLog', method: 'where', arguments: { row1: [59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71] }, options: { offset: -1, limit: -1, reverse: false }, include: 'user')).not_to be_empty
  # end

  it 'find query should not crash' do
    job_id = Job.last.id
    expect(JsonController::JsonQueryResult.create_from(model: 'Job', method: 'find', id: job_id)).not_to be nil

    # leaving out the method should not be an error b/c that is the way it has always been
    expect(JsonController::JsonQueryResult.create_from(model: 'Job', id: job_id)).not_to be nil
  end

end
