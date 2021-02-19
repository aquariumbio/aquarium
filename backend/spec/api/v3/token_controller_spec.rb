require 'rails_helper'

RSpec.describe Api::V3::TokenController, type: :request do
  describe 'api' do
    # Initialize @token_1 to store tokens
    before :all do
      @create_url = "/api/v3/token/create"
      @token_1 = []
    end

    # Sign in
    it "invalid_sign_in" do
      post "#{@create_url}?login=user_1&password=wrong_password"
      expect(response).to have_http_status 401
    end

    # Sign in 3 times
    it "sign_in_3_times" do
      # Sign in and set token
      post "#{@create_url}?login=user_1&password=password"
      expect(response).to have_http_status 200

      response_body = JSON.parse(response.body)
      token = response_body["token"]
      @token_1 << token

      # Sign in and set token
      post "#{@create_url}?login=user_1&password=password"
      expect(response).to have_http_status 200

      response_body = JSON.parse(response.body)
      token = response_body["token"]
      @token_1 << token

      # Sign in and set token
      post "#{@create_url}?login=user_1&password=password"
      expect(response).to have_http_status 200

      response_body = JSON.parse(response.body)
      token = response_body["token"]
      @token_1 << token
    end

    # Check tokens
    it "check_token" do
      get "/api/v3/token/get_user?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      get "/api/v3/token/get_user?token=#{@token_1[1]}"
      expect(response).to have_http_status 200

      get "/api/v3/token/get_user?token=#{@token_1[2]}"
      expect(response).to have_http_status 200
    end

    # Sign out
    it "sign_out" do
      post "/api/v3/token/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Check tokens
      get "/api/v3/token/get_user?token=#{@token_1[0]}"
      expect(response).to have_http_status 401

      get "/api/v3/token/get_user?token=#{@token_1[1]}"
      expect(response).to have_http_status 200

      get "/api/v3/token/get_user?token=#{@token_1[2]}"
      expect(response).to have_http_status 200
    end

    # Invalid sign out
    it "invalid_sign_out" do
      post "/api/v3/token/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 401
    end

    # Sign out all
    it "sign_out_all" do
      post "/api/v3/token/delete?token=#{@token_1[1]}&all=true"
      expect(response).to have_http_status 200

      # Check tokens
      get "/api/v3/token/get_user?token=#{@token_1[1]}"
      expect(response).to have_http_status 401

      get "/api/v3/token/get_user?token=#{@token_1[2]}"
      expect(response).to have_http_status 401
    end
  end
end
