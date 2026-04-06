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

  factory :equipment do
    name { "Projector" }
    description { "HD Projector" }
    location { "ERB Room 101" }
    quantity { 3 }
    latitude { 22.418199 }
    longitude { 114.207988 }
  end
end