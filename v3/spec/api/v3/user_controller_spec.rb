require 'rails_helper'

RSpec.describe Api::V3::UserController, type: :request do
  describe 'api' do

    # INITIALIZE USERS
    before :all do
      @user_1 = create(:user, login: 'user_1') rescue  User.find_by(login: 'user_1')
      @token_1 = []
    end

    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    after :all do
      @user_1.delete
    end

    # SIGN IN
    it "invalid_sign_in" do
      post "/api/v3/user/sign_in?login=user_1&password=wrong_password"
      resp = JSON.parse(response.body)

      expect(resp["status"]).to eq 400
    end

    # SIGN IN 3 TIMES
    it "sign_in_3_times" do
      # SIGN IN AND SET TOKEN
      post "/api/v3/user/sign_in?login=user_1&password=password"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      token = resp["data"]["token"]
      @token_1 << token

      # SIGN IN AND SET TOKEN
      post "/api/v3/user/sign_in?login=user_1&password=password"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      token = resp["data"]["token"]
      @token_1 << token

      # SIGN IN AND SET TOKEN
      post "/api/v3/user/sign_in?login=user_1&password=password"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      token = resp["data"]["token"]
      @token_1 << token
    end

    # CHECK TOKENS
    it "check_token" do
      post "/api/v3/user/validate_token?token=#{@token_1[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/user/validate_token?token=#{@token_1[1]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/user/validate_token?token=#{@token_1[2]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200
    end

    # SIGN OUT
    it "sign_out" do
      post "/api/v3/user/sign_out?token=#{@token_1[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      # CHECK TOKENS
      post "/api/v3/user/validate_token?token=#{@token_1[0]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 400

      post "/api/v3/user/validate_token?token=#{@token_1[1]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      post "/api/v3/user/validate_token?token=#{@token_1[2]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200
    end

    # INVALID SIGN OUT
    it "invalid_sign_out" do
      post "/api/v3/user/sign_out?token=#{@token_1[0]}"
      resp = JSON.parse(response.body)

      expect(resp["status"]).to eq 400
    end

    # SIGN OUT ALL
    it "sign_out_all" do
      post "/api/v3/user/sign_out?token=#{@token_1[1]}&all=true"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 200

      # CHECK TOKENS
      post "/api/v3/user/validate_token?token=#{@token_1[1]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 400

      post "/api/v3/user/validate_token?token=#{@token_1[2]}"
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq 400
    end

  end
end
