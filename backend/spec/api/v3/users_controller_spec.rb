require 'rails_helper'

RSpec.describe Api::V3::UsersController, type: :request do
  describe 'api' do

    # SIGN IN USERS
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

    # INVALID GET USERS AND PERMISSIONS
    it "invalid_get_users_and_permissions" do
      # BAD TOKEN
      get "/api/v3/users/permissions"
      expect(response).to have_http_status 401
    end

    # FORBIDDEN GET USERS AND PERMISSIONS
    it "forbidden_get_users_and_permissions" do
      # NOT ADMIN
      get "/api/v3/users/permissions?token=#{@token_2[0]}"
      expect(response).to have_http_status 403

      # ADMIN BUT RETIRED
      get "/api/v3/users/permissions?token=#{@token_3[0]}"
      expect(response).to have_http_status 403
    end

    # GET USERS AND PERMISSIONS
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

    # INVALID CHANGE PERMISSION FOR USE
    it "invalid_get_users_and_permissions" do
      # BAD TOKEN
      post "/api/v3/users/permissions/update?user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 401
    end

    # FORBIDDEN CHANGE PERMISSION FOR USE
    it "forbidden_get_users_and_permissions" do
      # NOT ADMIN
      post "/api/v3/users/permissions/update?token=#{@token_2[0]}&user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 403

      # ADMIN BUT RETIRED
      post "/api/v3/users/permissions/update?token=#{@token_3[0]}&user_id=2&permission_id=4&value=true"
      expect(response).to have_http_status 403
    end

    # CHANGE PERMISSION FOR USER
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

    # CANNOT CHANGE ADMIN / RETIRED FOR SELF
    it "cannot_change_self_permission_admin_retired" do
      post "/api/v3/users/permissions/update?token=#{@token_1[0]}&user_id=1&permission_id=1"
      expect(response).to have_http_status 403

      post "/api/v3/users/permissions/update?token=#{@token_1[0]}&user_id=1&permission_id=6"
      expect(response).to have_http_status 403
    end

  end
end
