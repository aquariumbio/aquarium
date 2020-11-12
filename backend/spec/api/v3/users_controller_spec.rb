require 'rails_helper'

RSpec.describe Api::V3::UsersController, type: :request do
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
      @token_1 << resp["data"]["token"]

      post "/api/v3/token/create?login=user_2&password=password"
      resp = JSON.parse(response.body)
      @token_2 << resp["data"]["token"]

      post "/api/v3/token/create?login=user_3&password=password"
      resp = JSON.parse(response.body)
      @token_3 << resp["data"]["token"]
     end

    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    after :all do
      @user_1.delete
      @user_2.delete
      @user_3.delete
    end

    # INVALID GET USERS AND PERMISSIONS
    it "invalid_get_users_and_permissions" do
      # BAD TOKEN
      post "/api/v3/users/permissions"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 400
    end

    # FORBIDDEN GET USERS AND PERMISSIONS
    it "forbidden_get_users_and_permissions" do
      # NOT ADMIN
      post "/api/v3/users/permissions?token=#{@token_2[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403

      # ADMIN BUT RETIRED
      post "/api/v3/users/permissions?token=#{@token_3[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403
    end

    # GET USERS AND PERMISSIONS
    it "get_users_and_permissions" do
      post "/api/v3/users/permissions?token=#{@token_1[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/users/permissions?token=#{@token_1[0]}&show=[1,2]"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/users/permissions?token=#{@token_1[0]}&sort=name"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/users/permissions?token=#{@token_1[0]}&sort=permission.admin"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200
    end

    # INVALID CHANGE PERMISSION FOR USE
    it "invalid_get_users_and_permissions" do
      # BAD TOKEN
      post "/api/v3/users/set_permission?user_id=#{@user_2.id}&permission_id=4&value=true"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 400
    end

    # FORBIDDEN CHANGE PERMISSION FOR USE
    it "forbidden_get_users_and_permissions" do
      # NOT ADMIN
      post "/api/v3/users/set_permission?token=#{@token_2[0]}&user_id=#{@user_2.id}&permission_id=4&value=true"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403

      # ADMIN BUT RETIRED
      post "/api/v3/users/set_permission?token=#{@token_3[0]}&user_id=#{@user_2.id}&permission_id=4&value=true"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403
    end

    # CHANGE PERMISSION FOR USER
    it "change_permission" do
      post "/api/v3/users/set_permission?token=#{@token_1[0]}&user_id=#{@user_2.id}&permission_id=4&value=true"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200
      expect(resp["data"]["permission_ids"].index('.4.')).not_to eq(nil)

      post "/api/v3/users/set_permission?token=#{@token_1[0]}&user_id=#{@user_2.id}&permission_id=4"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200
      expect(resp["data"]["permission_ids"].index('.4.')).to eq(nil)
    end

    # CANNOT CHANGE ADMIN / RETIRED FOR SELF
    it "cannot_change_self_permission_admin_retired" do
      post "/api/v3/users/set_permission?token=#{@token_1[0]}&user_id=#{@user_1.id}&permission_id=1"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403

      post "/api/v3/users/set_permission?token=#{@token_1[0]}&user_id=#{@user_1.id}&permission_id=6"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 403
    end

  end
end
