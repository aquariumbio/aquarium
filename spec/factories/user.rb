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

    after(:create) do |user|
      user.parameters.create(key: 'email', value: 'blah@blah.blah')
      user.parameters.create(key: 'phone', value: '5555555555')
      user.parameters.create(key: 'lab_agreement', value: 'true')
      user.parameters.create(key: 'aquarium', value: 'true')
    end
  end
end
