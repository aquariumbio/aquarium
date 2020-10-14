# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::UsersController, type: :request do
  describe 'api' do

    # INITIALIZE USERS - CREATE NEW USERS OR GET EXISTING USERS
    # NOTE: THESE USERS SHOULD NOT EXIST
    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    before :all do
      @user_1 = create(:user, login: 'user_1') rescue nil
      @user_1 = @user_1 || User.find_by_login('user_1')
    end

    after :all do
      @user_1.delete
    end

    # GET USERS
    it "get_users" do
      get "/api/v2/users"
      json_response = JSON.parse(response.body)

      # CHECK THE LAST THREE USERS
      len = json_response["data"].length

      last_user = json_response["data"][len - 1]
      expect(last_user["login"]).to eq("user_1")
    end

    # GET USER
    it "get_user" do
      get "/api/v2/users/#{@user_1.id}" # , params: { id: 1 }
      json_response = JSON.parse(response.body)

      user = json_response["data"]
      expect(user["login"]).to eq(@user_1["login"])
    end

    # GET USER (INVALID USER)
    it "get_user_invalid" do
      get "/api/v2/users/0" # , params: { id: 1 }
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

    # GET JOBS RUN BY USER
    it "get_user_jobs" do
      get "/api/v2/users/#{@user_1.id}/jobs"
      json_response = JSON.parse(response.body)

      # JUST CHECK FOR VALID RESPONSE
      # CHECK FOR VALID RESPONSE DATA IN JOBS_CONTROLLER_SPEC
      expect(json_response["status"]).to eq(200)
    end

    # GET JOBS RUN BY USER (INVALID USER)
    it "get_user_jobs_invalid" do
      get "/api/v2/users/0"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

    # GET JOBS ASSIGNED TO USER
    it "get_user_assigned_jobs" do
      get "/api/v2/users/#{@user_1.id}/assigned_jobs"
      json_response = JSON.parse(response.body)

      # JUST CHECK FOR VALID RESPONSE
      # CHECK FOR VALID RESPONSE DATA IN JOBS_CONTROLLER_SPEC
      expect(json_response["status"]).to eq(200)
    end

    # GET JOBS ASSIGNED TO USER (INVALID USER)
    it "get_user_assigned_jobs_invalid" do
      get "/api/v2/users/0" # , params: { id: 1 }
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

  end
end
