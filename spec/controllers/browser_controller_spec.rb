# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowserController, type: :controller do
  before do
    token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym
    cookies[token_name] = User.find(1).remember_token
  end

  it 'should find container if at least one sample matches'
end