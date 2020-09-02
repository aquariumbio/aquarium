# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/announcements').to route_to('announcements#index')
    end

    it 'routes to #new' do
      expect(get: '/announcements/new').to route_to('announcements#new')
    end

    it 'routes to #show' do
      expect(get: '/announcements/1').to route_to('announcements#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/announcements/1/edit').to route_to('announcements#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/announcements').to route_to('announcements#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/announcements/1').to route_to('announcements#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/announcements/1').to route_to('announcements#destroy', id: '1')
    end

  end
end
