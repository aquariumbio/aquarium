# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestController, type: :controller do
  let!(:test_user) { create(:user) }
  let(:dummy_sample_type) { create(:sample_type, name: 'DummySampleType') }
  let(:dummy_sample) { create(:sample, name: 'DummySample', sample_type: dummy_sample_type) }
  let(:dummy_object_type) { create(:object_type, name: 'DummyObjectType') }
  let!(:dummy_item) do
    create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id)
  end

  token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym

  let(:io_protocol) do
    create(
      :operation_type,
      name: 'io protocol',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user
    )
  end
  it 'test for basic protocol completes without error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: io_protocol.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('ok')
    expect(response_hash[:error]).to be_nil
    puts response_hash[:error]

  end

  let(:bad_syntax_protocol) do
    create(
      :operation_type,
      name: 'bad_syntax',
      category: 'testing',
      protocol: 'class Protocol; def main; 1=2; end; end',
      user: test_user
    )
  end

  it 'test for bad_syntax protocol should have error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: bad_syntax_protocol.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('protocol_syntax_error')
    expect(response_hash[:backtrace]).to be_empty
    expect(response_hash[:exception_backtrace]).to be_empty
    expect(response_hash[:log]).to be_empty
    expect(response_hash[:message]).to eq("testing/bad_syntax: line 1: syntax error, unexpected '=', expecting end\nclass Protocol; def main; 1=2; end; end\n                           ^")
  end

  let(:exit_protocol) do
    create(
      :operation_type,
      name: 'system_exit',
      category: 'testing',
      protocol: 'class Protocol; def main; exit; end; end',
      user: test_user
    )
  end
  it 'test for system_exit protocol should have error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: exit_protocol.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('protocol_error')
    expect(response_hash[:backtrace]).to be_empty
    expect(response_hash[:exception_backtrace]).to eq(["testing/system_exit: line 1: in `exit'", "testing/system_exit: line 1: in `main'"])
    expect(response_hash[:log]).to be_empty
    expect(response_hash[:message]).to eq('exit')
  end

  let(:failing_test_protocol) do
    create(
      :operation_type,
      name: 'failing test protocol',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user,
      test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; flunk(\'should fail\'); end; end;'
    )
  end
  it 'test with failing assertion should have an error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: failing_test_protocol.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('assertion_failure')
    expect(response_hash[:backtrace]).to be_empty
    expect(response_hash[:exception_backtrace]).to eq(["testing/failing test protocol: line 1: in `analyze'"])
    expect(response_hash[:log]).to be_empty
    expect(response_hash[:message]).to eq('Assertion failed: should fail')
  end

  let(:bad_test_protocol) do
    create(
      :operation_type,
      name: 'bad test protocol',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user,
      test: 'class ProtocolTest < ProtocolTestBase; def setup; exit; add_random_operations(1); end; def analyze; flunk(\'should fail\'); end; end;'
    )
  end

  it 'test with exit should have an error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: bad_test_protocol.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('test_error')
    expect(response_hash[:backtrace]).to be_empty
    expect(response_hash[:exception_backtrace]).to eq(["testing/bad test protocol: line 1: in `exit'", "testing/bad test protocol: line 1: in `setup'"])
    expect(response_hash[:log]).to be_empty
    expect(response_hash[:message]).to eq('exit')
  end

  let(:bad_syntax_test_protocol) do
    create(
      :operation_type,
      name: 'bad syntax test protocol',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user,
      test: 'class ProtocolTest < ProtocolTestBase; def setup; 1=2; add_random_operations(1); end; def analyze; flunk(\'should fail\'); end; end;'
    )
  end

  it 'test with bad syntax should have an error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: bad_syntax_test_protocol.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('test_syntax_error')
    expect(response_hash[:backtrace]).to be_empty
    expect(response_hash[:exception_backtrace]).to be_empty
    expect(response_hash[:log]).to be_empty
    expect(response_hash[:message]).to eq("testing/bad syntax test protocol: line 1: syntax error, unexpected '=', expecting end\n...ProtocolTestBase; def setup; 1=2; add_random_operations(1); ...\n...                              ^")
  end

  let(:bad_name_protocol_test) do
    create(
      :operation_type,
      name: 'bad name protocol test',
      category: 'testing',
      protocol: 'class Protocol;     def main;        show do;          title \'blah\';          note operations.first.input(\'blah\').item.id;        end;      end;    end',
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user,
      test: 'class ProtocolTest < ProtocolTestBase;      def setup;          adffd;          add_random_operations(3);      end;      def analyze;          log(\'Hello from Nemo\');          assert_equal(@backtrace.last[:operation], \'complete\');      end;        end'
    )
  end

  it 'test with bad variable name should have a test error' do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: bad_name_protocol_test.id

    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('test_error')
    expect(response_hash[:backtrace]).to be_empty
    expect(response_hash[:exception_backtrace]).to eq(["testing/bad name protocol test: line 1: in `setup'"])
    expect(response_hash[:log]).to be_empty
    expect(response_hash[:message]).to eq("undefined local variable or method `adffd'")
  end

end
