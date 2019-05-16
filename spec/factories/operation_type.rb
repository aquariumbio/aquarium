FactoryBot.define do
  factory :operation_type do
    sequence(:name) { |n| "operation_type_#{n}" }
    category { "the category" }
    deployed { true }
    initialize_with { OperationType.where(name: name, category: category).first_or_create }
  end
end