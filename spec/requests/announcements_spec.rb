# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Announcements', type: :request do
  describe 'GET /announcements' do
    it 'works! (now write some real specs)' do
      get announcements_path
      expect(response).to have_http_status(200)
    end
  end
end
