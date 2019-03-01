FactoryBot.define do
  factory :user do
    name { "Joe Neptunis" }
    login { "neptunis" }
    password { 'thePassword' }
  end
end