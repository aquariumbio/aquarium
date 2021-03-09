require 'rails_helper'

RSpec.describe Api::V3::JobsController, type: :request do
  describe 'api' do
    # Sign in users
    before :all do
      @create_url = "/api/v3/token/create"
      @token_1 = []

      post "#{@create_url}?login=user_1&password=password"
      response_body = JSON.parse(response.body)
      @token_1 << response_body["token"]
    end

    # Get counts
    it "get_counts" do
      get "/api/v3/jobs/counts?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      puts ">>> response_body"
      puts response_body
    end

    # Get unassigned
    it "get_unassigned" do
      get "/api/v3/jobs/unassigned?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      puts ">>> response_body"
      puts response_body
    end

    # Get assigned
    it "get_assigned" do
      get "/api/v3/jobs/assigned?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      puts ">>> response_body"
      puts response_body
    end

    # Get finished
    it "get_finished" do
      get "/api/v3/jobs/finished?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      puts ">>> response_body"
      puts response_body
    end

    # TODO: add real tests after you can create operations and jobs in v3
    # TODO: add permissions tests after change default test users
    #       from => user_1     / user_2      / user_3
    #       to   => user_admin / user_manage / user_run / user_design /user_develop / user_retired
  end
end
