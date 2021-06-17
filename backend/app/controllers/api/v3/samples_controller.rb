# frozen_string_literal: true

# @api api.v3
module Api
  module V3
    # Sample API calls
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
    class SamplesController < ApplicationController
      # INITIALIZE SEARCH TEXT -
      # TODO: INITIALIZE WHEN MIGRATE
      # TODO: MOVE TO WHEN CREATE / UPDATE NAME / DESCRIPTION / FIELD VALUES FOR EACH SAMPLE
      def set_search_text
        sql ="select s.id, s.name, s.description, st.name as 'sample_type' from samples s inner join sample_types st on st.id = s.sample_type_id"
        samples = Sample.find_by_sql sql

        samples.each do |sample|
          text = []

          # sample name + description
          text << sample.name if sample.name.to_s.length != 0
          text << sample.description if sample.description.to_s.length != 0
          text << sample.sample_type if sample.sample_type.to_s.length != 0

          # field values
          sql= "select * from view_samples where id =#{sample.id} order by ft_sort"
          temp = Sample.find_by_sql sql
          temp.each do |t|
            if t.ft_id
              text << t.ft_name if t.ft_name.to_s.length != 0
              text << t.fv_value if t.fv_value.to_s.length != 0
              text << t.child_sample_name if t.child_sample_name.to_s.length != 0
            end
          end
          sample.search_text = text.join(' ')

          # item ids
          sql = "
           select if(collection_id, collection_id, item_id) as 'iid'
           from view_inventories
           where id = #{sample.id}
           order by collection_id is not null, collection_type, item_type, collection_id, item_id
          "
          temp = Sample.find_by_sql sql
          iids = "."
          tid = 0
          temp.each do |t|
            if t.iid != tid
              tid = t.iid
              iids += "#{tid}."
            end
          end
          sample.item_ids = iids
          sample.save
        end
      end

      # INITIALIZE FIELD_TYPE_ID IN FIELD_VALUES TABLE
      # (THESE ARE MOSTLY NULL, THEY SHOULD BE THE IDS)
      def set_field_type_ids
        # NOTE: run in background in case it times out
        background = fork do
          # Get field type ids by sample type
          sql = "
            select ft.id, ft.name, ft.parent_id, ft.parent_class
            from field_types ft
            where ft.parent_class = 'SampleType'
          "
          list = FieldType.find_by_sql sql

          list.each do |ll|
            # get list of field values that match this field type (by sample_type_id and field_type_name)
            # NOTE: want to sanitize ll.name
            sql = "
              select fv.id
              from field_values fv
              inner join samples s on s.id = fv.parent_id and fv.parent_class = 'Sample'
              where s.sample_type_id = #{ll.parent_id} and fv.name = '#{ll.name}'
            "
            temp = FieldValue.find_by_sql sql
            ids = [0]
            temp.each do |t|
              ids << t.id
            end

            sql = "update field_values set field_type_id = #{ll.id} where id in (#{ids.join(',')})"
            FieldValue.connection.execute sql
          end
        end
        Process.detach(background)

        # NOTE:  SQL Query to get field values that could not be mapped
        # "select * from field_values where parent_class = 'Sample' and field_type_id is null"

      end


      # Searches samples
      #
      # <b>API Call:</b>
      #   GET: /api/v3/sample_types
      #   {
      #     token: <token>,
      #     page: <page>,
      #     words: <words>,
      #     sample_type_id: <sample_type_id>,
      #     user_id: <user_id>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     page: <page>,
      #     count: <countt>,
      #     pages: <pages>,
      #     samples: [
      #       {
      #         id: <sample_id>,
      #         name: <name>,
      #         description: <description>,
      #         sample_type: <sample_type>,
      #         user_name: <user_name>,
      #         login: <login>,
      #         type: <type>,
      #         created_at: <created_at>,
      #         item_ids: [
      #           <item_id>,
      #           ...
      #         ],
      #         fields: [
      #           {
      #             type: <type>,
      #             name: <name>,
      #             value: <value>,
      #             child_sample_id: <child_sample_id,
      #             child_sample_name: <child_sample_name>
      #           },
      #           ...
      #         ]
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method index(token, page, words, sample_tpye_id, user_id)
      # @param token [String] a token
      # @param page [Int] the page to return
      # @param words [String] search words / sample:<sample_id> / item:<item_id>
      # @param sample_type_id [Int] the id of the sample type to search
      # @param user_id [Int] the id of the sample owner to search
      def index
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        page = Input.int(params[:page])
        words = Input.text(params[:words])
        sample_type_id = Input.int(params[:sample_type_id])
        user_id = Input.int(params[:user_id])

        results = Sample.search({
          page: page,
          words: words,
          sample_type_id: sample_type_id,
          user_id: user_id
        })
        render json: results.to_json, status: :ok

      end

      # Searches samples
      #
      # <b>API Call:</b>
      #   GET: /api/v3/samples/search
      #   {
      #     token: <token>,
      #     text: <text>,
      #     sample_type_ids: <sample_type_ids>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     samples: [
      #       {
      #         id: <sample_id>,
      #         name: <name>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method index(token, words, sample_type_ids,)
      # @param token [String] a token
      # @param text [String] search text / sample:<sample_id>
      # @param sample_type_id [Array] the ids of the sample types to search
      def quick_search
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        text = Input.text(params[:text])
        sample_type_ids = Input.text(params[:sample_type_ids])

        results = Sample.quick_search({
          text: text,
          sample_type_ids: sample_type_ids
        })
        render json: results.to_json, status: :ok

      end

      # Returns details for a specific sample.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/sample_types/<id>
      #   {
      #     token: <token>
      #     id: <id>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     sample: {
      #       id: <___>,
      #       name: <___>,
      #       description: <___>,
      #       sample_type: <___>,
      #       user_name: <___>,
      #       login: <___>,
      #       type: <___>,
      #       created_at: <___>,
      #       item_ids: [
      #         <item_id>,
      #         ...
      #       ],
      #       fields: [
      #         {
      #           type: string,
      #           name: Restriction Enzyme(s),
      #           value: ,
      #           child_sample_id: null,
      #           child_sample_name: null
      #         },
      #         ...
      #       ]
      #     }
      #   }
      #
      # @!method show(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the sample
      def show
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.int(params[:id])
        sample, inventory = Sample.get_sample(id)

        render json: { sample: nil, inventory: nil }.to_json, status: :not_found and return  if !sample

        render json: { sample: sample, inventory: inventory }.to_json, status: :ok
      end

      # Create a new sample.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/samples/create
      #   {
      #     token: <token>,
      #     sample: {
      #       name: <name>,
      #       description: <description>,
      #       field_types: [
      #         {
      #           name: <name>,
      #           ftype: <ftype>,
      #           required: <required>,
      #           array: <array>,
      #           choices: <choices>,
      #           allowable_field_types: [ # (only used when ftype = "sample")
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
      #   STATUS_CODE: 201
      #   {
      #     sample: {
      #       id: <sample_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method create(token, sample)
      # @param token [String] a token
      # @param sample [Hash] the sample
      def create
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read sample parameter
        params_sample = params[:sample] || {}

