# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Users API calls
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
    class UsersController < ApplicationController
      # Returns a filtered / sorted list of users based on permission_ids.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users/permissions
      #   {
      #     token: <token>,
      #     show[]: <permission_id>,
      #     show[]: <permission_id>,
      #     ...
      #     sort: <sort>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     users: [
      #       {
      #         id: <user_id>,
      #         name: <name>,
      #         login: <login>,
      #         permission_ids: <permission_ids>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method permissions(token, show, sort)
      # @param token [String] a token
      # @param show [Array] the list of permission ids to filter
      # @param sort [String] the sort order
      def permissions
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        params_show = if params[:show].is_a?(Array)
                        params[:show]
                      elsif params[:show]
                        JSON.parse(params[:show]).to_a
                      else
                        []
                      end
        params_sort = params[:sort]

        conditions = []
        order = 'login'
        permission_ids = Permission.permission_ids()

        order = 'name, login' if params_sort == 'name'
        permission_ids.each do |key, val|
          conditions << key if params_show.index(key) || params_show.index(key.to_s)
          order = "permission_ids like '%.#{key}.%' desc, login" if params_sort == "permission.#{val}"
        end

        users = User.get_users_by_permission(conditions, order)

        render json: { users: users }.to_json, status: :ok
      end

      # Set a specific permission for a specific user.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users/permissions/update
      #   {
      #     token: <token>,
      #     user_id: <user_id>,
      #     permission_id: <permission_id>,
      #     value: <true/false>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     user: [
      #       {
      #         id: <user_id>,
      #         name: <name>,
      #         login: <login>,
      #         permission_ids: <permission_ids>
      #       }
      #     ]
      #   }
      #
      # @!method permissions_update(token, user_id, permission_id, value)
      # @param token [String] a token
      # @param user_id [Int] the id of the user to change
      # @param permission_id [Int] the id of the permission to change
      # @param value [Boolean] the permission setting ( <true/false> or <on/off> or <1/0> )
      def permissions_update
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        uid = Input.int(params[:user_id])
        rid = Input.int(params[:permission_id])
        val = Input.boolean(params[:value])
        if (uid == response[:user][:id]) && ((rid == 1) || (rid == 6))
          render json: { error: 'Cannot edit admin or retired for self.' }.to_json, status: :forbidden and return
        end

        valid = User.set_permission(uid, rid, val)
        render json: { error: 'Invalid' }.to_json, status: :unauthorized and return unless valid

        render json: { user: { id: valid.id, name: valid.name, login: valid.login, permission_ids: valid.permission_ids } }.to_json, status: :ok
      end
    end
  end
end
