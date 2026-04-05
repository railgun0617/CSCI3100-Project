FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "115512345#{n}@link.cuhk.edu.hk" }
    password { "password123" }

    trait :student do
      role { "student" }
    end

    trait :staff do
      role { "staff" }
    end
  end
end