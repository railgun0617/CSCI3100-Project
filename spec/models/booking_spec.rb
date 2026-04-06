require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:user) { create(:user) }
  let(:equipment) { create(:equipment) }

  it "is valid for a single one-hour slot" do
    booking = create(:booking)
    expect(booking).to be_valid
  end

  it "is invalid if slot is outside allowed hours" do
    booking = build(:booking,
                   start_time: Time.zone.parse("2025-10-04 23:00"),
                   end_time: Time.zone.parse("2025-10-05 00:00"))
    expect(booking).not_to be_valid
    expect(booking.errors[:start_time]).to include("is not within allowed booking hours")
  end

  it "does not allow duplicate booking for same user and slot" do
    booking = create(:booking)
    duplicate = build(:booking)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:base]).to include("You already have a booking for this slot")
  end

  it "does not allow overlapping approved bookings" do
    booking = create(:booking)
    overlap = build(:booking, user: user, equipment: equipment,
                  start_time: Time.zone.parse("2025-10-04 10:30"),
                  end_time: Time.zone.parse("2025-10-04 11:30"),
                  status: :pending)
    expect(overlap).not_to be_valid
  end
end