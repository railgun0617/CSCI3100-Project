FactoryBot.define do
  factory :booking_equipment, class: 'Booking' do
    association :user
    association :equipment
    booking_type { "equipment" }
    start_time { 1.hour.from_now }
    end_time   { 2.hours.from_now }
    quantity { 1 }
    status { :pending }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end

  factory :booking_venue, class: 'Booking' do
    association :user
    association :venue
    booking_type { "venue" }
    start_time { venue.open_time + 1.hour }
    end_time   { venue.open_time + 2.hours }
    status { :pending }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end