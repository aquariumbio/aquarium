# frozen_string_literal: true

module Api
  module V3
    # Sample type api calls
    class SampleTypesController < ApplicationController
      # Return all sample types.
      #
      # @param token [String] a token
      #
      # @return all sample types
      def index
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get list
        list = SampleType.find_all
        render json: { sample_types: nil,  }.to_json, status: :ok and return if list.length == 0

        # Get details of first item in list
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
      # @param id [id] the id of the sample type
      #
      # @return the sample type
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.number(params[:id])

        # Get item
        sample_type = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample_type

        # Get details of first item in list
        details = SampleType.details(id)
        details = details.update({ id: id, name: sample_type.name, description: sample_type.description })

        render json: {
          sample_type: details
         }.to_json, status: :ok
      end

      # Create a new sample type.
      #
      # @param token [String] a token
      # @param name [name] the name of the sample type
      # @param description [description] the description of the sample type
      # @param field_types [hash] the :field_types to be used for the allowable_field_types
      #
      # @return the sample type
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        sample_type, errors = SampleType.create(params)
        render json: { errors: errors }.to_json, status: :ok and return if !sample_type

        render json: sample_type.to_json, status: :created

      end

      # Update a sample type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the sample type
      # @param name [name] the name of the sample type
      # @param description [description] the description of the sample type
      # @param field_types [hash] the :field_types to be used for the allowable_field_types
      #
      # @return the sample type
      def update
         # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.number(params[:id])

        # Get item
        sample_type = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample_type

        # Update sample
        # Note: any errors handled automatically and silently
        sample_type = sample_type.update(params)

        render json: sample_type.to_json, status: :ok
      end

      # Delete a sample type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the sample type
      #
      # @return a success message
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.number(params[:id])

        # Get item
        sample = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample

        # Delete item and related items without foreign keys
        sample.delete_sample_type

        render json: {
          message: "deleted"
         }.to_json, status: :ok

      end

    end
  end
end
