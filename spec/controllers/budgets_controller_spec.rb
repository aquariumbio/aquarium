# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BudgetsController, type: :controller do
  let!(:regular_user) { create(:user) }

  
  it 'non-admin should return error message' do
    token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
    cookies[token_name] = User.find(regular_user.id).remember_token

    get :index, as: :json 
    expect(response.headers['Content-Type']).to eq('text/html; charset=utf-8')
    skip('should redirect because user is not admin rather than not logged in')
    expect(response.body).to be_nil
  end



end