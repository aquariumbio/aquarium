# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Users API calls
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
    class UsersController < ApplicationController
      # Returns all users / all users beginning with <letter>.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     users: [
      #       {
      #         id: <user_id>,
      #         name: <name>,
      #         login: <login>,
      #         permission_ids: <permission_ids>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method index(token, letter)
      # @param token [String] a token
      # @param letter [Character] a letter
      def index
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get users
        letter = Input.letter(params[:letter])
        users = letter ? User.find_by_first_letter(letter) : User.find_all

        render json: { users: users }.to_json, status: :ok
      end

      # Returns a specific user.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users/<id>
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
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the user
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get user
        id = Input.int(params[:id])
        user = User.find_id(id)
        render json: { error: "User not found" }.to_json, status: :not_found and return if !user

        render json: { user: user }.to_json, status: :ok
      end

      # Returns a specific user.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users/<id>
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
      #       permission_ids: <permission_ids>,
      #       user_email: <email>,
      #       user_phone: <phone>
      #     }
      #   }
      #
      # @!method show_info(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the user
      def show_info
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get user
        id = Input.int(params[:id])
        user = User.find_id_show_info(id)
        render json: { error: "User not found" }.to_json, status: :not_found and return if !user

        render json: { user: user }.to_json, status: :ok
      end

      # Returns the groups for a specific user.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     groups: {
      #       id: <user_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <created_at>,
      #       updated_at: <updated_at>
      #     },
      #     ...
      #   }
      #
      # @!method groups(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the user
      def groups
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get groups
        id = Input.int(params[:id])
        groups = User.find_id_groups(id)

        render json: { groups: groups }.to_json, status: :ok
      end

      # Create a new user.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/users/create
      #   {
      #     token: <token>
      #     user: {
      #       name: <name>,
      #       login: <login>,
      #       password: <password>,
      #       permission_ids: [ <array_of_permission_ids> ]
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     user: {
      #       id: <user_id>,
      #       name: <name>,
      #       login: <login>,
      #       permission_ids: <permission_ids>
      #     }
      #   }
      #
      # @!method create(token, user)
      # @param token [String] a token
      # @param user [Hash] the user
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read user parameter
        params_user = params[:user] || {}

        # Create user
        user, errors = User.create(params_user)
        render json: { errors: errors }.to_json, status: :ok and return if !user

        render json: { user: user }.to_json, status: :created
      end

      # Update a user's info.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/users/<id>/update_info
      #   {
      #     token: <token>
      #     id: <user_id>,
      #     user: {
      #       name: <name>
      #       email: <email>
      #       phone: <phone>
      #     }
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
      #     }
      #   }
      #
      # @!method update_info(token, id, user)
      # @param token [String] a token
      # @param id [Int] the id of the user
      # @param user [Hash] the user
      def update_info
        # Check token for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # If not oneself then check token for admin permissions
        params_user_id = Input.int(params[:id])
        if response[:user]["id"] != params_user_id
          status, response = check_token_for_permission(Permission.admin_id)
          render json: response.to_json, status: status.to_sym and return if response[:error]
        end

        # get the user
        user = User.find_id(params_user_id)
        return [{ error: 'Invalid' }, :unauthorized] unless user

        params_user = params[:user] || {}
        response, status = user.update_info(params_user)
        render json: response.to_json, status: status
      end

      # Update a user's permissions
      #
      # <b>API Call:</b>
      #   POST: /api/v3/users/<id>/update_permissions
      #   {
      #     token: <token>
      #     id: <user_id>,
      #     user: {
      #       permission_ids: [ <array_of_permission_ids> ]
      #     }
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
      #     }
      #   }
      #
      # @!method update_permissions(token, id, user)
      # @param token [String] a token
      # @param id [Int] the id of the user
      # @param user [Hash] the user
      def update_permissions
        # Check for admin permissions <or> self
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # user who is updating
        by_user_id = response[:user]["id"]

        # get the user
        params_user_id = Input.int(params[:id])
        user = User.find_id(params_user_id)
        return [{ error: 'Invalid' }, :unauthorized] unless user

        params_user = params[:user] || {}
        response, status = user.update_permissions(by_user_id, params_user)
        render json: response.to_json, status: status
      end

      # Set agreement to true for <agreement> = /lab|aquarium/.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/users/<id>/agreements/<agreeement>
      #   {
      #     token: <token>,
      #     id: <user_id>,
      #     agreement: "lab" | "aquarium"
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
      #     }
      #   }
      #
      # @!method agreements(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the user
      def agreements
        # Check token for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # If not oneself then check token for admin permissions
        params_user_id = Input.int(params[:id])
        if response[:user]["id"] != params_user_id
          status, response = check_token_for_permission(Permission.admin_id)
          render json: response.to_json, status: status.to_sym and return if response[:error]
        end

        # get the user
        user = User.find_id(params_user_id)
        render json: { error: 'Invalid' }.to_json, status: :unauthorized and return if !user

        # Update the agreement to true
        UserProfile.set_user_profile(user.id, params[:agreement], true)

        render json: { user: user }.to_json, status: :ok
      end

      # Set preferences for <preference> = /new_samples_private|lab_name/.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/users/<id>/preferences/<preference>
      #   {
      #     token: <token>,
      #     id: <user_id>,
      #     value: <value>
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
      #     }
      #   }
      #
      # @!method preferences(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the user
      def preferences
        # Check token for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # If not oneself then check token for admin permissions
        params_user_id = Input.int(params[:id])
        if response[:user]["id"] != params_user_id
          status, response = check_token_for_permission(Permission.admin_id)
          render json: response.to_json, status: status.to_sym and return if response[:error]
        end

        # get the user
        user = User.find_id(params_user_id)
        render json: { error: 'Invalid' }.to_json, status: :unauthorized and return if !user

        # Read inputs
        new_samples_private = Input.boolean(params[:new_samples_private])
        lab_name = Input.text_field(params[:lab_name])

        # Update the preferences
        UserProfile.set_user_profile(user.id, "new_samples_private", new_samples_private)
        UserProfile.set_user_profile(user.id, "lab_name", lab_name)

        render json: { user: user }.to_json, status: :ok
      end

      ###
      ### FOR USERS/PERMISSIONS PAGES
      ###

      # Returns a filtered / sorted list of users based on permission_ids.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/users/permissions
      #   {
      #     token: <token>,
      #     show[]: <permission_id>,
      #     show[]: <permission_id>,
      #     ...
      #     sort: <sort>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     users: [
      #       {
      #         id: <user_id>,
      #         name: <name>,
      #         login: <login>,
      #         permission_ids: <permission_ids>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method permissions(token, show, sort)
      # @param token [String] a token
      # @param show [Array] the list of permission ids to filter
      # @param sort [String] the sort order
      def permissions
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
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
      # <b>API Call:</b>
      #   POST: /api/v3/users/permissions/update
      #   {
      #     token: <token>,
      #     user_id: <user_id>,
      #     permission_id: <permission_id>,
      #     value: <true/false>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     user: [
      #       {
      #         id: <user_id>,
      #         name: <name>,
      #         login: <login>,
      #         permission_ids: <permission_ids>
      #       }
      #     ]
      #   }
      #
      # @!method update_permission(token, user_id, permission_id, value)
      # @param token [String] a token
      # @param user_id [Int] the id of the user to change
      # @param permission_id [Int] the id of the permission to change
      # @param value [Boolean] the permission setting ( <true/false> or <on/off> or <1/0> )
      def update_permission
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        by_user_id = response[:user]["id"]
        to_user_id = Input.int(params[:user_id])
        to_permission_id = Input.int(params[:permission_id])
        to_value = Input.boolean(params[:value])

        response, status = User.set_permission(by_user_id, to_user_id, to_permission_id, to_value)
        render json: response.to_json, status: status
      end
    end
  end
end
