# frozen_string_literal: true

module Api
  module V3
    # PERMISSIONS RELATED API CALLS
    class PermissionsController < ApplicationController
      # GET CURRENT LIST OF PERMISSIONS FROM PERMISSIONS DB
      def get_permissions
        status, response = check_token_for_permission
        if response[:error]
          render json: response.to_json, status: status and return 
        end

        permissions = Permission.permission_ids

        render json: { permissions: permissions }.to_json, status: :ok
      end
    end
  end
end
