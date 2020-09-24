# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::GroupsController, type: :request do
  describe 'api' do

    # INITIALIZE USERS - CREATE NEW USER OR GET EXISTING USER
    # NOTE: THESE USERS SHOULD NOT EXIST
    # NOTE: DATABASE ENTRIES IN BEFORE :ALL ARE NOT FLUSHED AUTOMATICALLY
    before :all do
      @user_1 = create(:user, login: 'user_1') rescue nil
      @user_1 = @user_1 || User.find_by_login('user_1')
    end

    after :all do
      @user_1.delete
    end

    # GET GROUPS
    it 'get_groups' do
      get '/api/v2/groups'
      json_response = JSON.parse(response.body)

      # JUST CHECK FOR VALID RESPONSE
      expect(json_response["status"]).to eq(200)
    end

    # GET GROUP
    it 'get_group' do
      get '/api/v2/groups/55'
      json_response = JSON.parse(response.body)

      group = json_response["data"]
      expect(group["name"]).to eq("technicians")
    end

    # GET GROUP (INVALID GROUP)
    it 'get_group_invalid' do
      get '/api/v2/groups/0'
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

    # GET USERS IN GROUP
    it 'get_user_jobs' do
      get '/api/v2/groups/55/users'
      json_response = JSON.parse(response.body)
      len = json_response["data"].length

      # ADD USER OR GET EXISTING USER
      user_1 = create(:user, login: 'user_1') rescue nil
      user_1 = user_1 || User.find_by_login('user_1')

      # ADD USER TO GROUP
      membership = ( create(:membership, { group_id: 55, user_id: user_1.id }) ) rescue nil
      plus = membership ? 1 : 0

      get '/api/v2/groups/55/users'
      json_response = JSON.parse(response.body)
      len_new = json_response["data"].length

      expect(len_new).to eq(len + plus)
    end

    # GET USERS IN GROUP (INVALID GROUP)
    it 'get_user_jobs_invalid' do
      get '/api/v2/groups/0/users'
      json_response = JSON.parse(response.body)

      expect(json_response["status"]).to eq(400)
    end

  end
end

