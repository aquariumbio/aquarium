FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "sample_#{n}" }
    project { "the project" }
    user_id { 1 }
    sample_type
  end

  factory :sample_type do
    sequence(:name) { |n| "sample_#{n}" }
    description { "a sample type" }

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
