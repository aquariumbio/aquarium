require 'rails_helper'

RSpec.describe Api::V3::BudgetsController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]

      @budget_ids = []
    end

    # Create budget with errors
    it "invalid_budget" do
      post "/api/v3/budgets/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Errors
      resp = JSON.parse(response.body)
      expect(resp["errors"]["name"]).to eq ["can't be blank"]
      expect(resp["errors"]["description"]).to eq ["can't be blank"]
    end

    # CRUD tests

    # Create budget
    it "create_budget" do
      # budget parameters
      params = {
        budget: {
          "name": "new name",
          "description": "new description",
          "contact": "new contact",
          "email": "new email",
          "phone": "new phone"
        }
      }

      # Create budget
      post "/api/v3/budgets/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Save the id
      resp = JSON.parse(response.body)
      this_budget = resp["budget"]
      @budget_ids << this_budget["id"]
    end

    # Get budget
    it "get_budget" do
      # Get budget
      get "/api/v3/budgets/#{@budget_ids[0]}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      budget = resp["budget"]
      expect(budget["name"]).to eq "new name"
      expect(budget["description"]).to eq "new description"
      expect(budget["contact"]).to eq "new contact"
      expect(budget["email"]).to eq "new email"
      expect(budget["phone"]).to eq "new phone"
    end

    # Update budget with errors
    it "invalid_update_budget" do
      # Update budget
      update_params = {
        budget: {
        }
      }

      post "/api/v3/budgets/#{@budget_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      errors = resp["errors"]
      expect(errors["name"]).to eq ["can't be blank"]
      expect(errors["description"]).to eq ["can't be blank"]
      expect(errors["contact"]).to eq ["can't be blank"]
      expect(errors["email"]).to eq ["can't be blank"]
      expect(errors["phone"]).to eq ["can't be blank"]
    end

    # Update budget
    it "invalid_update_budget" do
      # Update budget
      update_params = {
        budget: {
          "name": "update name",
          "description": "update description",
          "contact": "update contact",
          "email": "update email",
          "phone": "update phone"
        }
      }

      post "/api/v3/budgets/#{@budget_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Check
      budget = resp["budget"]
      expect(budget["name"]).to eq "update name"
      expect(budget["description"]).to eq "update description"
      expect(budget["contact"]).to eq "update contact"
      expect(budget["email"]).to eq "update email"
      expect(budget["phone"]).to eq "update phone"
    end

  end
end
