require 'rails_helper'

RSpec.describe OperationTypesController, type: :controller do

  token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym

  describe "Tests operation types" do
    OperationType.where(deployed: true).each do |ot|
      it "successfully tests operation type #{ot.id}: #{ot.name}" do

        cookies[token_name] = User.find(1).remember_token

        get(:random, { id: ot.id, num: 3 })

        post_data = ot.as_json
        post_data[:test_operations] = JSON.parse @response.body
        post :test, post_data

        ops = JSON.parse @response.body, symbolize_names: true
        ops[:operations].each { |op| assert_equal("done", op[:status]) }
      end
    end
  end
end
