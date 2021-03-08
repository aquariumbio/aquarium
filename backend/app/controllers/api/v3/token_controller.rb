# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Token API calls.
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
    class TokenController < ApplicationController
      # Create a token.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/token/create
      #   {
      #     login: <login>,
      #     password: <password>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     token: <token>,
      #     user: {
      #       id: <user_id>,
      #       name: <name>,
      #       login: <login>,
      #       permission_ids: <permission_ids>
      #       email: <email>,
      #       phone: <phone>,
      #       lab_agreement: <lab_agreement>,
      #       aquarium_agreement: <aquarium_agreement>,
      #       new_samples_private: <new_samples_private>,
      #       lab_name: <lab_name>
      #     }
      #   }
      #
      # @!method create(login, password)
      # @param login [String] login
      # @param password [String] password
      def create
        login = params[:login].to_s.strip.downcase
        password = params[:password]

        user = User.find_by(login: login)
        render json: { error: 'Invalid' }.to_json, status: :unauthorized and return if !user || !user.authenticate(password)

        ip = request.remote_ip
        timenow = Time.now.utc

        # Create a token
        token = UserToken.new_token(ip)
        render json: { error: 'Invalid' }.to_json, status: :unauthorized unless token

        user_token = UserToken.new
        user_token.user_id = user.id
        user_token.token = token
        user_token.ip = ip
        user_token.timenow = timenow
        user_token.save

         # Return token and user with extended info
        render json: { token: token, user: User.find_id_show_info(user.id) }.to_json, status: :ok
      end

      # Remove a token or optionally all tokens associated with this user.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/token/delete
      #   {
      #     token: <token>,
      #     all: <boolean> (true/false or on/off or 1/0)
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Signed out"
      #   }
      #
      # @!method delete(token, all)
      # @param token [String] a token
      # @param all [Boolean] true/on/1 to remove all tokens associated with this user
      def delete
        ip = request.remote_ip
        token = params[:token].to_s.strip.downcase
        all = (params[:all] == 'true' || params[:all] == 'on')

        signout = User.sign_out({ ip: ip, token: token, all: all })
        render json: { error: 'Invalid' }.to_json, status: :unauthorized and return unless signout

        render json: { message: 'Signed out' }.to_json, status: :ok
      end

      # Returns the user for the token and an optional permission_id.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/token/get_user
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     user: {
      #       id: <user_id>,
      #       name: <name>,
      #       login: <login>,
      #       permission_ids: <permission_ids>
      #       email: <email>,
      #       phone: <phone>,
      #       lab_agreement: <lab_agreement>,
      #       aquarium_agreement: <aquarium_agreement>,
      #       new_samples_private: <new_samples_private>,
      #       lab_name: <lab_name>
      #     }
      #   }
      #
      # @!method get_user(token)
      # @param token [String] a token
      def get_user
        permission_id = params[:permission_id] ? params[:permission_id].to_i : 0

        # Check for permission_id permissions
        status, response = check_token_for_permission(permission_id)
        render json: response.to_json, status: status.to_sym
      end
    end
  end
end
