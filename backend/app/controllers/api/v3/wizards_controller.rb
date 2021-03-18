# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Wizard API calls.
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
    class WizardsController < ApplicationController
      # Returns all wizards.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/wizards
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     wizards: [
      #       {
      #         id: <wizard_id>,
      #         name: <name>,
      #         description: <description>,
      #         specification: <specification>,
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

        # Get wizards
        letter = Input.letter(params[:letter])
        wizards = letter ? Wizard.find_by_first_letter(letter) : Wizard.find_all

        render json: { wizards: wizards }.to_json, status: :ok
      end

      # Returns a specific wizard.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/wizards/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     wizard: {
      #       id: <wizard_id>,
      #       name: <name>,
      #       description: <description>,
      #       specification: <specification>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the wizard
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get wizard
        id = Input.int(params[:id])
        wizard = Wizard.find_id(id)

        render json: { wizard: wizard }.to_json, status: :ok
      end

      # Create a new wizard.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/wizards/create
      #   {
      #     token: <token>
      #     wizard: {
      #       name: <name>,
      #       description: <description>,
      #       specification: <specification>,
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     wizard: {
      #       id: <wizard_id>,
      #       name: <name>,
      #       description: <description>,
      #       specification: <specification>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, wizard)
      # @param token [String] a token
      # @param wizard [Hash] the wizard
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read wizard parameter
        params_wizard = params[:wizard] || {}

        # Create wizard
        wizard, errors = Wizard.create(params_wizard)
        render json: { errors: errors }.to_json, status: :ok and return if !wizard

        render json: { wizard: wizard }.to_json, status: :created
      end

      # Update a wizard.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/wizards/<id>/update
      #   {
      #     token: <token>
      #     id: <wizard_id>,
      #     wizard: {
      #       name: <name>,
      #       description: <description>,
      #       specification: <specification>,
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     wizard: {
      #       id: <wizard_id>,
      #       name: <name>,
      #       description: <description>,
      #       specification: <specification>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, wizard)
      # @param token [String] a token
      # @param id [Int] the id of the wizard
      # @param wizard [Hash] the wizard
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get wizard
        id = Input.int(params[:id])
        wizard = Wizard.find_id(id)
        render json: { error: "Wizzard not found" }.to_json, status: :not_found and return if !wizard

        # Read wizard parameter
        params_wizard = params[:wizard] || {}

        # Update wizard
        wizard, errors = wizard.update(params_wizard)
        render json: { errors: errors }.to_json, status: :ok and return if !wizard

        render json: { wizard: wizard }.to_json, status: :ok
      end

      # Delete a wizard.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/wizards/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Wizard deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the wizard
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get wizard
        id = Input.int(params[:id])
        wizard = Wizard.find_id(id)
        render json: { error: "Wizzard not found" }.to_json, status: :not_found and return if !wizard

        # Delete wizard
        wizard.delete

        render json: { message: "Wizard deleted" }.to_json, status: :ok
      end
    end
  end
end
