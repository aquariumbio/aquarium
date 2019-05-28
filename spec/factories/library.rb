# frozen_string_literal: true

FactoryBot.define do
  factory :library do
    name { 'the_library' }
    category { 'the_test_category' }
  end
end
