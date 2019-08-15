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
  it "test for basic protocol completes without error" do
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

  it "test for basic protocol completes without error" do
    cookies[token_name] = User.find(1).remember_token

    get :run, id: bad_syntax_protocol.id
    
    response_hash = JSON.parse(@response.body, symbolize_names: true)

    expect(response_hash[:result]).to eq('error')
    expect(response_hash[:error_type]).to eq('protocol_syntax_error')
    expect(response_hash[:error]).to be_nil
    puts response_hash[:error]

  end

end