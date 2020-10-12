# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::JobsController, type: :request do
  describe 'api' do

    # INITIALIZE USERS - CREATE NEW USERS OR GET EXISTING USERS
    # NOTE: THESE USERS SHOULD NOT EXIST
    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    before :all do
      @user_1 = create(:user, name: 'user 1', login: 'user_1') rescue nil
      @user_1 = @user_1 || User.find_by_login('user_1')

      @user_2 = create(:user, name: 'user 2', login: 'user_2') rescue nil
      @user_2 = @user_2 || User.find_by_login('user_2')

      @user_3 = create(:user, name: 'user 3', login: 'user_3') rescue nil
      @user_3 = @user_3 || User.find_by_login('user_3')

      @job_1 = create(:job, { user_id: @user_1.id })

      @job_2 = create(:job, { user_id: @user_2.id })

      @job_3 = create(:job, { user_id: @user_3.id })
    end

    after :all do
      @user_1.delete
      @user_2.delete
      @user_3.delete
      @job_1.delete
      @job_2.delete
      @job_3.delete
    end

    # GET JOB
    it "get_job" do
      get "/api/v2/jobs/#{@job_1.id}"
      json_response = JSON.parse(response.body)

      # JUST CHECK FOR VALID RESPONSE
      job = json_response["data"]

      expect(job["user_id"]).to eq(@job_1.user_id)
    end

    # GET JOB (INVALID JOB)
    it "get_job" do
      get "/api/v2/jobs/0"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

    # GET JOB ASSIGNMENT
    it "get_job_assignment" do
      # NOOP
      # TESTED IN "ASSIGN_UNASSIGN_JOB"
    end

    # GET JOB ASSIGNMENT (INVALID JOB)
    it "get_job_assignment" do
      get "/api/v2/jobs/0/assignment"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

    # ASSIGN JOB + UNASSIGN JOB + GET JOB ASSIGNMENT
    it "assign_unassign_job" do
      # SIMULATE LOGING IN THE USER
      token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
      cookies[token_name] = User.find(@user_1.id).remember_token

      # ASSIGN JOB
      post "/api/v2/jobs/#{@job_1.id}/assign?to=#{@user_2.id}"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(200)

      # VERIFY ASSIGNMENT
      get "/api/v2/jobs/#{@job_1.id}/assignment"
      json_response = JSON.parse(response.body)

      assignment = json_response["data"]
      expect(assignment["by_login"]).to eq(@user_1["login"])
      expect(assignment["to_login"]).to eq(@user_2["login"])

      # UNASSIGN JOB
      post "/api/v2/jobs/#{@job_1.id}/unassign"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(200)

      # VERIFY ASSIGNMENT = NIL
      get "/api/v2/jobs/#{@job_1.id}/assignment"
      json_response = JSON.parse(response.body)

      assignment = json_response["data"]
      expect(assignment).to eq(nil)
    end

    # ASSIGN JOB (INVALID USER)
    it "assign_job" do
      post "/api/v2/jobs/1/assign"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

    # UNASSIGN JOB
    it "unassign job" do
      # NOOP
      # TESTED IN "ASSIGN_UNASSIGN_JOB"
    end

    # UNASSIGN JOB (INVALID USER)
    it "unassign job" do
      post "/api/v2/jobs/0/unassign"
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

  end
end


