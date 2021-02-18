# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Object Type API calls
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
    class ObjectTypesController < ApplicationController
      # Returns all handlers plus object_types for the first handler
      #
      # <b>API Call:</b>
      #   GET: /api/v3/object_types
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     handlers: [
      #       {
      #         id: <null>,
      #         handler: <handler>
      #       },
      #       ...
      #     ]
      #     <handler>: {
      #       object_types: [
      #         {
      #           id: <id>,
      #           name: <name>,
      #           description: <description>,
      #           min: <min>,
      #           max: <max>,
      #           handler: <handler>,
      #           safety: <safety>,
      #           cleanup: <cleanup>,
      #           data: <data>,
      #           vendor: <vendor>,
      #           created_at: <datetime>,
      #           updated_at: <datetime>,
      #           unit: <unit>,,
      #           cost: <cost>,
      #           release_method: <release_method>,
      #           release_description: <release_description>,
      #           sample_type_id: <sample_type_id>,
      #           image: <image>,
      #           prefix: <prefix>,
      #           rows: <rows>,
      #           columns: <columns>
      #         },
      #         ...
      #       ]
      #     }
      #   }
      #
      # @!method index(token)
      # @param token [String] a token
      def index
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
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

      # Returns all object_types for a specific handler.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/object_types/handler/<handler>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     <handler>: {
      #       object_types: [
      #         {
      #           id: <id>,
      #           name: <name>,
      #           description: <description>,
      #           min: <min>,
      #           max: <max>,
      #           handler: <handler>,
      #           safety: <safety>,
      #           cleanup: <cleanup>,
      #           data: <data>,
      #           vendor: <vendor>,
      #           created_at: <datetime>,
      #           updated_at: <datetime>,
      #           unit: <unit>,,
      #           cost: <cost>,
      #           release_method: <release_method>,
      #           release_description: <release_description>,
      #           sample_type_id: <sample_type_id>,
      #           image: <image>,
      #           prefix: <prefix>,
      #           rows: <rows>,
      #           columns: <columns>
      #         },
      #         ...
      #       ]
      #     }
      #   }
      #
      # @!method show_handler(token, handler)
      # @param token [String] a token
      # @param handler [String] the name of the handler
      def show_handler
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get object_types
        handler = Input.text(params[:handler])
        object_types = ObjectType.find_by_handler(handler)

        render json: {
          handler => {
            object_types: object_types
           }
         }.to_json, status: :ok
      end

      # Returns a specific object type
      #
      # <b>API Call:</b>
      #   GET: /api/v3/object_types/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     object_type: {
      #       id: <id>,
      #       name: <name>,
      #       description: <description>,
      #       min: <min>,
      #       max: <max>,
      #       handler: <handler>,
      #       safety: <safety>,
      #       cleanup: <cleanup>,
      #       data: <data>,
      #       vendor: <vendor>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>,
      #       unit: <unit>,,
      #       cost: <cost>,
      #       release_method: <release_method>,
      #       release_description: <release_description>,
      #       sample_type_id: <sample_type_id>,
      #       image: <image>,
      #       prefix: <prefix>,
      #       rows: <rows>,
      #       columns: <columns>
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the object type
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get object type
        id = Input.int(params[:id])
        object_type = ObjectType.find_id(id)

        render json: {
          object_type: object_type
        }.to_json, status: :ok
      end

      # Create a new object type.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/object_types/create
      #   {
      #     token: <token>,
      #     object_type: {
      #       name: <name>,
      #       description: <description>,
      #       prefix: <prefix>,
      #       min: <min>,
      #       max: <max>,
      #       unit: <unit>,
      #       cost: <cost>,
      #       handler: <handler>,
      #       release_method: <release_method>,
      #       rows: <rows>,                               # (for handler == "collection")
      #       columns: <columns>,                         # (for handler == "collection")
      #       sample_type_id: <sample_type_id>,           # (for handler == "sample_container")
      #       release_description: <release_description>,
      #       safety:<safety>,
      #       cleanup: <cleanup>,
      #       data: <data>,
      #       vendor: <vendor>,
      #       image: <image>                              # (TODO)
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 201
      #   {
      #     object_type: {
      #       id: <id>,
      #       name: <name>,
      #       description: <description>,
      #       min: <min>,
      #       max: <max>,
      #       handler: <handler>,
      #       safety: <safety>,
      #       cleanup: <cleanup>,
      #       data: <data>,
      #       vendor: <vendor>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>,
      #       unit: <unit>,,
      #       cost: <cost>,
      #       release_method: <release_method>,
      #       release_description: <release_description>,
      #       sample_type_id: <sample_type_id>,
      #       image: <image>,
      #       prefix: <prefix>,
      #       rows: <rows>,
      #       columns: <columns>
      #     }
      #   }
      #
      # @!method create(token, object_type)
      # @param token [String] a token
      # @param object_type [Hash] the object type
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read object type parameter
        params_object_type = params[:object_type] || {}

        # Create object type
        object_type, errors = ObjectType.create(params_object_type)
        render json: { errors: errors }.to_json, status: :ok and return if !object_type

        render json: { object_type: object_type }.to_json, status: :created
      end

      # Update an object type.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/object_types/<id>/update
      #   {
      #     token: <token>
      #     id: <object_type_id>,
      #     object_type: {
      #       name: <name>,
      #       description: <description>,
      #       prefix: <prefix>,
      #       min: <min>,
      #       max: <max>,
      #       unit: <unit>,
      #       cost: <cost>,
      #       handler: <handler>,
      #       release_method: <release_method>,
      #       rows: <rows>,                               # (for handler == "collection")
      #       columns: <columns>,                         # (for handler == "collection")
      #       sample_type_id: <sample_type_id>,           # (for handler == "sample_container")
      #       release_description: <release_description>,
      #       safety:<safety>,
      #       cleanup: <cleanup>,
      #       data: <data>,
      #       vendor: <vendor>,
      #       image: <image>                              # (TODO)
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     object_type: {
      #       id: <id>,
      #       name: <name>,
      #       description: <description>,
      #       min: <min>,
      #       max: <max>,
      #       handler: <handler>,
      #       safety: <safety>,
      #       cleanup: <cleanup>,
      #       data: <data>,
      #       vendor: <vendor>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>,
      #       unit: <unit>,,
      #       cost: <cost>,
      #       release_method: <release_method>,
      #       release_description: <release_description>,
      #       sample_type_id: <sample_type_id>,
      #       image: <image>,
      #       prefix: <prefix>,
      #       rows: <rows>,
      #       columns: <columns>
      #     }
      #   }
      #
      # @!method update(token, id, object_type)
      # @param token [String] a token
      # @param id [Int] the id of the object type
      # @param object_type [Hash] the object type
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get object type
        id = Input.int(params[:id])
        object_type = ObjectType.find_id(id)
        render json: { object_type: nil }.to_json, status: :ok and return if !object_type

        # Read object type parameter
        params_object_type = params[:object_type] || {}

        # Update object type
        # Note: any errors handled automatically and silently
        object_type = object_type.update(params_object_type)

        render json:  { object_type: object_type }.to_json, status: :ok
      end

      # Delete an object type.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/object_types/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Object type deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the object type
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get object type
        id = Input.int(params[:id])
        object_type = ObjectType.find_id(id)
        render json: { object_type: nil  }.to_json, status: :ok and return if !object_type

        # Delete object type
        object_type.delete

        render json: {
          message: "Object type deleted"
         }.to_json, status: :ok
      end

    end
  end
end
