# frozen_string_literal: true

FactoryBot.define do
  factory :library do
    transient do
      source {}
      user {}
    end

    name { 'the_library' }
    category { 'the_test_category' }

    after(:create) do |operation_type, evaluator|
      if evaluator.source && evaluator.user
        operation_type.add_source(content: evaluator.source, user: evaluator.user)
      end
    end
  end
end
