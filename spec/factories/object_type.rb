FactoryBot.define do
  factory :object_type do
    name { "an object_type" }
    unit { "object" }
    min { 0 }
    max { 1 }
    release_method { "return" }
    description { "a container object type" }
    cost { 0.01 }

    trait :collection_type do
      handler { 'collection' }
    end

    factory :stripwell do
      name { 'Stripwell' }
      description { 'Stripwell' }
      collection_type
      release_method { 'query' }
      unit { 'stripwell' }
      rows { 1 }
      columns { 12 }
    end

    factory :collection_96_well do
      name { '96 PCR collection' }
      description { '96 PCR collection' }
      collection_type
      unit { 'part' }
      rows { 8 }
      columns { 12 }
    end
  end
end
