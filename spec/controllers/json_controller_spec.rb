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
  before do
    token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
    cookies[token_name] = User.find(1).remember_token
  end

  context 'where' do
    it 'where should work' do
      params = {
        model: 'DataAssociation',
        method: 'where',
        arguments: { parent_id: 1, parent_class: 'Plan' },
        options: { offset: -1, limit: -1, reverse: false }
      }
      post :index, params, as: :json

      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response.body).to eq('[]')
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
