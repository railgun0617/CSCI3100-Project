FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "115501234#{n}@elink.cuhk.edu.hk" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :student do
      role { "student" }
    end

    trait :staff do
      role { "staff" }
    end
  end
end