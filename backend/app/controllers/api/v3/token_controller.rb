class Api::V3::TokenController < ApplicationController
  def create
    login = params[:login].to_s.strip.downcase
    password = params[:password]

    user = User.find_by(login: login)
    render json: { status: 400, error: 'Invalid.' }.to_json and return if !user || !user.authenticate(password)

    ip = request.remote_ip
    timenow = Time.now.utc

    # CREATE A TOKEN
    token = UserToken.new_token(ip)
    render json: { status: 400, error: 'Invalid.' }.to_json unless token

    user_token = UserToken.new
    user_token.user_id = user.id
    user_token.token = token
    user_token.ip = ip
    user_token.timenow = timenow
    user_token.save

    render json: { status: 200, data: { token: token } }.to_json
  end

  def delete
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase
    all = (params[:all] == 'true' || params[:all] == 'on')

    signout = User.sign_out({ ip: ip, token: token, all: all })
    render json: { status: 400, error: 'Invalid.' }.to_json and return unless signout

    render json: { status: 200, data: { message: 'Signed out.' } }.to_json
  end

  def get_user
    permission_id = params[:permission_id] ? params[:permission_id].to_i : 0

    result = check_token_for_permission(permission_id)
    render json: result.to_json # and return if result[:error]
  end
end