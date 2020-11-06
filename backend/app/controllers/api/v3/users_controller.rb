class Api::V3::UsersController < ApplicationController
  def permissions
    # CHECK FOR ADMIN PERMISSIONS
    result = check_token_for_permission(1)
    render json: result.to_json and return if result[:error]

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

    render json: { status: 200, data: { users: users } }.to_json
  end

  def set_permission
    # CHECK FOR ADMIN PERMISSIONS
    result = check_token_for_permission(1)
    render json: result.to_json and return if result[:error]

    uid = params[:user_id].to_i
    rid = params[:permission_id].to_i
    val = (params[:value] == 'true' || params[:value] == 'on')
    if (uid == result[:user][:id]) && ((rid == 1) || (rid == 6))
      render json: { status: 403, error: 'Cannot edit admin or retired for self.' }.to_json and return
    end

    valid = User.set_permission(uid, rid, val)
    render json: { status: 400, error: 'Invalid.' }.to_json and return unless valid

    render json: { status: 200, data: { id: valid.id, name: valid.name, login: valid.login, permission_ids: valid.permission_ids } }.to_json
  end
end
