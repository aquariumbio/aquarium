# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Permissions API calls
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
    class PermissionsController < ApplicationController
      # Returns list of permissions.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/permissions
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     permissions: {
      #       "1": "admin",
      #       "2": "manage",
      #       "3": "run",
      #       "4": "design",
      #       "5": "develop",
      #       "6": "retired"
      #     }
      #   }
      #
      # @!method index(token)
      # @param token [String] a token
      def index
         # Check for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        permissions = Permission.permission_ids

        render json: { permissions: permissions }.to_json, status: :ok
      end
    end
  end
end
