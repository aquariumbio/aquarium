# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Sample Type API calls
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
    class SampleTypesController < ApplicationController
      # Returns all sample types plus details for the first sample type
      #
      # <b>API Call:</b>
      #   GET: /api/v3/sample_types
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     sample_types: [
      #       {
      #         id: <sample_type_id>,
      #         name: <name>,
      #         description: <description>,
      #         created_at: <datetime>,
      #         updated_at: <datetime>
      #       },
      #       ...
      #     ]
      #     first: {
      #       id: <sample_type_id>,
      #       name: <name>,
      #       inventory: <inventory>,
      #       field_types: [
      #         {
      #           id: <field_type_id>,
      #           parent_id: <parent_id>,
      #           name: <name>,
      #           ftype: <ftype>,
      #           choices: <choices>,
      #           array: <array>,
      #           required: <required>,
      #           created_at: <datetime>,
      #           updated_at: <dateime>,
      #           parent_class: <parent_class>,
      #           role: <role>,
      #           part: <part>,
      #           routing: <routing>,
      #           preferred_operation_type_id: <preferred_operation_type_id>,
      #           preferred_field_type_id: <preferred_field_type_id>,
      #           allowable_field_types: [
      #             {
      #               id: <allowable_field_type_id>,
      #               field_type_id: <field_type_id>,
      #               sample_type_id: <sample_type_id>,
      #               name: <name>
      #             },
      #             ...
      #           ]
      #         },
      #       ],
      #       object_types: [
      #         {
      #           id: <object_type_id>,
      #           name: <name>,
      #           description: <description>,
      #           min: <min>,
      #           max: <max>,
      #           handler: <handler>,
      #           safety:<safety>,
      #           cleanup: <cleanup>,
      #           data: <data>,
      #           vendor: <vendor>,
      #           created_at: <datetime>,
      #           updated_at: <dateime>,
      #           unit: <unit>,
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
      #       ],
      #     }
      #   }
      #
      # @!method index(token)
      # @param token [String] a token
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

      # Returns details for a specific sample type.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/sample_types/<id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     sample_type: {
      #       id: <sample_type_id>,
      #       name: <name>,
      #       inventory: <inventory>,
      #       field_types: [
      #         {
      #           id: <field_type_id>,
      #           parent_id: <parent_id>,
      #           name: <name>,
      #           ftype: <ftype>,
      #           choices: <choices>,
      #           array: <array>,
      #           required: <required>,
      #           created_at: <datetime>,
      #           updated_at: <dateime>,
      #           parent_class: <parent_class>,
      #           role: <role>,
      #           part: <part>,
      #           routing: <routing>,
      #           preferred_operation_type_id: <preferred_operation_type_id>,
      #           preferred_field_type_id: <preferred_field_type_id>,
      #           allowable_field_types: [
      #             {
      #               id: <allowable_field_type_id>,
      #               field_type_id: <field_type_id>,
      #               sample_type_id: <sample_type_id>,
      #               name: <name>
      #             },
      #             ...
      #           ]
      #         },
      #       ],
      #       object_types: [
      #         {
      #           id: <object_type_id>,
      #           name: <name>,
      #           description: <description>,
      #           min: <min>,
      #           max: <max>,
      #           handler: <handler>,
      #           safety:<safety>,
      #           cleanup: <cleanup>,
      #           data: <data>,
      #           vendor: <vendor>,
      #           created_at: <datetime>,
      #           updated_at: <dateime>,
      #           unit: <unit>,
      #           cost: <cost>,
      #           release_method: <release_method>,
      #           release_description: <release_description>,
      #           sample_type_id: <sample_type_id>,
      #           image: <image>,
      #           prefix: <prefix>,
      #           rows: <rows>,
      #           columns: <columns>
      #         }
      #       }
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the sample type
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
      # <b>API Call:</b>
      #   GET: /api/v3/sample_types/create
      #   {
      #     token: <token>,
      #     sample_type: {
      #       name: <name>,
      #       description: <description>,
      #       field_types: [
      #         {
      #           name: <name>,
      #           ftype: <ftype>,
      #           required: <required>,
      #           array: <array>,
      #           choices: <choices>,
      #           allowable_field_types: [             # (for ftype == "sample")
      #             {
      #               sample_type_id: <sample_type_id>
      #             },
      #             ...
      #           ]
      #         },
      #         ...
      #       ]
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 201
      #   {
      #     sample_type: {
      #       id: <sample_type_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, sample_type)
      # @param token [String] a token
      # @param sample_type [Hash] the sample_type
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read sample type parameter
        params_sample_type = params[:sample_type] || {}

        # Create sample type
        sample_type, errors = SampleType.create(params_sample_type)
        render json: { errors: errors }.to_json, status: :ok and return if !sample_type

        render json: { sample_type: sample_type }.to_json, status: :created
      end

      # Update a sample type.
      #
      # @param token [String] a token
      # @param id [Int] the id of the sample type
      # @param sample_type [Hash] the sample type
      # @return the sample type

      # Update an sample_type.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/sample_types/<id>/update
      #   {
      #     token: <token>
      #     id: <sample_type_id>,
      #     sample_type: {
      #       name: <name>,
      #       description: <description>,
      #       field_types: [
      #         {
      #           id: <field_type_id>,
      #           name: <name>,
      #           ftype: <ftype>,
      #           required: <required>,
      #           array: <array>,
      #           choices: <choices>,
      #           allowable_field_types: [             # (for ftype == "sample")
      #             {
      #               id: <allowable_field_type_id>,
      #               sample_type_id: <sample_type_id>
      #             },
      #             ...
      #           ]
      #         },
      #         ...
      #       ]
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS CODE: 200
      #   {
      #     sample_type: {
      #       id: <sample_type_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, sample_type)
      # @param token [String] a token
      # @param id [Int] the id of the sample_type
      # @param sample_type [Hash] the sample_type
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

        render json: { sample_type: sample_type }.to_json, status: :ok
      end

      # Delete a sample type.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/sample_types/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Sample type deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the sample type
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
          message: "Sample type deleted"
         }.to_json, status: :ok
      end

    end
  end
end
