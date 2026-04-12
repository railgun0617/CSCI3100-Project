FactoryBot.define do
  factory :booking_equipment, class: 'Booking' do
    association :user
    booking_type { "equipment" }
    start_time { 1.day.from_now }
    end_time   { 1.day.from_now + 1.hour }
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
    booking_type { "venue" }
    start_time { (Time.zone.now.to_date + 1.day).to_time.change(hour: venue.open_time.hour) + 1.hour }
    end_time   { start_time + 1.hour }
    status { :pending }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
