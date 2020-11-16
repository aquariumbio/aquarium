# frozen_string_literal: true

module Api
  module V3
    # USER RELATED API CALLS
    class UsersController < ApplicationController
      # RETURN LIST OF USERS FILTERED AND/OR SORTED BY PERMISSION
      # /api/v3/users/permissions?token=<token>&show[]=[1,2,3,4,5,6]&sort=<sort>
      def permissions
        # CHECK FOR ADMIN PERMISSIONS
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

      # SET SPECIFIC PERMISSION FOR SPECIFIC USER
      # /api/v3/users/set_permission?token=<token>&user_id=<user_id>&permission_id=<permission_id>&value=<true>
      def set_permission
        # CHECK FOR ADMIN PERMISSIONS
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        uid = params[:user_id].to_i
        rid = params[:permission_id].to_i
        val = (params[:value] == 'true' || params[:value] == 'on')
        if (uid == response[:user][:id]) && ((rid == 1) || (rid == 6))
          render json: { error: 'Cannot edit admin or retired for self.' }.to_json, status: :forbidden and return
        end

        valid = User.set_permission(uid, rid, val)
        render json: { error: 'Invalid.' }.to_json, status: :unauthorized and return unless valid

        render json: { user: { id: valid.id, name: valid.name, login: valid.login, permission_ids: valid.permission_ids } }.to_json, status: :ok
      end
    end
  end
end
