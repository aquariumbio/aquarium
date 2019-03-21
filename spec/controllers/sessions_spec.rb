require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  remember_token_name = "remember_token_#{Bioturk::Application.environment_name}"

  describe "Sessions" do

    it "logs in and gets the remember_token cookie" do

      post :create, { session: { login: "neptune", password: "aquarium" } }, as: 'html'
      expect(response.cookies).to have_key(remember_token_name)
    end

  end

end
