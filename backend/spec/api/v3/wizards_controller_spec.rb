require 'rails_helper'

RSpec.describe Api::V3::WizardsController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]

      @wizard_ids = []
    end

    # Create wizard with errors
    it "invalid_wizard" do
      post "/api/v3/wizards/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      resp = JSON.parse(response.body)
      expect(resp["errors"]["name"]).to eq ["can't be blank"]
      expect(resp["errors"]["description"]).to eq ["can't be blank"]
    end

    # CRUD tests

    # Create wizard
    it "create_wizard" do
      # wizard parameters
      params = {
        wizard: {
          "name": "new name",
          "description": "new description",
          "specification": {
            "fields": {
              "0": {
                "name": "aaa",
                "capacity": "-1"
              },
              "1": {
                "name": "bbb",
                "capacity": "10"
              },
              "2": {
                "name": "ccc",
                "capacity": "50"
              }
            }
          }
        }
      }

      # Create wizard
      post "/api/v3/wizards/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Save the id
      resp = JSON.parse(response.body)
      this_wizard = resp["wizard"]
      @wizard_ids << this_wizard["id"]
    end

    # Get wizard
    it "get_wizard" do
      # Get wizard
      get "/api/v3/wizards/#{@wizard_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      wizard = resp["wizard"]
      expect(wizard["name"]).to eq "new name"
      expect(wizard["description"]).to eq "new description"
      expect(wizard["specification"]).to eq "{\"fields\":{\"0\":{\"name\":\"aaa\",\"capacity\":\"-1\"},\"1\":{\"name\":\"bbb\",\"capacity\":\"10\"},\"2\":{\"name\":\"ccc\",\"capacity\":\"50\"}}}"
    end

    # Update wizard with errors
    it "invalid_update_wizard" do
      # Update wizard
      update_params = {
        wizard: {
        }
      }

      post "/api/v3/wizards/#{@wizard_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      errors = resp["errors"]
      expect(errors["name"]).to eq ["can't be blank"]
      expect(errors["description"]).to eq ["can't be blank"]
    end

    # Update wizard
    it "invalid_update_wizard" do
      # Update wizard
      update_params = {
        wizard: {
          "name": "update name",
          "description": "update description",
          "specification": {
            "fields": {
              "0": {
                "name": "aaa aaa",
                "capacity": "-1"
              },
              "1": {
                "name": "bbb bbb",
                "capacity": "50"
              },
              "2": {
                "name": "ccc ccc",
                "capacity": "5"
              }
            }
          }
        }
      }

      post "/api/v3/wizards/#{@wizard_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      wizard = resp["wizard"]
      expect(wizard["name"]).to eq "update name"
      expect(wizard["description"]).to eq "update description"
      expect(wizard["specification"]).to eq "{\"fields\":{\"0\":{\"name\":\"aaa aaa\",\"capacity\":\"-1\"},\"1\":{\"name\":\"bbb bbb\",\"capacity\":\"50\"},\"2\":{\"name\":\"ccc ccc\",\"capacity\":\"5\"}}}"
    end

    # Delete the wizard
    it "delete_wizards" do
      post "/api/v3/wizards/#{@wizard_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end

  end
end
