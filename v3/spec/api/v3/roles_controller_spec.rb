require 'rails_helper'

RSpec.describe Api::V3::RolesController, type: :request do
  describe 'api' do

    # INITIALIZE AND SIGN IN USERS
    before :all do
      @user_1 = create(:user, login: 'user_1', role_ids:'.1.')
      @token_1 = []

      @user_2 = create(:user, login: 'user_2', role_ids:'.2.3.')
      @token_2 = []

      @user_3 = create(:user, login: 'user_3', role_ids:'.1.6.')
      @token_3 = []

      post "/api/v3/user/sign_in?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["data"]["token"]

      post "/api/v3/user/sign_in?login=user_2&password=password"
      resp = JSON.parse(response.body)
      @token_2 << resp["data"]["token"]

      post "/api/v3/user/sign_in?login=user_3&password=password"
      resp = JSON.parse(response.body)
      @token_3 << resp["data"]["token"]
     end

    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    after :all do
      @user_1.delete
      @user_2.delete
      @user_3.delete
    end

    # INVALID GET ROLES
    it "invalid_get_roles" do
      # BAD TOKEN
      post "/api/v3/roles/get_roles"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 400
    end

    # FORBIDDEN GET ROLES
    it "forbidden_get_roles" do
      # RETIRED
      post "/api/v3/roles/get_roles?token=#{@token_3[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403
    end

    # GET ROLES
    it "get_roles" do
      post "/api/v3/roles/get_roles?token=#{@token_1[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/roles/get_roles?token=#{@token_2[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200
    end


  end
end
