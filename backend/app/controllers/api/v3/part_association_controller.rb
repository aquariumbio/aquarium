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
    class PartAssociationController < ApplicationController
      # Create a new part association.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/groups/create
      #   {
      #     token: <token>
      #     part_association: {
      #       collection_id: <collection_id>,
      #       part_id: <part_id>,
      #       row: <row>,
      #       column: <column>
      #     }
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 201
      #   {
      #     part_association: {
      #       id: <item_id>,
      #       collection_id: <collection_id>,
      #       part_id: <part_id>,
      #       row: <row>,
      #       column: <column>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, item)
      # @param token [String] a token
      # @param part_association [Hash] the part_association
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read group parameter
        params_part_association = params[:params_part_association] || {}

        # Create group
        part_assocation, errors = PartAssocation.create_from(params_part_association)
        render json: { errors: errors }.to_json, status: :ok and return if !item

        render json: { part_association: part_association }.to_json, status: :created
      end

      # Returns details for a specific collection.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/items/collection/36357
      #   {
      #     token: <token>
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
      def show_collection
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = params[:id].to_i
        item, object_type, collection = Item.get_collection(id)

        render json: { item: nil, object_type: nil, collection: nil }.to_json, status: :not_found and return  if !item

        render json: { item: item, object_type: object_type, collection: collection }.to_json, status: :ok
      end

      # Discard an item.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/items/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Item deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the item
      def discard
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.int(params[:id])

        # Get item
        # TODO: should verify that this is an item, not a collection
        item = Item.find_by(id: id)
        render json: { error: "Item not found" }.to_json, status: :not_found and return if !item

        # discard sample
        item.discard

        render json: {
          message: "Item deleted"
        }.to_json, status: :ok
      end

    end
  end
end
