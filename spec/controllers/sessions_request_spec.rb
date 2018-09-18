require 'rails_helper'

describe "session login", type: :request do
    it "returns cookies from correct login with html format" do
        login_attributes = {login: 'neptune', password: 'aquarium'}
        post '/sessions.html', {session: login_attributes}
        remember_token_name = "remember_token_#{Bioturk::Application.environment_name}"
        expect(response.cookies).to have_key(remember_token_name)
        expect(response.cookies[remember_token_name]).to_not be_nil
    end

    it "returns cookies from correct login with json format" do
        login_attributes = {login: 'neptune', password: 'aquarium'}
        post '/sessions.json', {session: login_attributes}, as: 'json'
        remember_token_name = "remember_token_#{Bioturk::Application.environment_name}"
        expect(response.cookies).to have_key(remember_token_name)
        expect(response.cookies[remember_token_name]).to_not be_nil
    end

    it "does not return remember token with incorrect login" do
        login_attributes = {login: 'blah', password: 'blah'}
        post '/sessions.json', {session: login_attributes}, as: 'json'
        remember_token_name = "remember_token_#{Bioturk::Application.environment_name}"
        expect(response.cookies).not.to have_key(remember_token_name)
    end
end