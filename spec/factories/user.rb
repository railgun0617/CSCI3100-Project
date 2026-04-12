FactoryBot.define do
  factory :user do
    association :tenant
    sequence(:email) { |n| "115501234#{n}@elink.cuhk.edu.hk" }
    password { "password123" }

    trait :student do
      role { "student" }
    end

    trait :staff do
      role { "staff" }
    end

    trait :default do
      role { "student" }
    end
  end
end
