# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperationTypesController, type: :controller do

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
      inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
      user: test_user
    )
  end
  let(:dummy_item) do
    create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id)
  end

  token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym

  describe 'Tests operation types' do

    it "test for correct protocol completes without error" do
      cookies[token_name] = User.find(1).remember_token

      # this shouldn't be necessary, but item isn't saved if not touched.
      dummy_item.save

      get :random, id: io_protocol.id, num: 3

      post_data = io_protocol.as_json
      post_data[:test_operations] = JSON.parse(@response.body)
      post :test, post_data

      response_hash = JSON.parse(@response.body, symbolize_names: true)

      expect(response_hash[:error]).to be_nil
      puts response_hash[:error]
      expect(response_hash[:operations]).not_to be_nil
      response_hash[:operations].each do |op|
        assert_equal 'done', op[:status]
      end
    end

    # A protocol with some funky syntax
    let(:bad_syntax_protocol) do
      create(
        :operation_type,
        name: 'bad_syntax',
        category: 'testing',
        protocol: 'class Protocol; def main; 1=2; end; end',
        user: test_user
      )
    end

    it "test for protocol with syntax error has error" do
      cookies[token_name] = User.find(1).remember_token
      get :random, id: bad_syntax_protocol.id, num: 3

      post_data = bad_syntax_protocol.as_json
      post_data[:test_operations] = JSON.parse(@response.body)
      post :test, post_data

      response_hash = JSON.parse(@response.body, symbolize_names: true)

      expect(response_hash[:error]).to eq("testing/bad_syntax: line 1: syntax error, unexpected '=', expecting end\nclass Protocol; def main; 1=2; end; end\n                           ^")
      expect(response_hash[:operations]).to be_nil
    end

  end
end
