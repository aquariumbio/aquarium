require 'rails_helper'

RSpec.describe Api::V3::ParametersController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []
      @parameter_ids = []
      @sample_type_ids = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]

      @parameter_ids = []
    end

    # Create parameter with errors
    it "invalid_parameter" do
      post "/api/v3/parameters/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      resp = JSON.parse(response.body)
      expect(resp["errors"]["key"]).to eq ["can't be blank"]
      expect(resp["errors"]["value"]).to eq ["can't be blank"]
      expect(resp["errors"]["description"]).to eq ["can't be blank"]
    end

    # CRUD tests

    # Create parameter
    it "create_parameter" do
      # parameter parameters
      params = {
        parameter: {
          "key": "new key",
          "value": "new value",
          "description": "new desription"
        }
      }

      # Create parameter
      post "/api/v3/parameters/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Save the id
      resp = JSON.parse(response.body)
      this_parameter = resp["parameter"]
      @parameter_ids << this_parameter["id"]
    end

    # Get parameter
    it "get_parameter" do
      # Get parameter
      get "/api/v3/parameters/#{@parameter_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      parameter = resp["parameter"]
      expect(parameter["key"]).to eq "new key"
      expect(parameter["value"]).to eq "new value"
      expect(parameter["description"]).to eq "new desription"
    end

    # Update parameter with errors
    it "invalid_update_parameter" do
      # Update parameter
      update_params = {
        parameter: {
        }
      }

      post "/api/v3/parameters/#{@parameter_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      errors = resp["errors"]
      expect(errors["key"]).to eq ["can't be blank"]
      expect(errors["value"]).to eq ["can't be blank"]
      expect(errors["description"]).to eq ["can't be blank"]
    end

    # Update parameter
    it "invalid_update_parameter" do
      # Update parameter
      update_params = {
        parameter: {
          "key": "update key",
          "value": "update value",
          "description": "update description"
        }
      }

      post "/api/v3/parameters/#{@parameter_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      parameter = resp["parameter"]
      expect(parameter["key"]).to eq "update key"
      expect(parameter["value"]).to eq "update value"
      expect(parameter["description"]).to eq "update description"
    end

    # Delete the parameter
    it "delete_parameters" do
      post "/api/v3/parameters/#{@parameter_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end

  end
end
