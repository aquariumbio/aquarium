# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Parameter API calls.
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
    class ParametersController < ApplicationController
      # <b>API Call:</b>
      #   GET: /api/v3/parameters
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     parameters: [
      #       {
      #         id: <parameter_id>,
      #         key: <key>,
      #         value: <value>,
      #         description: <true/false>,
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

        # Get parameters
        parameters = Parameter.find_all

        render json: { parameters: parameters }.to_json, status: :ok
      end

      # Returns a specific parameter.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/parameters/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     parameter: {
      #       id: <parameter_id>,
      #       key: <key>,
      #       value: <value>,
      #       description: <true/false>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the parameter
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get parameter
        id = Input.int(params[:id])
        parameter = Parameter.find_id(id)

        render json: { parameter: parameter }.to_json, status: :ok
      end

      # Create a new parameter.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/parameters/create
      #   {
      #     token: <token>
      #     parameter: {
      #       key: <key>,
      #       value: <value>,
      #       description: <true/false>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 201
      #   {
      #     parameter: {
      #       id: <parameter_id>,
      #       key: <key>,
      #       value: <value>,
      #       description: <true/false>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, parameter)
      # @param token [String] a token
      # @param parameter [Hash] the parameter
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read sample type parameter
        params_parameter = params[:parameter] || {}

        # Create sample type
        parameter, errors = Parameter.create(params_parameter)
        render json: { errors: errors }.to_json, status: :ok and return if !parameter

        render json: { parameter: parameter }.to_json, status: :created
      end

      # Update an parameter.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/parameters/create
      #   {
      #     token: <token>
      #     id: <parameter_id>,
      #     parameter: {
      #       key: <key>,
      #       value: <value>,
      #       description: <true/false>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     parameter: {
      #       id: <parameter_id>,
      #       key: <key>,
      #       value: <value>,
      #       description: <true/false>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, parameter)
      # @param token [String] a token
      # @param id [Int] the id of the parameter
      # @param parameter [Hash] the parameter
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get sample type
        id = Input.int(params[:id])
        parameter = Parameter.find_id(id)
        render json: { parameter: nil }.to_json, status: :ok and return if !parameter

        # Read parameter parameter
        params_parameter = params[:parameter] || {}

        # Update parameter
        parameter, errors = parameter.update(params_parameter)
        render json: { errors: errors }.to_json, status: :ok and return if !parameter

        render json: { parameter: parameter }.to_json, status: :ok
      end

      # Delete an parameter.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/parameters/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     value: "Parameter deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the parameter
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get parameter
        id = Input.int(params[:id])
        parameter = Parameter.find_id(id)
        render json: { parameter: nil  }.to_json, status: :ok and return if !parameter

        # Delete parameter
        parameter.delete

        render json: { message: "Parameter deleted" }.to_json, status: :ok
      end

    end
  end
end
