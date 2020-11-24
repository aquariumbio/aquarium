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

  end
end
