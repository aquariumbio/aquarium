require 'rails_helper'

RSpec.describe Api::V3::SampleTypesController, type: :request do
  describe 'api' do

    # SIGN IN USERS
    before :all do
      @token_1 = []

      post "/api/v3/token/create?login=user_1&password=password"
      resp = JSON.parse(response.body)
      @token_1 << resp["token"]
    end

    # CREATE SAMPLE TYPE WITH ERRORS
    it "invalid_sample_type" do
      post "/api/v3/sample_types/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # NAME CANNOT BE BLANK, DESCRSIPTION CANNOT BE BLANK
      resp = JSON.parse(response.body)
      expect(resp["errors"]["name"]).to eq ["can't be blank"]
      expect(resp["errors"]["description"]).to eq ["can't be blank"]
    end


    # CRUD SAMPLE TYPE
    # COMPLEX TESTS BUT THEY ARE ALL INTER-WOVEN SO IT IS EASIER THAN BREAKING THEM UP
    it "crud_sample_type" do
      # SAMPLE TYPE PARAMETERS TO BE USED AS ALLOWABLE FEILD TYPES
      params_1 = {
          id: nil,
          name: "sample name 1",
          description: "sample definition",
          field_types: nil
      }

      params_2 = {
          id: nil,
          name: "sample name 2",
          description: "sample definition",
          field_types: nil
      }

      # CREATE SAMPLE TYPE
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params_1
      expect(response).to have_http_status 201

      resp = JSON.parse(response.body)
      id_1 = resp["id"]

      # CREATE SAMPLE TYPE
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params_2
      expect(response).to have_http_status 201

      resp = JSON.parse(response.body)
      id_2 = resp["id"]

      # SAMPLE TYPE PARAMETERS
      params = {
          id: nil,
          name: "sample name 3",
          description: "sample definition",
          field_types: [
              {
                  id: nil,
                  name: "field1",
                  ftype: "sample",
                  required: false,
                  array: false,
                  choices: nil,
                  allowable_field_types: [
                      {
                          id: nil,
                          sample_type_id: id_1
                      },
                      {
                          id: nil,
                          sample_type_id: id_2
                      }
                  ]
              },
              {
                  id: nil,
                  name: "field2",
                  ftype: "string",
                  required: false,
                  array: false,
                  choices: "a, b, c",
                  allowable_field_types: nil
              }
          ]
      }

      # CREATE SAMPLE TYPE
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      resp = JSON.parse(response.body)
      this_id = resp["id"]

      # GET SAMPLE TYPE
      get "/api/v3/sample_types/#{this_id}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # GET THE SAMPLE TYPE IDS
      resp = JSON.parse(response.body)

      this_ft      = resp["sample_type"]["field_types"]
      this_ft_id_0 = this_ft[0]["id"]
      this_ft_id_1 = this_ft[1]["id"]
      this_aft_0   = this_ft[0]["allowable_field_types"]
      this_aft_id_0_0 = this_aft_0[0]["id"]
      this_aft_id_0_1 = this_aft_0[1]["id"]

      # UPDATE SAMPLE TYPE
      # SWITCH THE VALUES OF THE FIELD TYPES AND THEN CHECK RESULTS
      # CAN RUN A SLEW OF OTHER TESTS BUT IF IT GETS THESE EVERYTHING SHOULD WORK
      update_params = {
          id: this_id,
          name: "sample name 4",
          description: "sample definition",
          field_types: [
              {
                  id: this_ft_id_1,
                  name: "field4",
                  ftype: "sample",
                  required: false,
                  array: false,
                  choices: nil,
                  allowable_field_types: [
                      {
                          id: this_aft_id_0_0,
                          sample_type_id: id_1
                      },
                      {
                          id: this_aft_id_0_1,
                          sample_type_id: id_2
                      }
                  ]
              },
              {
                  id: this_ft_id_0,
                  name: "field3",
                  ftype: "string",
                  required: false,
                  array: false,
                  choices: "a, b, c",
                  allowable_field_types: nil
              }
          ]
      }

      post "/api/v3/sample_types/#{this_id}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      resp = JSON.parse(response.body)

      # GET SAMPLE TYPE
      get "/api/v3/sample_types/#{this_id}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      resp = JSON.parse(response.body)

      # FIELDS SHOULD HAVE SWITCHED
      update_ft      = resp["sample_type"]["field_types"]
      update_ft_0    = update_ft[0]["ftype"]
      update_ft_1    = update_ft[1]["ftype"]
      update_aft_1   = update_ft[1]["allowable_field_types"]
      update_aft_1_0 = update_aft_1[0]["sample_type_id"]
      update_aft_1_1 = update_aft_1[1]["sample_type_id"]

      expect(update_ft_0).to eq "string"
      expect(update_ft_1).to eq "sample"
      expect(update_aft_1_0).to eq id_1
      expect(update_aft_1_1).to eq id_2

      # DELETE SAMPLE TYPES
      post "/api/v3/sample_types/#{this_id}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/sample_types/#{id_1}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/sample_types/#{id_2}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end
  end
end
