require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  remember_token_name = "remember_token_#{Bioturk::Application.environment_name}"

  describe "Sessions" do

    it "logs in an gets a tasty cookie" do

      post :create, { session: { login: "neptune", password: "aquarium" } }, as: 'html'
      raise "no remember token" unless response.cookies[remember_token_name]

    end

  end

end



