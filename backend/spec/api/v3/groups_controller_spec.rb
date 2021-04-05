require 'rails_helper'

RSpec.describe Api::V3::GroupsController, type: :request do
  describe 'api' do
    # Sign in users
    before :all do
      @create_url = "/api/v3/token/create"
      @token_1 = []

      post "#{@create_url}?login=user_admin&password=aquarium123"
      response_body = JSON.parse(response.body)
      @token_1 << response_body["token"]

      @group_ids = []
    end

    # Create group with errors
    it "invalid_group" do
      post "/api/v3/groups/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      response_body = JSON.parse(response.body)
      expect(response_body["errors"]["name"]).to eq ["can't be blank"]
      expect(response_body["errors"]["description"]).to eq ["can't be blank"]
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
      response_body = JSON.parse(response.body)
      this_group = response_body["group"]
      @group_ids << this_group["id"]
    end

    # Get group
    it "get_group" do
      # Get group
      get "/api/v3/groups/#{@group_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      response_body = JSON.parse(response.body)

      # Check
      group = response_body["group"]
      expect(group["name"]).to eq "new name"
      expect(group["description"]).to eq "new description"
    end

    # Get groups by fist letter
    it "get_groups_first_letter" do
      get "/api/v3/groups?token=#{@token_1[0]}&letter=n"
      expect(response).to have_http_status 200

      # Check
      response_body = JSON.parse(response.body)
      groups = response_body["groups"]
      expect(groups[0]["name"]).to eq "new name"
    end

    # Get groups by fist letter none
    it "get_groups_first_letter_none" do
      get "/api/v3/groups?token=#{@token_1[0]}&letter=a"
      expect(response).to have_http_status 200

      # Check no groups that start with "a"
      response_body = JSON.parse(response.body)
      groups = response_body["groups"]
      expect(groups).to eq []
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
      response_body = JSON.parse(response.body)

      # Check
      errors = response_body["errors"]
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
      response_body = JSON.parse(response.body)

      # Check
      group = response_body["group"]
      expect(group["name"]).to eq "update name"
      expect(group["description"]).to eq "update description"
    end

    # create membership
    it "create_membership" do
      # membership parameters
      params = {
        user_id: 1
      }

      post "/api/v3/groups/#{@group_ids[0]}/create_membership?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      membership = resp["membership"]
      expect(membership["group_id"]).to eq @group_ids[0]
      expect(membership["user_id"]).to eq 1
    end

    # get user groups
    it "get_user_groups" do
      get "/api/v3/users/1/groups?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      group = resp["groups"][0]
      expect(group["name"]).to eq "update name"
      expect(group["description"]).to eq "update description"
    end

    # delete membership
    it "delete_membership" do
      post "/api/v3/groups/#{@group_ids[0]}/delete_membership/1?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      get "/api/v3/users/1/groups?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      expect(resp["groups"]).to eq []
    end

    # Delete the group
    it "delete_groups" do
      post "/api/v3/groups/#{@group_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end
  end
end
