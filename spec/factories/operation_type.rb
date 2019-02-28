FactoryBot.define do
  factory :operation_type do
    sequence(:name) { |n| "operation_type_#{n}" }
    category { "the category" }
    deployed { true }
  end

  
end