require 'rails_helper'

RSpec.describe Api::V3::AnnouncementsController, type: :request do
  describe 'api' do
    # Sign in users
    before :all do
      @create_url = "/api/v3/token/create"
      @token_1 = []

      post "#{@create_url}?login=user_1&password=aquarium123"
      response_body = JSON.parse(response.body)
      @token_1 << response_body["token"]

      @announcement_ids = []
    end

    # Create announcement with errors
    it "invalid_announcement" do
      post "/api/v3/announcements/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      response_body = JSON.parse(response.body)
      expect(response_body["errors"]["title"]).to eq ["can't be blank"]
      expect(response_body["errors"]["message"]).to eq ["can't be blank"]
    end

    # CRUD tests

    # Create announcement
    it "create_announcement" do
      # announcement parameters
      params = {
        announcement: {
          "title": "new title",
          "message": "new message",
          "active": "false"
        }
      }

      # Create announcement
      post "/api/v3/announcements/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Save the id
      response_body = JSON.parse(response.body)
      this_announcement = response_body["announcement"]
      @announcement_ids << this_announcement["id"]
    end

    # Get announcement
    it "get_announcement" do
      # Get announcement
      get "/api/v3/announcements/#{@announcement_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      response_body = JSON.parse(response.body)

      # Check
      announcement = response_body["announcement"]
      expect(announcement["title"]).to eq "new title"
      expect(announcement["message"]).to eq "new message"
      expect(announcement["active"]).to eq false
    end

    # Update announcement with errors
    it "invalid_update_announcement" do
      # Update announcement
      update_params = {
        announcement: {
        }
      }

      post "/api/v3/announcements/#{@announcement_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      response_body = JSON.parse(response.body)

      # Check
      errors = response_body["errors"]
      expect(errors["title"]).to eq ["can't be blank"]
      expect(errors["message"]).to eq ["can't be blank"]
    end

    # Update announcement
    it "invalid_update_announcement" do
      # Update announcement
      update_params = {
        announcement: {
          "title": "update title",
          "message": "update message",
          "active": "true"
        }
      }

      post "/api/v3/announcements/#{@announcement_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      response_body = JSON.parse(response.body)

      # Check
      announcement = response_body["announcement"]
      expect(announcement["title"]).to eq "update title"
      expect(announcement["message"]).to eq "update message"
      expect(announcement["active"]).to eq true
    end

    # Delete the announcement
    it "delete_announcements" do
      post "/api/v3/announcements/#{@announcement_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end
  end
end
