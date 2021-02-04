# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Joe Neptunis' }
    login { 'neptunis' }
    password { 'thePassword' }
    password_confirmation { 'thePassword' }

    initialize_with { User.where(name: name, login: login).first_or_create }
    # TODO: make sure agreement is set
  end
end
