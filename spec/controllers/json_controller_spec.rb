# typed: false
# frozen_string_literal: true

require 'rails_helper'

# see spec/models/json_query_result_spec.rb

# TODO: write tests for all of the following:
# all:
#   /json, {model: model_name, method: 'all', arguments: [], options: {offset: -1, limit: -1, reverse: false} }
# find_by_name:
#   /json, {model: model_name, method: 'find_by_name', arguments: [ object_name ]}
# find:
#  /json.json, {model: model_name, id: obj_id}
# where:
#  /json, {model: model_name, method: 'where', arguments: criteria_object, options: {offset: -1, limit: -1, reverse: false}}
# new:
#  /json, {model: model_name, method: 'new'}
RSpec.describe JsonController, type: :controller do
  let!(:test_user) { create(:user) }
  let!(:dummy_plan) { create(:plan, name: 'DummyPlan') }
  let!(:dummy_association) { create(:data_association, owner: dummy_plan, key: 'dummy', value: 'dummy_value') }

  before do
    token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
    cookies[token_name] = test_user.remember_token
  end

  context 'where' do

    it 'where should work' do
      params = {
        model: 'DataAssociation',
        method: 'where',
        arguments: { parent_id: dummy_plan.id, parent_class: dummy_plan.class },
        options: { offset: -1, limit: -1, reverse: false }
      }
      post :index, params, as: :json

      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response.body).not_to be_nil
      response_data = JSON.parse(response.body)
      expect(response_data).not_to be_empty

    end
  end

  context 'find' do
    it 'find should work' do
      params = {
        model: 'DataAssociation',
        id: dummy_association.id
      }
      post :index, params, as: :json

      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response.body).not_to be_nil
      response_data = JSON.parse(response.body)
      expect(response_data).not_to have_key('errors')
      expect(response_data['id']).to eq(dummy_association.id)
      expect(response_data['parent_id']).to eq(dummy_plan.id)
    end
  end

  context 'no method' do
    it 'should be unhappy' do
      post :index, as: :json
      expect(response.status).to eq(422)
    end
  end

  it 'returns parts of collection if object_type is collection'
end
