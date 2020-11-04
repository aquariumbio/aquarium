class Api::V3::TokenController < ApplicationController

  def create
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

  def delete
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase
    all = params[:all] == "true" ? true : false

    signout = User.sign_out({:ip => ip, :token => token, :all => all})
    if !signout
      render :json => { :status => 400, :error => "Invalid." }.to_json and return
    end

    render :json => { :status => 200, :data => { :message => "Signed out." } }.to_json
  end

  def get_user()
    role_id = params[:role_id] ? params[:role_id].to_i : 0

    result = check_token_for_permission(role_id)
    render :json => result.to_json # and return if result[:error]
  end

end
