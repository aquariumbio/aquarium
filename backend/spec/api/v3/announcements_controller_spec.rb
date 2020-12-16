require 'rails_helper'

RSpec.describe Api::V3::AnnouncementsController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]

      @announcement_ids = []
    end

    # Create announcement with errors
    it "invalid_announcement" do
      post "/api/v3/announcements/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      resp = JSON.parse(response.body)
      expect(resp["errors"]["title"]).to eq ["can't be blank"]
      expect(resp["errors"]["message"]).to eq ["can't be blank"]
    end

    # CRUD tests

    # Create announcement with handler = collection
    it "create_announcement_collection" do
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
      resp = JSON.parse(response.body)
      this_announcement = resp["announcement"]
      @announcement_ids << this_announcement["id"]
    end

    # Get announcement
    it "get_announcement" do
      # Get announcement
      get "/api/v3/announcements/#{@announcement_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      announcement = resp["announcement"]
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
      resp = JSON.parse(response.body)

      # Check
      errors = resp["errors"]
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
      resp = JSON.parse(response.body)

      # Check
      announcement = resp["announcement"]
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
