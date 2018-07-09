

require 'rails_helper'

RSpec.describe ParametersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/parameters').to route_to('parameters#index')
    end

    it 'routes to #new' do
      expect(get: '/parameters/new').to route_to('parameters#new')
    end

    it 'routes to #show' do
      expect(get: '/parameters/1').to route_to('parameters#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/parameters/1/edit').to route_to('parameters#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/parameters').to route_to('parameters#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/parameters/1').to route_to('parameters#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/parameters/1').to route_to('parameters#destroy', id: '1')
    end

  end
end
