class Api::V3::UserController < ApplicationController

  def sign_in
    login = params[:login].to_s.strip.downcase
    password = params[:password]

    user = User.find_by(login: login)
    if !user || !user.authenticate(password)
      render :json => { :status => 400, :error => "Invalid." }.to_json and return
    end

    token = SecureRandom.hex(64) # 128 characters
    ip = request.remote_ip
    timenow = Time.now.utc

    user_token = UserToken.new
    user_token.user_id = user.id
    user_token.token = token
    user_token.ip = ip
    user_token.timenow = timenow
    user_token.save

    render :json => { :status => 200, :data => { :token => token} }.to_json
  end

  def test_token
    token = params[:token].to_s.strip.downcase
    ip = request.remote_ip

    status, user = User.validate_token({:token => token, :ip => ip})
    case status
      when 400
        render :json => { :status => 400, :error => "Invalid." }.to_json and return
      when 401
        render :json => { :status => 401, :error => "Session timeout." }.to_json and return
      when 200
        render :json => { :status => 200, :data => user }.to_json
      end

  end

  def sign_out
    token = params[:token].to_s.strip.downcase
    all = ( params[:all] == "on" || params[:all] == "true" ) ? true : false
    ip = request.remote_ip

    signout = User.sign_out({:token => token, :ip => ip, :all => all})
    if !signout
      render :json => { :status => 400, :error => "Invalid." }.to_json and return
    end

    render :json => { :status => 200, :data => { :message => "Success." } }.to_json
  end


end
