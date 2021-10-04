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
      def create_part
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Add a part
        params_part_association = params[:part_association] || {}

        # Get the sample id
        sample = Sample.find_by(id: Input.int(params_part_association[:sample_id]))
        render json: { part_association: nil }.to_json, status: :not_found and return if !sample

        # Add a part
        # IMPORTANT: OBJECT_TYPE_ID MUST BE WHATEVER IS __PART
        #            NEED TO REVIEW THIS
        item = Item.create ({
          quantity: 1,
          object_type_id: 807,
          sample_id: sample.id
        })

        # Create group
        params_part_association[:part_id] = item.id
        part_association, errors = PartAssociation.create_from(params_part_association)
        render json: { errors: errors }.to_json, status: :ok and return if !part_association

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
