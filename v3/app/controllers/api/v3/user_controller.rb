class Api::V3::UserController < ApplicationController

  def sign_in
    login = params[:login].to_s.strip.downcase
    password = params[:password]

    user = User.find_by(login: login)
    if !user || !user.authenticate(password)
      render :json => { :status => 400, :error => "Invalid." }.to_json and return
    end

    ip = request.remote_ip
    timenow = Time.now.utc

    # CREATE A TOKEN
    token = UserToken.new_token(ip)
    render :json => { :status => 400, :error => "Invalid." }.to_json if !token

    user_token = UserToken.new
    user_token.user_id = user.id
    user_token.token = token
    user_token.ip = ip
    user_token.timenow = timenow
    user_token.save

    render :json => { :status => 200, :data => { :token => token } }.to_json
  end

  def sign_out
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase
    all = params[:all] == "true" ? true : false

    signout = User.sign_out({:ip => ip, :token => token, :all => all})
    if !signout
      render :json => { :status => 400, :error => "Invalid." }.to_json and return
    end

    render :json => { :status => 200, :data => { :message => "Signed out." } }.to_json
  end

  def validate_token()
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase
    role_id = params[:role_id] ? params[:role_id].to_i : 0

    status, user = User.validate_token({:ip => ip, :token => token},role_id)
    case status
      when 400
        render :json => { :status => 400, :error => "Invalid." }.to_json and return
      when 401
        render :json => { :status => 401, :error => "Session timeout." }.to_json and return
      when 403
        render :json => { :status => 403, :error => "#{Role.role_ids[role_id].capitalize} permissions required." }.to_json and return
      when 200
        render :json => { :status => 200, :data => user }.to_json and return
      end
  end

end
