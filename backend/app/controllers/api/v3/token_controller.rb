# frozen_string_literal: true

module Api
  module V3
    # TOKEN RELATED API CALLS
    class TokenController < ApplicationController
      # SIGN IN
      # /api/v3/token/create?login=<login>&password=<password>
      def create
        login = params[:login].to_s.strip.downcase
        password = params[:password]

        user = User.find_by(login: login)
        render json: { error: 'Invalid.' }.to_json, status: :unauthorized and return if !user || !user.authenticate(password)

        ip = request.remote_ip
        timenow = Time.now.utc

        # CREATE A TOKEN
        token = UserToken.new_token(ip)
        render json: { error: 'Invalid.' }.to_json, status: :unauthorized unless token

        user_token = UserToken.new
        user_token.user_id = user.id
        user_token.token = token
        user_token.ip = ip
        user_token.timenow = timenow
        user_token.save

        render json: { token: token }.to_json, status: :ok
      end

      # SIGN OUT (ALL = SIGN OUT OF ALL DEVICES)
      # /api/v3/token/delete?token=<token>&all=<true>
      def delete
        ip = request.remote_ip
        token = params[:token].to_s.strip.downcase
        all = (params[:all] == 'true' || params[:all] == 'on')

        signout = User.sign_out({ ip: ip, token: token, all: all })
        render json: { error: 'Invalid.' }.to_json, status: :unauthorized and return unless signout

        render json: { message: 'Signed out.' }.to_json, status: :ok
      end

      # GET USER
      # /api/v3/token/get_user?token=<token>
      def get_user
        permission_id = params[:permission_id] ? params[:permission_id].to_i : 0

        status, response = check_token_for_permission(permission_id)
        render json: response.to_json, status: status.to_sym
      end
    end
  end
end
