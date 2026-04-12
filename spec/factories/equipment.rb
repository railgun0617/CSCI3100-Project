FactoryBot.define do
  factory :equipment do
    association :tenant
    sequence(:name) { |n| "Projector #{n}" }
    description { "HD Projector" }
    location { "ERB Room 101" }
    quantity { 3 }
    latitude { 22.418199 }
    longitude { 114.207988 }
  end
end
