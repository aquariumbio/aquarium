require 'rails_helper'

RSpec.describe Api::V3::UsersController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []
      @token_2 = []
      @token_3 = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]

      post "/api/v3/token/create?login=user_2&password=password"
      resp = JSON.parse(response.body)
      @token_2 << resp["token"]

      post "/api/v3/token/create?login=user_3&password=password"
      resp = JSON.parse(response.body)
      @token_3 << resp["token"]

      @user_ids = []
    end

    # Invalid get users and permissions
    it "invalid_get_users_and_permissions" do
      # Bad token
      get "/api/v3/users/permissions"
      expect(response).to have_http_status 401
    end

    # Forbidden get users and permissions
    it "forbidden_get_users_and_permissions" do
      # Not admin
      get "/api/v3/users/permissions?token=#{@token_2[0]}"
      expect(response).to have_http_status 403

      # Admin but retired
      get "/api/v3/users/permissions?token=#{@token_3[0]}"
      expect(response).to have_http_status 403
    end

    # Get users and permissions
    it "get_users_and_permissions" do
      get "/api/v3/users/permissions?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      get "/api/v3/users/permissions?token=#{@token_1[0]}&show=[1,2]"
      expect(response).to have_http_status 200

      get "/api/v3/users/permissions?token=#{@token_1[0]}&sort=name"
      expect(response).to have_http_status 200

      get "/api/v3/users/permissions?token=#{@token_1[0]}&sort=permission.admin"
      expect(response).to have_http_status 200
    end

    # Invalid change permission for use
    it "invalid_get_users_and_permissions" do
      # Bad token
      post "/api/v3/users/permissions/update?user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 401
    end

    # Forbidden change permission for use
    it "forbidden_get_users_and_permissions" do
      # Not admin
      post "/api/v3/users/permissions/update?token=#{@token_2[0]}&user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 403

      # Admin but retired
      post "/api/v3/users/permissions/update?token=#{@token_3[0]}&user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 403
    end

    # Change permission for user
    it "change_permission" do
      post "/api/v3/users/permissions/update?token=#{@token_1[0]}&user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      expect(resp["user"]["permission_ids"].index('.4.')).not_to eq(nil)

      post "/api/v3/users/permissions/update?token=#{@token_1[0]}&user_id=2&permission_id=4"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      expect(resp["user"]["permission_ids"].index('.4.')).to eq(nil)
    end

    # Cannot change admin / retired for self
    it "cannot_change_self_permission_admin_retired" do
      post "/api/v3/users/permissions/update?token=#{@token_1[0]}&user_id=1&permission_id=1"
      expect(response).to have_http_status 403

      post "/api/v3/users/permissions/update?token=#{@token_1[0]}&user_id=1&permission_id=6"
      expect(response).to have_http_status 403
    end

    # Invalid get users
    it "invalid_get_users" do
      # Bad token
      get "/api/v3/users"
      expect(response).to have_http_status 401
    end

    # Forbidden get users
    it "forbidden_get_users" do
      # Not admin
      get "/api/v3/users?token=#{@token_2[0]}"
      expect(response).to have_http_status 403

      # Admin but retired
      get "/api/v3/users?token=#{@token_3[0]}"
      expect(response).to have_http_status 403
    end

    # Get users
    it "get_users" do
      get "/api/v3/users?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end

    # Create user - errors
    it "create_user_errors" do
      # user parameters
      params = {
        user: {
          "name": "  ",
          "login": "  ",
          "password": "a 1"
        }
      }
      post "/api/v3/users/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)

      # Check errors
      errors = resp["errors"]
      expect(errors["name"]).to eq [ "can't be blank" ]
      expect(errors["login"]).to eq [ "can't be blank" ]
      expect(errors["password"]).to eq [ "password must be at least 10 characters", "passsword cannot contain spaces or invisible characters" ]
    end

    # Create user
    it "create_user" do
      # user parameters
      params = {
        user: {
          "name": " abc  123 ",
          "login": " abc123 ",
          "password": "password123"
        }
      }
      post "/api/v3/users/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      resp = JSON.parse(response.body)

      @user_ids << resp["user"]["id"]
    end

    # Invalid get user
    it "invalid_get_user" do
      # Bad token
      get "/api/v3/users/#{@user_ids[0]}"
      expect(response).to have_http_status 401
    end

    # Forbidden get user
    it "forbidden_get_user" do
      # Not admin
      get "/api/v3/users/#{@user_ids[0]}?token=#{@token_2[0]}"
      expect(response).to have_http_status 403

      # Admin but retired
      get "/api/v3/users/#{@user_ids[0]}?token=#{@token_3[0]}"
      expect(response).to have_http_status 403
    end

    # get user
    it "get_user" do
      get "/api/v3/users/#{@user_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end

  end
end