puts ">>> params_sample"
puts params_sample.to_json
puts ">>>"

return "create sample"
        # Create sample
#         sample, errors = SampleType.create_from(params_sample)
#         render json: { errors: errors }.to_json, status: :ok and return if !sample
#
#         render json: { sample: sample }.to_json, status: :created
      end

      # Update a sample.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/samples/<id>/update
      #   {
      #     token: <token>
      #     id: <sample_id>,
      #     sample: {
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
      #           allowable_field_types: [ # (only used when ftype = "sample")
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
      #   STATUS_CODE: 200
      #   {
      #     sample: {
      #       id: <sample_id>,
      #       name: <name>,
      #       description: <description>,
      #       created_at: <datetime>,
      #       updated_at: <datetime>
      #     }
      #   }
      #
      # @!method update(token, id, sample)
      # @param token [String] a token
      # @param id [Int] the id of the sample
      # @param sample [Hash] the sample
      def update
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get sample
        id = Input.int(params[:id])
        sample = Sample.find_id(id)
        render json: { error: "Sample not found" }.to_json, status: :not_found and return if !sample

        # Read sample parameter
        params_sample = params[:sample] || {}

puts ">>> params_sample"
# params_sample.each do |k,v|
# puts "#{k}: #{v}"
# end
# puts ">>>"

        # Update sample
        sample, errors = sample.update_with(params_sample)
puts ">>> ..."
        render json: { errors: errors }.to_json, status: :ok and return if !sample
puts ">>> OK"

        render json: { sample: sample }.to_json, status: :ok
      end

      # Delete a sample.
      #
      # <b>API Call:</b>
      #   POST: /api/v3/samples/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Sample deleted"
      #   }
      #
      # @!method delete(token, id)
      # @param token [String] a token
      # @param id [Int] the id of the sample
      def delete
        # Check for admin permissions
        status, response = check_token_for_permission(Permission.admin_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.int(params[:id])

        # Get sample
        sample = Sample.find_id(id)
        render json: { error: "Sample not found" }.to_json, status: :not_found and return if !sample

return "delete sample"
        # Delete sample and related items that do not have foreign keys
#         sample.delete_sample
#
#         render json: {
#           message: "Sample deleted"
#         }.to_json, status: :ok
      end
    end
  end
end
