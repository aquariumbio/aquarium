# frozen_string_literal: true

module Api
  module V3
    # SAMPLE TYPE API CALLS
    class SampleTypesController < ApplicationController
      # LIST OF SAMPLE TYPES PLUS DETAILS FOR FIRST ITEM IN LIST
      def index
        # CHECK FOR ADMIN PERMISSIONS
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # GET LIST
        list = SampleType.find_all
        render json: { sample_types: nil,  }.to_json, status: :ok and return if list.length == 0

        # GET DETAILS OF FIRST ITEM IN LIST
        details = SampleType.details(list[0].id)
        details = details.update({ id: list[0].id, name: list[0].name })

        render json: {
          sample_types: list,
          first: details
         }.to_json, status: :ok
      end

      # DETAILS FOR SELECTED SAMPLE TYPE
      def show
        # CHECK FOR ADMIN PERMISSIONS
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.number(params[:id])

        # GET ITEM
        sample_type = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample_type

        # GET DETAILS OF FIRST ITEM IN LIST
        details = SampleType.details(id)
        details = details.update({ id: id, name: sample_type.name, description: sample_type.description })

        render json: {
          sample_type: details
         }.to_json, status: :ok
      end

      # CREATE NEW SAMPLE TYPE
      def create
        # CHECK FOR ADMIN PERMISSIONS
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        sample_type, errors = SampleType.create(params)
        render json: { errors: errors }.to_json, status: :ok and return if !sample_type

        render json: sample_type.to_json, status: :created

      end

      # UPDATE SAMPLE TYPE
      def update
         # CHECK FOR ADMIN PERMISSIONS
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.number(params[:id])

        # GET ITEM
        sample_type = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample_type

        # UPDATE SAMPLE
        # NOTE: ANY ERRORS HANDLED AUTOMATICALLY AND SILENTLY
        sample_type = sample_type.update(params)

        render json: sample_type.to_json, status: :ok
      end

      # DELETE SAMPLE TYPE
      def delete
        # CHECK FOR ADMIN PERMISSIONS
        status, response = check_token_for_permission(1)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        id = Input.number(params[:id])

        # GET ITEM
        sample = SampleType.find_id(id)
        render json: { sample_type: nil  }.to_json, status: :ok and return if !sample

        # DELETE ITEM AND RELATED ITEMS WITHOUT FOREIGN KEYS
        sample.delete_sample_type

        render json: {
          message: "deleted"
         }.to_json, status: :ok

      end

    end
  end
end
