# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Group API calls.
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
    class GroupsController < ApplicationController
      # Returns all groups / all groups beginning with <letter>.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/groups
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     groups: [
      #       {
      #         id: <group_id>,
      #         name: <name>,
      #         description: <description>,
      #         created_at: <datetime>,
      #         updated_at: <datetime>
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

        # Get groups
        letter = Input.letter(params[:letter])
        groups = letter ? Group.find_by_first_letter(letter) : Group.find_all

        render json: { groups: groups }.to_json, status: :ok
      end

      # Returns a specific group.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/groups/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     group: {
      #       id: <group_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #     members: [
      #       {
      #         id: <user_id>,
      #         name: <name>,
      #         login: <login>,
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the group
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get group
        id = Input.int(params[:id])
        group = Group.find_id(id)
        render json: { error: "Group not found" }.to_json, status: :not_found and return if !group

        # Get members
        members = Membership.group_members(id)

        render json: { group: group, members: members }.to_json, status: :ok
      end

      # Create a new group.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/groups/create
      #   {
      #     token: <token>
      #     group: {
      #       title: <name>,
      #       message: <description>,
      #       active: <true/false>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     group: {
      #       id: <group_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, group)
      # @param token [String] a token
      # @param group [Hash] the group
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read group parameter
        params_group = params[:group] || {}

        # Create group
        group, errors = Group.create_from(params_group)
        render json: { errors: errors }.to_json, status: :ok and return if !group

        render json: { group: group }.to_json, status: :created
      end

      # Update a group.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/groups/create
      #   {
      #     token: <token>
      #     id: <group_id>,
      #     group: {
      #       name: <name>,
      #       description: <description>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     group: {
      #       id: <group_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, group)
      # @param token [String] a token
      # @param id [Int] the id of the group
      # @param group [Hash] the group
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get group
        id = Input.int(params[:id])
        group = Group.find_id(id)
        render json: { error: "Group not found" }.to_json, status: :not_found and return if !group

        # Read group parameter
        params_group = params[:group] || {}

        # Update group
        group, errors = group.update(params_group)
        render json: { errors: errors }.to_json, status: :ok and return if !group

        render json: { group: group }.to_json, status: :ok
      end

      # Delete a group.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/groups/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Group deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the group
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get group
        id = Input.int(params[:id])
        group = Group.find_id(id)
        render json: { error: "Group not found" }.to_json, status: :not_found and return if !group

        # Delete group
        group.delete

        render json: { message: "Group deleted" }.to_json, status: :ok
      end

      # Add a membership.
      #
      # <b>API Call:</b>
      #   POST: 'api/v3/groups/:id/create_membership
      #   {
      #     token: <token>
      #     id: <group_id>,
      #     user_id: <user_id>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     membership: {
      #       id: <group_id>,
      #       user_id: <user_id>,
      #       group_id: <group_id>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create_membership(token, id, user_id)
      # @param token [String] a token
      # @param id [Int] the id of the group
      # @param user_id [Int] the user_id
      def create_membership
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get group
        id = Input.int(params[:id])
        group = Group.find_id(id)
        render json: { error: "Group not found" }.to_json, status: :not_found and return if !group

        # Get user
        user_id = Input.int(params[:user_id])
        user = User.find_id(user_id)
        render json: { error: "Membership not found" }.to_json, status: :not_found and return if !user

        # Add membership
        membership = Membership.find(id, user_id)
        if !membership
          membership = Membership.new({
                                        group_id: id,
                                        user_id: user_id
                                      })
          membership.save
        end
        render json: { membership: membership }.to_json, status: :ok
      end

      # Delete a membership.
      #
      # <b>API Call:</b>
      #   POST: 'api/v3/groups/<id>/delete_membership/<user_id>
      #   {
      #     token: <token>
      #     id: <group_id>,
      #     user_id: <user_id>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Membership deleted"
      #   }
      #
      # @!method delete_membership(token, id, user_id)
      # @param token [String] a token
      # @param id [Int] the id of the group
      # @param user_id [Int] the user_id
      def delete_membership
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get membership
        group_id = Input.int(params[:id])
        user_id = Input.int(params[:user_id])
        membership = Membership.find(group_id, user_id)
        render json: { error: "Membership not found" }.to_json, status: :not_found and return if !membership

        # Delete membership
        membership.delete

        render json: { message: "Membership deleted" }.to_json, status: :ok
      end
    end
  end
end
