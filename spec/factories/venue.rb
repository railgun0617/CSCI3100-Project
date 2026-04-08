FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Library #{n}" }
    description { "A place to let students to study" }
    capacity { 50 }
    latitude { 22.418199 }
    longitude { 114.207988 }
    open_time { Time.zone.parse("09:00") }
    close_time { Time.zone.parse("18:00") }
  end
end