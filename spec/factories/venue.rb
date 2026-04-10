FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Library #{n}" }
    description { "A place to let students to study" }
    capacity { 50 }
    open_time { Time.zone.parse("09:00") }
    close_time { Time.zone.parse("18:00") }
    latitude { 22.419538 }
    longitude { 114.205059}
  end
end