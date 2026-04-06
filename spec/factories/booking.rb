FactoryBot.define do
  factory :booking do
    association :user
    association :equipment
    start_time { Time.zone.parse("2025-10-04 10:00") }
    end_time   { Time.zone.parse("2025-10-04 11:00") }
    status { :pending }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end