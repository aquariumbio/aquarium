require 'rails_helper'

RSpec.describe Api::V3::TokenController, type: :request do
  describe 'api' do

    # INITIALIZE USERS
    before :all do
      @user_1 = create(:user, login: 'user_1')
      @token_1 = []
    end

    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    after :all do
      @user_1.delete
    end

    # SIGN IN
    it "invalid_sign_in" do
      post "/api/v3/token/create?login=user_1&password=wrong_password"
      expect(response).to have_http_status 401
    end

    # SIGN IN 3 TIMES
    it "sign_in_3_times" do
      # SIGN IN AND SET TOKEN
      post "/api/v3/token/create?login=user_1&password=password"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      token = resp["token"]
      @token_1 << token

      # SIGN IN AND SET TOKEN
      post "/api/v3/token/create?login=user_1&password=password"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      token = resp["token"]
      @token_1 << token

      # SIGN IN AND SET TOKEN
      post "/api/v3/token/create?login=user_1&password=password"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      token = resp["token"]
      @token_1 << token
    end

    # CHECK TOKENS
    it "check_token" do
      post "/api/v3/token/get_user?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/token/get_user?token=#{@token_1[1]}"
      expect(response).to have_http_status 200

      post "/api/v3/token/get_user?token=#{@token_1[2]}"
      expect(response).to have_http_status 200
    end

    # SIGN OUT
    it "sign_out" do
      post "/api/v3/token/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # CHECK TOKENS
      post "/api/v3/token/get_user?token=#{@token_1[0]}"
      expect(response).to have_http_status 401

      post "/api/v3/token/get_user?token=#{@token_1[1]}"
      expect(response).to have_http_status 200

      post "/api/v3/token/get_user?token=#{@token_1[2]}"
      expect(response).to have_http_status 200
    end

    # INVALID SIGN OUT
    it "invalid_sign_out" do
      post "/api/v3/token/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 401
    end

    # SIGN OUT ALL
    it "sign_out_all" do
      post "/api/v3/token/delete?token=#{@token_1[1]}&all=true"
      expect(response).to have_http_status 200

      # CHECK TOKENS
      post "/api/v3/token/get_user?token=#{@token_1[1]}"
      expect(response).to have_http_status 401

      post "/api/v3/token/get_user?token=#{@token_1[2]}"
      expect(response).to have_http_status 401
    end

  end
end
