# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProtocolTestEngine do
  let!(:test_user) { create(:user) }
  let(:dummy_sample_type) { create(:sample_type, name: 'DummySampleType') }
  let(:dummy_sample) { create(:sample, name: 'DummySample', sample_type: dummy_sample_type) }
  let(:dummy_object_type) { create(:object_type, name: 'DummyObjectType') }
  let(:io_protocol) do
    create(
      :operation_type,
      name: 'io protocol',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(3); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end;',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user
    )
  end
  let(:dummy_item) do
    create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id)
  end

  it 'io protocol test should pass' do
    test = ProtocolTestEngine.run(operation_type: io_protocol, user: test_user)
    expect(test).to be_nil
  end

end
