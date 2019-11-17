# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "sample_#{n}" }
    project { 'testing' }
    user_id { 1 }
    sample_type
  end

  factory :sample_type do
    sequence(:name) { |n| "sample_type_#{n}" }
    description { 'a sample type' }
    initialize_with { SampleType.where(name: name).first_or_create } # singleton

    factory :sample_type_with_samples do
      transient do
        sample_count { 5 }
      end

      after(:create) do |sample_type, evaluator|
        create_list(:sample, evaluator.sample_count, sample_type: sample_type)
      end
    end
  end
end
