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

        sql = "select * from view_samples where id = #{id} order by ft_sort, ft_name, fv_id"
        sample_data = Sample.find_by_sql sql
        render json: { sample: nil }.to_json, status: :not_found and return if !sample_data

        # initialize new_sample
        this_sample = sample_data[0]
        sids = this_sample.item_ids
        sample = {
          id: this_sample.id,
          name: this_sample.name,
          description: this_sample.description,
          sample_type: this_sample.sample_type.upcase,
          user_name: this_sample.user_name,
          login: this_sample.login,
          type: this_sample.ft_type,
          created_at: this_sample.created_at,
          item_ids: sids[1,sids.length-2].to_s.split("."),
          fields: []
        }

        # loop through results and create objects to pass to the view
        sample_data.each do |s|
          sample[:fields] << {type: s.ft_type, name: s.ft_name, value: s.fv_value, child_sample_id: s.child_sample_id, child_sample_name: s.child_sample_name}
        end

        # get items + collections from inventory
        # NOTES:
        # - collection_id could appear multilpe times
        sql = "
          select *
          from view_inventories
          where id = #{id}
          order by collection_id is not null, collection_type, item_type, collection_id, item_id
        "
        inventory_data = Sample.find_by_sql sql

        # create hash of items / collections
        # NOTES:
        # - single row for items
        # - multiple rows for collections (one for each instance in the collection)
        # - create empty array for data_associations (key_values)
        # - counts for type_id (either item or collection)
        ids = [0]
        inv = {}
        this_id = nil
        this_data = nil
        inventory_data.each do |s|
          id = s.collection_id || s.item_id
          if id != this_id
            this_id = id
            if s.collection_id
              ids << s.collection_id
              this_data = {
                item_id: this_id,
                type_id: s.collection_type_id,
                type: s.collection_type,
                location: s.collection_location,
                date: s.collection_date,
                collections: [{row: s.row, column: s.column}],
                key_values: []
              }
            else
              ids << s.item_id
              this_data = {
                item_id: this_id,
                type_id: s.item_type_id,
                type: s.item_type,
                location: s.item_location,
                date: s.item_date,
                key_values: []
              }
            end
          else
            this_data[:collections] << {row: s.row, column: s.column}
          end
          inv = inv.update({this_id => this_data})
        end

        # get data assocations for items/collections
        # NOTES:
        # - for collection ids, sometimes the parent_class is an item, sometimes it is a collection
        #   (see sample 36319 and sample 36382)
        sql = "
          select da.*, u.upload_file_name, u.upload_content_type
          from data_associations da
          left join uploads u on u.id = da.upload_id
          where parent_id in (#{ids.join(',')}) and parent_class in ('Item', 'Collection')
          order by parent_id, updated_at desc
        "
        data_associations = DataAssociation.find_by_sql sql

        # loop through data_associations and set values
        # NOTES
        # - if multiple parent_id / parent_class / key then only take the latest
        this_parent_id = nil
        this_parent_class = nil
        this_key = nil
        data_associations.each do |da|
          if this_parent_id != da.parent_id || this_parent_class != da.parent_class || this_key != da.key
            this_parent_id = da.parent_id
            this_parent_class = da.parent_class
            this_key = da.key

            # add data_associations
            inv[this_parent_id][:key_values] << {uid: da.id, key: this_key, object: da.object, upload_id: da.upload_id, upload_file_name: da.upload_file_name, upload_content_type: da.upload_content_type}
          end
        end

        # roll up lists
        wip = {}
        this_type_id = nil
        inv.each do |k,v|
          if this_id != v[:type_id]
            this_id = v[:type_id]
            wip = wip.update({ this_id => { type_id: this_id, type: v[:type], count_inventory: 0, count_deleted: 0, data: [] } })
          end
          wip[this_id][:data] << v
          if v[:location] == 'deleted'
            wip[this_id][:count_deleted] += 1
          else
            wip[this_id][:count_inventory] += 1
          end
        end

        # only send data
        inventory = []
        wip.each do |k,v|
          inventory << v
        end

        render json: { sample: sample, inventory: inventory }.to_json, status: :ok
      end

    end
  end
end

# # TABLES
# samples
#   search_text
#   item_ids
#
# field_type_sorts
#   id
#   ftype (string, number, url, sample)
#   sort (1, 2, 3, 4)
#
# # VIEWS
#
# # VIEW_SAMPLES => BASED ON SAMPLES
# ;
# create view view_samples as
# select s.id, s.name, s.description, s.created_at, s.item_ids,
# st.name as 'sample_type',
# u.name as 'user_name', u.login,
# ft.id as 'ft_id',
# ft.ftype as 'ft_type',
# fts.sort as 'ft_sort',
# ft.name as 'ft_name',
# fv.id as 'fv_id',
# fv.value as 'fv_value',
# fv.child_sample_id,
# ss.name as 'child_sample_name'
# from samples s
# inner join sample_types st on st.id = s.sample_type_id
# inner join users u on u.id = s.user_id
# left join field_types ft on ft.parent_id = s.sample_type_id and ft.parent_class = 'SampleType'
# left join field_type_sorts fts on fts.ftype = ft.ftype
# left join field_values fv on fv.parent_id = s.id and fv.parent_class = 'Sample' and fv.name = ft.name
# left join samples ss on ss.id = fv.child_sample_id
# ;
#
# # VIEW_INVENTORIES => BASED ON SAMPLES
#
# create view view_inventories as
# select s.id,
# i.id as 'item_id', i.location as 'item_location', i.created_at as 'item_date',
# ot.id as 'item_type_id', ot.name as 'item_type',
# pa.collection_id, pa.row, pa.column,
# ii.location as 'collection_location', ii.created_at as 'collection_date',
# ott.id as 'collection_type_id', ott.name as 'collection_type'
# from samples s
# inner join items i on i.sample_id = s.id
# inner join object_types ot on ot.id =i.object_type_id
# left join part_associations pa on pa.part_id = i.id
# left join items ii on ii.id = pa.collection_id
# left join object_types ott on ott.id = ii.object_type_id
# ;
#

