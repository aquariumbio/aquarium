FactoryBot.define do
  factory :user do
    name { "Joe Neptunis" }
    login { "neptunis" }
    password { 'thePassword' }
    password_confirmation { 'thePassword' }
  end
end
