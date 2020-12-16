require 'rails_helper'

RSpec.describe Api::V3::GroupsController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]

      @group_ids = []
    end

    # Create group with errors
    it "invalid_group" do
      post "/api/v3/groups/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      resp = JSON.parse(response.body)
      expect(resp["errors"]["name"]).to eq ["can't be blank"]
      expect(resp["errors"]["description"]).to eq ["can't be blank"]
    end

    # CRUD tests

    # Create group
    it "create_group" do
      # group parameters
      params = {
        group: {
          "name": "new name",
          "description": "new description"
        }
      }

      # Create group
      post "/api/v3/groups/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Save the id
      resp = JSON.parse(response.body)
      this_group = resp["group"]
      @group_ids << this_group["id"]
    end

    # Get group
    it "get_group" do
      # Get group
      get "/api/v3/groups/#{@group_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      group = resp["group"]
      expect(group["name"]).to eq "new name"
      expect(group["description"]).to eq "new description"
    end

    # Update group with errors
    it "invalid_update_group" do
      # Update group
      update_params = {
        group: {
        }
      }

      post "/api/v3/groups/#{@group_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      errors = resp["errors"]
      expect(errors["name"]).to eq ["can't be blank"]
      expect(errors["description"]).to eq ["can't be blank"]
    end

    # Update group
    it "invalid_update_group" do
      # Update group
      update_params = {
        group: {
          "name": "update name",
          "description": "update description"
        }
      }

      post "/api/v3/groups/#{@group_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      group = resp["group"]
      expect(group["name"]).to eq "update name"
      expect(group["description"]).to eq "update description"
    end

    # Delete the group
    it "delete_groups" do
      post "/api/v3/groups/#{@group_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end

  end
end
