require 'rails_helper'

RSpec.describe Api::V3::ObjectTypesController, type: :request do
  describe 'api' do

    # Sign in users
    before :all do
      @token_1 = []
      @object_type_ids = []
      @sample_type_ids = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]
    end

    # Create sample type with errors
    it "invalid_object_type" do
      params = {
        "object_type": {
            "min": -1,
            "max": -2
        }
      }
      post "/api/v3/object_types/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 200

      # Errors
      resp = JSON.parse(response.body)
      expect(resp["errors"]["name"]).to eq ["can't be blank"]
      expect(resp["errors"]["description"]).to eq ["can't be blank"]
      expect(resp["errors"]["handler"]).to eq ["can't be blank"]
      expect(resp["errors"]["cost"]).to eq ["cost must be at least 0.01"]
      expect(resp["errors"]["min"]).to eq ["min must be greater than or equal to zero","min must be less than or equal to max"]
      expect(resp["errors"]["max"]).to eq ["max must be greater than or equal to zero"]
    end

    # CRUD tests

    # Create object type with handler = collection
    it "create_object_type_collection" do
      # Object type parameters
      params = {
        object_type: {
          name: "object name 1",
          description: "object definition",
          prefix: "object prefix",
          min: 1,
          max: 2,
          unit: "unit",
          cost: 3,
          handler: "collection",
          release_method: "return",
          rows: 4,
          columns: 5,
          release_description: "object release description",
          safety: "object safety information",
          cleanup: "object cleanup information",
          data: "object data",
          vendor: "object vendor information"
        }
      }

      # Create object type
      post "/api/v3/object_types/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Get object type
      get "/api/v3/object_types/handler/collection?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      this_object_type = resp["collection"]["object_types"][0]

      # Save the id (to delete it later)
      @object_type_ids << this_object_type["id"]

      expect(this_object_type["name"]).to eq "object name 1"
    end

    # Update object type
    it "update_object_type" do
      # Update object type
      update_params = {
        object_type: {
          name: "update name 1",
          description: "update definition",
          prefix: "update prefix",
          min: -1,
          max: 3,
          unit: "units",
          cost: 0,
          handler: "",
          release_method: "no change",
          release_description: "update release description",
          safety: "update safety information",
          cleanup: "update cleanup information",
          data: "update data",
          vendor: "update vendor information"
        }
      }

      post "/api/v3/object_types/#{@object_type_ids[0]}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # Spot check name, min, max, cost, rows, cols
      expect(resp["name"]).to eq "update name 1" # changed
      expect(resp["min"]).to eq 1 # no change
      expect(resp["max"]).to eq 2 # no change
      expect(resp["cost"]).to eq 3 # no change
      expect(resp["rows"]).to eq 1 # default
      expect(resp["columns"]).to eq 12 # default
    end

    # Create object type with handler = sample_container
    it "create_object_type_container" do
      # Sample type parameters to be used as allowable feild types
      params_1 = {
        sample_type: {
          name: "sample name 1",
          description: "sample definition",
          field_types: nil
        }
      }

      # Create sample type
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params_1
      expect(response).to have_http_status 201

      resp = JSON.parse(response.body)
      @sample_type_ids << resp["id"]

      # Object type parameters
      params = {
        object_type: {
          name: "object name 2",
          description: "object definition",
          prefix: "object prefix",
          min: 1,
          max: 2,
          unit: "unit",
          cost: 3,
          handler: "sample_container",
          sample_type_id: @sample_type_ids[0],
          release_method: "return",
          rows: 4,
          columns: 5,
          release_description: "object release description",
          safety: "object safety information",
          cleanup: "object cleanup information",
          data: "object data",
          vendor: "object vendor information"
        }
      }

      # Create object type
      post "/api/v3/object_types/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      # Get object type
      get "/api/v3/object_types/handler/sample_container?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)
      this_object_type = resp["sample_container"]["object_types"][0]

      # Save the id (to delete it later)
      @object_type_ids << this_object_type["id"]

      expect(this_object_type["name"]).to eq "object name 2"
    end

    # Delete the object types
    # Also delete the sample type (for cleanup)
    it "delete_object_types" do
      post "/api/v3/object_types/#{@object_type_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/object_types/#{@object_type_ids[1]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/sample_types/#{@sample_type_ids[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end

  end
end
