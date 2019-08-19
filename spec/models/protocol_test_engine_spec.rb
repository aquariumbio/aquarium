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
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end;',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user
    )
  end
  let!(:dummy_item) do
    create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id)
  end

  it 'io protocol test should pass' do
    test = ProtocolTestEngine.run(operation_type: io_protocol, user: test_user)
    expect(test).not_to be_nil
    expect(test.methods).to include(:setup, :analyze, :run)
  end

  let(:failing_test) do
    create(
      :operation_type,
      name: 'failing test',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' }; end end',
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'not-the-output\'); end; end',
      user: test_user
    )
  end

  it 'failing assertion should result in assertion error' do
    expect { ProtocolTestEngine.run(operation_type: failing_test, user: test_user) }.to raise_error(KrillAssertionError)
  end

  let(:bad_protocol_syntax) do
    create(
      :operation_type,
      name: 'bad syntax',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' ]; end end',
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end',
      user: test_user
    )
  end

  it 'protocol with bad syntax should raise KrillSyntaxError' do
    # TODO: confirm message is syntax error
    expect { ProtocolTestEngine.run(operation_type: bad_protocol_syntax, user: test_user) }.to raise_error(Krill::KrillSyntaxError)
  end

  let(:bad_test_syntax) do
    create(
      :operation_type,
      name: 'bad test syntax',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' }; end end',
      test: 'class ProtocolTest < ProtocolTestBase; def setup; * add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end',
      user: test_user
    )
  end

  it 'test with bad syntax should raise syntax error on load' do
    expect { ProtocolTestEngine.run(operation_type: bad_test_syntax, user: test_user) }.to raise_error(KrillTestSyntaxError)
  end

  let(:raise_protocol) do
    create(
      :operation_type,
      name: 'raise_exception',
      category: 'testing',
      protocol: 'class Protocol; def main; raise \'the_exception\' end end',
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end',
      user: test_user
    )
  end

  it 'test for protocol that raises error should be able to test for it' do
    skip('not implemented correctly')
    expect { ProtocolTestEngine.run(operation_type: raise_protocol, user: test_user) }.to raise_error(Krill::KrillError)
  end

end
