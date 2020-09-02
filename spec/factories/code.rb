# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :code do
    name { 'the_code' }
    content { 'def the_code; end' }
    parent_id { 1 }
    parent_class { 'DummyClass' }
    user_id { 1 }
  end
end
