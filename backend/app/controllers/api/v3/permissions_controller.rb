# frozen_string_literal: true

module Api
  module V3
    # Permissions related api calls
    class PermissionsController < ApplicationController
      # Returns the list of permissions.
      #
      # @param token [String] a token
      # @return the list of permissions
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
