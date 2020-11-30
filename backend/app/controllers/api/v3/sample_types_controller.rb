# frozen_string_literal: true

module Api
  module V3
    # Sample type api calls
    class SampleTypesController < ApplicationController
      # Return all sample types plus details for the first sample type
      #
      # @param token [String] a token
      # @return all sample types plus details for the first sample type
      def index
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get list
        list = SampleType.find_all
        render json: { sample_types: nil,  }.to_json, status: :ok and return if list.length == 0

        # Get details of first sample type in list
        details = SampleType.details(list[0].id)
        details = details.update({ id: list[0].id, name: list[0].name })

        render json: {
          sample_types: list,
          first: details
         }.to_json, status: :ok
      end

      # Return details for a specific sample type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the sample type
      # @return the sample type
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.int(params[:id])

        # Get sample type
        sample_type = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample_type

        # Get details for sample type
        details = SampleType.details(id)
        details = details.update({ id: id, name: sample_type.name, description: sample_type.description })

        render json: {
          sample_type: details
        }.to_json, status: :ok
      end

      # Create a new sample type.
      #
      # @param token [String] a token
      # @param sample_type [Hash] the sample_type
      # @return the sample type
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read sample type parameter
        params_sample_type = params[:sample_type] || {}

        # Create sample type
        sample_type, errors = SampleType.create(params_sample_type)
        render json: { errors: errors }.to_json, status: :ok and return if !sample_type

        render json: sample_type.to_json, status: :created
      end

      # Update a sample type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the sample type
      # @param sample_type [Hash] the sample type
      # @return the sample type
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get sample type
        id = Input.int(params[:id])
        sample_type = SampleType.find_id(id)
        render json: { sample_type: nil }.to_json, status: :ok and return if !sample_type

        # Read sample type parameter
        params_sample_type = params[:sample_type] || {}

        # Update sample type
        # Note: any errors handled automatically and silently
        sample_type = sample_type.update(params_sample_type)

        render json: sample_type.to_json, status: :ok
      end

      # Delete a sample type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the sample type
      # @return a success message
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.int(params[:id])

        # Get sample type
        sample = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample

        # Delete sample type and related items that do not have foreign keys
        sample.delete_sample_type

        render json: {
          message: "deleted"
         }.to_json, status: :ok
      end

    end
  end
end
