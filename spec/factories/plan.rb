# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    sequence(:name) { |n| "plan_#{n}" }
    initialize_with { Plan.where(name: name).first_or_create }
  end
end
