# frozen_string_literal: true

module Api
  module V3
    # User related api calls
    class AnnouncementsController < ApplicationController
      # Return all announcements
      #
      # @param token [String] a token
      # @return all announcements
      def index
        # Check for any permissions
        status, response = check_token_for_permission
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get announcements
        announcements = Announcement.find_all

        render json: {
          announcements: announcements
         }.to_json, status: :ok
      end

      # Return a specific announcement
      #
      # @param token [String] a token
      # @param id [Int] the id of the announcement
      # @return the announcement
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get announcement
        id = Input.int(params[:id])
        announcement = Announcement.find_id(id)

        render json: {
          announcement: announcement
        }.to_json, status: :ok
      end

      # Create a new announcement.
      #
      # @param token [String] a token
      # @param announcement [Hash] the announcement
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(1)
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
      # @param token [String] a token
      # @param id [Int] the id of the announcement
      # @param announcement [Hash] the announcement
      # @return the sample type
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(1)
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
      # @param token [String] a token
      # @param id [Int] the id of the announcement
      # @return a success message
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get announcement
        id = Input.int(params[:id])
        announcement = Announcement.find_id(id)
        render json: { announcement: nil  }.to_json, status: :ok and return if !announcement

        # Delete announcement
        announcement.delete

        render json: {
          message: "deleted"
         }.to_json, status: :ok
      end

    end
  end
end
