# frozen_string_literal: true

module Api
  module V3
    # User related api calls
    class ObjectTypesController < ApplicationController
      # Return all handlers plus object_types for the first handler
      #
      # @param token [String] a token
      # @return all handlers plus object_types for the first handler
      def index
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get handlers
        handlers = ObjectType.find_handlers
        render json: { object_types: nil }.to_json, status: :ok and return if handlers.length == 0

        # Get objects of first item in list
        object_types = ObjectType.find_by_handler(handlers[0].handler)

        render json: {
          handlers: handlers,
          handlers[0].handler => {
            object_types: object_types
           }
         }.to_json, status: :ok
      end

      # Return all object_types for a specific handler.
      #
      # @param token [String] a token
      # @param handler [String] the name of the handler
      # @return all object_types for the handler
      def show_handler
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        handler = Input.text(params[:handler])

        # Get object_types
        object_types = ObjectType.find_by_handler(handler)

        render json: {
          handler => {
            object_types: object_types
           }
         }.to_json, status: :ok
      end

      # Create a new object type.
      #
      # @param token [String] a token
      # @param object_type [Hash] the object type
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read sample type parameter
        params_object_type = params[:object_type] || {}

        # Create sample type
        object_type, errors = ObjectType.create(params_object_type)
        render json: { errors: errors }.to_json, status: :ok and return if !object_type

        render json: object_type.to_json, status: :created
      end

      # Update an object type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the object type
      # @param object_type [Hash] the object type
      # @return the sample type
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get sample type
        id = Input.int(params[:id])
        object_type = ObjectType.find_id(id)
        render json: { object_type: nil }.to_json, status: :ok and return if !object_type

        # Read object type parameter
        params_object_type = params[:object_type] || {}

        # Update object type
        # Note: any errors handled automatically and silently
        object_type = object_type.update(params_object_type)

        render json: object_type.to_json, status: :ok
      end

      # Delete an object type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the object type
      # @return a success message
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get object type
        id = Input.int(params[:id])
        object_type = ObjectType.find_id(id)
        render json: { object_type: nil  }.to_json, status: :ok and return if !object_type

        # Delete object type
        object_type.delete

        render json: {
          message: "deleted"
         }.to_json, status: :ok
      end

    end
  end
end
