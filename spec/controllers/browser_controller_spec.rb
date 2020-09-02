# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowserController, type: :controller do
  before do
    token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
    cookies[token_name] = User.find(1).remember_token
  end

  let(:dummy_sample_type) { create(:sample_type, name: 'DummySampleType') }
  let!(:dummy_sample) { create(:sample, name: 'DummySample', sample_type: dummy_sample_type) }
  let!(:dummy_object_type) { create(:object_type, name: 'DummyObjectType') }
  let!(:dummy_item_1) { create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id) }

  it 'search on dummy_item should return dummy_sample' do
    params = { item_id: dummy_item_1.id, page: 0 }
    post :search, params, as: :json

    expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
    response_body = JSON.parse(response.body).symbolize_keys
    expect(response_body[:count]).to eq(1)
    expect(response_body[:samples][0]['id']).to eq(dummy_sample.id)
  end

  it 'search with non-existent item should not return samples' do
    params = { item_id: dummy_item_1.id + 1, page: 0 }
    post :search, params, as: :json

    expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
    response_body = JSON.parse(response.body).symbolize_keys
    expect(response_body[:count]).to eq(0)
  end

  it 'should find container if at least one sample matches'
end
