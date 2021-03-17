require 'rails_helper'

RSpec.describe Api::V3::PermissionsController, type: :request do
  describe 'api' do
    # Sign in users
    before :each do
      @create_url = "/api/v3/token/create"
      @token_1 = []
      @token_2 = []
      @token_3 = []

      post "#{@create_url}?login=user_admin&password=aquarium123"
      response_body = JSON.parse(response.body)
      @token_1 << response_body["token"]

      post "#{@create_url}?login=user_manage&password=aquarium123"
      response_body = JSON.parse(response.body)
      @token_2 << response_body["token"]

      post "#{@create_url}?login=user_retired&password=aquarium123"
      response_body = JSON.parse(response.body)
      @token_3 << response_body["token"]
    end

    # Invalid get roles
    it "invalid_get_permissions" do
      # Bad token
      get "/api/v3/permissions"
      expect(response).to have_http_status 401
    end

    # Forbidden get roles
    it "forbidden_get_permissions" do
      # RETIRED
      get "/api/v3/permissions?token=#{@token_3[0]}"
      expect(response).to have_http_status 403
    end

    # Get roles
    it "get_permissions" do
      get "/api/v3/permissions?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      get "/api/v3/permissions?token=#{@token_2[0]}"
      expect(response).to have_http_status 200
    end
  end
end
