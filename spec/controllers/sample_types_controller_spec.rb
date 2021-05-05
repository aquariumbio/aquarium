# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleTypesController, type: :controller do
  let!(:test_user) { create(:user) }

  before do
    token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
    cookies[token_name] = test_user.remember_token
  end

  context 'create' do
    it 'create dummy should work' do
      params = {
        sample_type: {
          name: 'DummyType',
          description: 'dummy type description'
        }
      }
      post :create, params, as: :json

      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response.status).to eq(200)
      expect(response.body).not_to be_nil
      response_data = JSON.parse(response.body)
      expect(response_data).not_to have_key('errors')
      expect(response_data['name']).to eq(params['name'])
    end

    it 'yeast strain example should work' do
      params = {
        sample_type: {
          description: "A strain of yeast distinguished from others by genomic or plasmid modifications",
          name: "Yeast Strain",
          field_types: [
            {
              ftype: "sample",
              part: nil,
              choices: nil,
              preferred_operation_type_id: nil,
              parent_class: "",
              parent_id: nil,
              array: false,
              name: "Plasmid",
              preferred_field_type_id: nil,
              routing: nil,
              required: false,
              role: nil
            },
            {
              ftype: "string",
              part: nil,
              choices: "MATa,MATalpha,Diploid",
              preferred_operation_type_id: nil,
              parent_class: "",
              parent_id: nil,
              array: false,
              name: "Mating Type",
              preferred_field_type_id: nil,
              routing: nil,
              required: true,
              role: nil
            }
          ]
        }
      }
      post :create, params, as: :json

      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      # expect(response.status).to eq(200)
      expect(response.body).not_to be_nil
      response_data = JSON.parse(response.body)
      expect(response_data).not_to have_key('errors')
      expect(response_data['name']).to eq(params['name'])
    end

  end

end
