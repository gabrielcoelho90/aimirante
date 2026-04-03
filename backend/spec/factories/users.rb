FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    plan { "trial" }
    plan_expires_at { 7.days.from_now }
  end
end
