class Api::V3::UsersController < ApplicationController

  def roles
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase

    status, user = User.validate_token({:ip => ip, :token => token},1)
    case status
      when 400
        render :json => { :status => 400, :error => "Invalid." }.to_json and return
      when 401
        render :json => { :status => 401, :error => "Session timeout." }.to_json and return
      when 403
        render :json => { :status => 403, :error => "Admin permissions required." }.to_json and return
      when 200
        # noop
      end

    if params[:show].kind_of?(Array)
      params_show = params[:show]
    elsif params[:show]
      params_show = JSON.parse(params[:show]).to_a
    else
      params_show = []
    end
    params_sort = params[:sort]

    ins = []
    order = "login"
    role_ids = Role.role_ids()

    if params_sort == "name"
      order = "name, login"
    end
    role_ids.each do |key,val|
      ins << key if params_show.index(key.to_s)
      if params_sort == "role.#{val}"
        order = "role_ids like '%.#{key}.%' desc, login"
      end
    end

    users = User.get_users_by_role(ins, order)

    render :json => { :status => 200, :data => { :users => users } }.to_json
  end

  def set_role
    # TODO - GET USER_ID FROM TOKEN AND VERIFY PERMISSIONS
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase

    status, user = User.validate_token({:ip => ip, :token => token},1)
    case status
      when 400
        render :json => { :status => 400, :error => "Invalid." }.to_json and return
      when 401
        render :json => { :status => 401, :error => "Session timeout." }.to_json and return
      when 403
        render :json => { :status => 403, :error => "Admin permissions required." }.to_json and return
      when 200
        # noop
      end


    uid = params[:user_id].to_i
    rid = params[:role_id].to_i
    val = params[:value] == "true" ? true : false

    render :json => { :status => 403, :error => "Cannot edit admin or retired for self." }.to_json and return if uid == user[:id] and ( rid == 1 or rid == 6 )

    valid = User.set_role(uid,rid,val)
    render :json => { :status => 400, :error => "Invalid." }.to_json and return if !valid

    render :json => { :status => 200, :data => { :id => valid.id, :name => valid.name, :login => valid.login, :role_ids => valid.role_ids } }.to_json
  end

end
