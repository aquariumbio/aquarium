# frozen_string_literal: true

module Api
  module V3
    # User related api calls
    class UsersController < ApplicationController
      # Returns a filtered / sorted list of users based on permission_ids.
      #
      # @param token [String] a token
      # @param show [Array] the list of permission ids to filter
      # @param sort [String] the sort order
      #
      # @return a filtered / sorted list of users
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
      # @param token [String] a token
      # @param user_id [Int] the id of the user to change
      # @param permission_id [Int] the id of the permission to change
      # @param value [String] "true" or "on" to turn the permission on, anything else to turn the permission off
      #
      # @return the user
      def permissions_update
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        uid = params[:user_id].to_i
        rid = params[:permission_id].to_i
        val = (params[:value] == 'true' || params[:value] == 'on')
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
