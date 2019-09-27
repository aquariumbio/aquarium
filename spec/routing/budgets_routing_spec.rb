# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BudgetsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/budgets').to route_to('budgets#index')
    end

    it 'routes to #new' do
      expect(get: '/budgets/new').to route_to('budgets#new')
    end

    it 'routes to #show' do
      expect(get: '/budgets/1').to route_to('budgets#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/budgets/1/edit').to route_to('budgets#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/budgets').to route_to('budgets#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/budgets/1').to route_to('budgets#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/budgets/1').to route_to('budgets#destroy', id: '1')
    end

  end
end
