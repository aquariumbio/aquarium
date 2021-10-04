# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Budget API calls.
    #
    # <b>General</b>
    #   API Status Codes:
    #
    #     STATUS_CODE: 200 - OK
    #     STATUS_CODE: 201 - Created
    #     STATUS_CODE: 401 - Unauthorized
    #     STATUS_CODE: 403 - Forbidden
    #
    #   API Success Response with Form Errors:
    #
    #     STATUS_CODE: 200
    #     {
    #       errors: {
    #         field_1: [
    #           field_1_error_1,
    #           field_1_error_2,
    #           ...
    #         ],
    #         field_2: [
    #           field_2_error_1,
    #           field_2_error_2,
    #           ...
    #         ],
    #         ...
    #       }
    #     }
    class BudgetsController < ApplicationController
      # Returns all budgets.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/budgets
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     budgets: [
      #       {
      #         id: <budget_id>,
      #         name: <name>,
      #         description: <description>,
      #         created_at: <datetime>,
      #         updated_at: <datetime>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method index(token)
      # @param token [String] a token
      def index
        # Check for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get budgets
        letter = Input.letter(params[:letter])
        budgets = letter ? Budget.find_by_first_letter(letter) : Budget.find_all

        render json: { budgets: budgets }.to_json, status: :ok
      end

      # Returns a specific budget.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/budgets/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     budget: {
      #       id: <budget_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the budget
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get budget
        id = Input.int(params[:id])
        budget = Budget.find_id(id)
        render json: { error: "Budget not found" }.to_json, status: :not_found and return if !budget

        render json: { budget: budget }.to_json, status: :ok
      end

      # Create a new budget.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/budgets/create
      #   {
      #     token: <token>
      #     budget: {
      #       title: <name>,
      #       message: <description>,
      #       active: <true/false>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     budget: {
      #       id: <budget_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, budget)
      # @param token [String] a token
      # @param budget [Hash] the budget
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read budget parameter
        params_budget = params[:budget] || {}

        # Create budget
        budget, errors = Budget.create_from(params_budget)
        render json: { errors: errors }.to_json, status: :ok and return if !budget

        render json: { budget: budget }.to_json, status: :created
      end

      # Update a budget.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/budgets/create
      #   {
      #     token: <token>
      #     id: <budget_id>,
      #     budget: {
      #       name: <name>,
      #       description: <description>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     budget: {
      #       id: <budget_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, budget)
      # @param token [String] a token
      # @param id [Int] the id of the budget
      # @param budget [Hash] the budget
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get budget
        id = Input.int(params[:id])
        budget = Budget.find_id(id)
        render json: { error: "Budget not found" }.to_json, status: :not_found and return if !budget

        # Read budget parameter
        params_budget = params[:budget] || {}

        # Update budget
        budget, errors = budget.update_with(params_budget)
        render json: { errors: errors }.to_json, status: :ok and return if !budget

        render json: { budget: budget }.to_json, status: :ok
      end

      # Add a user_budget_association.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/budgets/create
      #   {
      #     token: <token>
      #     id: <budget_id>,
      #     user_id: <user_id>,
      #     quota: <amount>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     user_budget: {
      #       id: <budget_id>,
      #       user_id: <user_id>,
      #       quota: <quota>,
      #       disabled: NULL,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create_user_budget(token, id, user_id, quota)
      # @param token [String] a token
      # @param id [Int] the id of the budget
      # @param user_id [Int] the user_id
      # @param quota [Float] the budget quota
      def create_user_budget
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get budget
        id = Input.int(params[:id])
        budget = Budget.find_id(id)
        render json: { error: "User Budget not found" }.to_json, status: :not_found and return if !budget

        # Get user
        user_id = Input.int(params[:user_id])
        user = User.find_id(id)
        render json: { error: "User Budget not found" }.to_json, status: :not_found and return if !user

        # Get quota
        quota = Input.float(params[:quota])

        # Add user_budget
        user_budget = UserBudgetAssociation.new({
                                                  user_id: user_id,
                                                  budget_id: budget.id,
                                                  quota: quota
                                                })
        user_budget.save
        render json: { user_budget: user_budget }.to_json, status: :ok
      end

      # Delete a user_budget_association.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/budgets/create
      #   {
      #     token: <token>
      #     id: <budget_id>,
      #     user_budget_id: <user_budget_id>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "UserBudget deleted"
      #   }
      #
      # @!method delete_user_budget(token, id, user_id, quota)
      # @param token [String] a token
      # @param id [Int] the id of the budget
      # @param user_id [Int] the user_id
      # @param quota [Float] the budget quota
      def delete_user_budget
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get user_budget
        budget_id = Input.int(params[:id])
        user_budget_id = Input.int(params[:user_budget_id])
        user_budget = UserBudgetAssociation.find_id(user_budget_id, budget_id)
        render json: { error: "User Budget not found" }.to_json, status: :not_found and return if !user_budget

        # Delete user_budget
        user_budget.delete

        render json: { message: "User Budget deleted" }.to_json, status: :ok
      end
    end
  end
end
