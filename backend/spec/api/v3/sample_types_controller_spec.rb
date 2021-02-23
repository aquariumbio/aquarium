require 'rails_helper'

RSpec.describe Api::V3::SampleTypesController, type: :request do
  describe 'api' do
    # Sign in users
    before :all do
      @create_url = "/api/v3/token/create"
      @token_1 = []

      post "#{@create_url}?login=user_1&password=password"
      response_body = JSON.parse(response.body)
      @token_1 << response_body["token"]
    end

    # Create sample type with errors
    it "invalid_sample_type" do
      post "/api/v3/sample_types/create?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # NAME CANNOT BE BLANK, DESCRSIPTION CANNOT BE BLANK
      response_body = JSON.parse(response.body)
      expect(response_body["errors"]["name"]).to eq ["can't be blank"]
      expect(response_body["errors"]["description"]).to eq ["can't be blank"]
    end

    # CRUD tests
    # TODO: Break this up into separate tests (the way it is done for object types)
    it "crud_sample_type" do
      # Sample type parameters to be used as allowable feild types
      params_1 = {
        sample_type: {
          name: "sample name 1",
          description: "sample definition",
          field_types: nil
        }
      }

      params_2 = {
        sample_type: {
          name: "sample name 2",
          description: "sample definition",
          field_types: nil
        }
      }

      # Create sample type
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params_1
      expect(response).to have_http_status 201

      response_body = JSON.parse(response.body)
      id_1 = response_body["sample_type"]["id"]

      # Create sample type
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params_2
      expect(response).to have_http_status 201

      response_body = JSON.parse(response.body)
      id_2 = response_body["sample_type"]["id"]

      # Sample type parameters
      params = {
        sample_type: {
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
      }

      # Create sample type
      post "/api/v3/sample_types/create?token=#{@token_1[0]}", :params => params
      expect(response).to have_http_status 201

      response_body = JSON.parse(response.body)
      this_id = response_body["sample_type"]["id"]

      # Get sample type
      get "/api/v3/sample_types/#{this_id}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # Get the sample type ids
      response_body = JSON.parse(response.body)

      this_ft      = response_body["sample_type"]["field_types"]
      this_ft_id_0 = this_ft[0]["id"]
      this_ft_id_1 = this_ft[1]["id"]
      this_aft_0   = this_ft[0]["allowable_field_types"]
      this_aft_id_0_0 = this_aft_0[0]["id"]
      this_aft_id_0_1 = this_aft_0[1]["id"]

      # Update sample type
      # Switch the values of the field types and then check results
      # Can run a slew of other tests but if it gets these everything should work
      update_params = {
        id: this_id,
        sample_type: {
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
      }

      post "/api/v3/sample_types/#{this_id}/update?token=#{@token_1[0]}", :params => update_params
      expect(response).to have_http_status 200
      response_body = JSON.parse(response.body)

      # Get sample type
      get "/api/v3/sample_types/#{this_id}?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      response_body = JSON.parse(response.body)

      # Fields should have switched
      update_ft      = response_body["sample_type"]["field_types"]
      update_ft_0    = update_ft[0]["ftype"]
      update_ft_1    = update_ft[1]["ftype"]
      update_aft_1   = update_ft[1]["allowable_field_types"]
      update_aft_1_0 = update_aft_1[0]["sample_type_id"]
      update_aft_1_1 = update_aft_1[1]["sample_type_id"]

      expect(update_ft_0).to eq "string"
      expect(update_ft_1).to eq "sample"
      expect(update_aft_1_0).to eq id_1
      expect(update_aft_1_1).to eq id_2

      # Delete sample types
      post "/api/v3/sample_types/#{this_id}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/sample_types/#{id_1}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      post "/api/v3/sample_types/#{id_2}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200
    end
  end
end
