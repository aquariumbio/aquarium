# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Announcement API calls.
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
    class AnnouncementsController < ApplicationController
      # Returns all announcements.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/announcements
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     announcements: [
      #       {
      #         id: <announcement_id>,
      #         title: <title>,
      #         message: <message>,
      #         active: <true/false>,
      #         created_at: <datetime>,
      #         updated_at: <datetime>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method index(token)
      # @param token [String] a token
      def index
        # Check for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get announcements
        announcements = Announcement.find_all

        render json: { announcements: announcements }.to_json, status: :ok
      end

      # Returns a specific announcement.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/announcements/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     announcement: {
      #       id: <announcement_id>,
      #       title: <title>,
      #       message: <message>,
      #       active: <true/false>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the announcement
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get announcement
        id = Input.int(params[:id])
        announcement = Announcement.find_id(id)

        render json: { announcement: announcement }.to_json, status: :ok
      end

      # Create a new announcement.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/announcements/create
      #   {
      #     token: <token>
      #     announcement: {
      #       title: <title>,
      #       message: <message>,
      #       active: <true/false>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 201
      #   {
      #     announcement: {
      #       id: <announcement_id>,
      #       title: <title>,
      #       message: <message>,
      #       active: <true/false>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, announcement)
      # @param token [String] a token
      # @param announcement [Hash] the announcement
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read sample type parameter
        params_announcement = params[:announcement] || {}

        # Create sample type
        announcement, errors = Announcement.create(params_announcement)
        render json: { errors: errors }.to_json, status: :ok and return if !announcement

        render json: { announcement: announcement }.to_json, status: :created
      end

      # Update an announcement.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/announcements/create
      #   {
      #     token: <token>
      #     id: <announcement_id>,
      #     announcement: {
      #       title: <title>,
      #       message: <message>,
      #       active: <true/false>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     announcement: {
      #       id: <announcement_id>,
      #       title: <title>,
      #       message: <message>,
      #       active: <true/false>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, announcement)
      # @param token [String] a token
      # @param id [Int] the id of the announcement
      # @param announcement [Hash] the announcement
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get sample type
        id = Input.int(params[:id])
        announcement = Announcement.find_id(id)
        render json: { announcement: nil }.to_json, status: :ok and return if !announcement

        # Read announcement parameter
        params_announcement = params[:announcement] || {}

        # Update announcement
        announcement, errors = announcement.update(params_announcement)
        render json: { errors: errors }.to_json, status: :ok and return if !announcement

        render json: { announcement: announcement }.to_json, status: :ok
      end

      # Delete an announcement.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/announcements/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Announcement deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the announcement
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get announcement
        id = Input.int(params[:id])
        announcement = Announcement.find_id(id)
        render json: { announcement: nil  }.to_json, status: :ok and return if !announcement

        # Delete announcement
        announcement.delete

        render json: { message: "Announcement deleted" }.to_json, status: :ok
      end

    end
  end
end
