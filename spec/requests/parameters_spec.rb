require 'rails_helper'

RSpec.describe 'Parameters', type: :request do
  describe 'GET /parameters' do
    it 'works! (now write some real specs)' do
      get parameters_path
      expect(response).to have_http_status(200)
    end
  end
end
