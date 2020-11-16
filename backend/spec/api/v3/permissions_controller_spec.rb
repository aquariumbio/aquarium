require 'rails_helper'

RSpec.describe Api::V3::PermissionsController, type: :request do
  describe 'api' do

    # INITIALIZE AND SIGN IN USERS
    before :all do
      @user_1 = create(:user, login: 'user_1', permission_ids:'.1.')
      @token_1 = []

      @user_2 = create(:user, login: 'user_2', permission_ids:'.2.3.')
      @token_2 = []

      @user_3 = create(:user, login: 'user_3', permission_ids:'.1.6.')
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

    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    after :all do
      @user_1.delete
      @user_2.delete
      @user_3.delete
    end

    # INVALID GET ROLES
    it "invalid_get_permissions" do
      # BAD TOKEN
      post "/api/v3/permissions/get_permissions"
      expect(response).to have_http_status 401
    end

    # FORBIDDEN GET ROLES
    it "forbidden_get_permissions" do
      # RETIRED
      post "/api/v3/permissions/get_permissions?token=#{@token_3[0]}"
      expect(response).to have_http_status 403
    end

    # GET ROLES
    it "get_permissions" do
      post "/api/v3/permissions/get_permissions?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/permissions/get_permissions?token=#{@token_2[0]}"
      expect(response).to have_http_status 200
    end

  end
end
