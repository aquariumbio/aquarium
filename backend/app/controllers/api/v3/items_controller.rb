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
    class ItemsController < ApplicationController
      # Create a new item.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/groups/create
      #   {
      #     token: <token>
      #     item: {
      #       object_type_id: <object_type_id>,
      #       sample_id: <sample_id>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     item: {
      #       id: <item_id>,
      #       location: <location>,
      #       quantity: <quantity>,
      #       object_type_id: <object_type_id>,
      #       inuse: <inuse>,
      #       sample_id: <sample_id>,
      #       data: <data>,
      #       locator_id: <locator_id>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, item)
      # @param token [String] a token
      # @param item [Hash] the item
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read group parameter
        params_item = params[:item] || {}

        # Create group
        item, object_type, errors = Item.create_from(params_item)
        render json: { errors: errors }.to_json, status: :ok and return if !item

        render json: { item: item, object_type: object_type }.to_json, status: :created
      end

      # Returns details for a specific item.
      def show_collection
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = params[:id].to_i
        item, object_type, collection = Item.get_collection(id)

        render json: { item: nil, object_type: nil, collection: nill }.to_json, status: :not_found and return  if !item

        render json: { item: item, object_type: object_type, collection: collection }.to_json, status: :ok
      end

    end
  end
end
