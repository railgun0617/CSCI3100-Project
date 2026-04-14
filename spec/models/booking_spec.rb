require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:user)      { create(:user) }
  let(:equipment) { create(:equipment, quantity: 2) }
  let(:venue)     { create(:venue) }
  let(:slot_start) { 1.day.from_now.change(hour: 10) }
  let(:slot_end)   { slot_start + 1.hour }

  describe "booking equipment validations" do
    it "is valid for booking 1 equipment when there is remaining equipment" do
      booking = create(:booking_equipment, user: user, equipment: equipment, start_time: slot_start, end_time: slot_end, quantity: 1)
      expect(booking).to be_valid
    end

    it "is invalid if no remaining equipment" do
      create_list(:booking_equipment, equipment.quantity, equipment: equipment, start_time: slot_start, end_time: slot_end)
      booking = build(:booking_equipment, equipment: equipment, start_time: slot_start, end_time: slot_end)
      expect(booking).not_to be_valid
    end

    it "is invalid if booking more than remaining equipment" do
      create_list(:booking_equipment, equipment.quantity, equipment: equipment, start_time: slot_start, end_time: slot_end)
      booking = build(:booking_equipment, equipment: equipment, quantity: 2, start_time: slot_start, end_time: slot_end)
      expect(booking).not_to be_valid
    end

    it "is invalid if booking zero equipment" do
      booking = build(:booking_equipment, equipment: equipment, quantity: 0, start_time: slot_start, end_time: slot_end)
      expect(booking).not_to be_valid
    end

    it "is invalid if booking less than zero equipment" do
      booking = build(:booking_equipment, equipment: equipment, quantity: -1, start_time: slot_start, end_time: slot_end)
      expect(booking).not_to be_valid
    end

    it "is invalid if booking less than 1 hour" do
      booking = build(:booking_equipment, equipment: equipment, start_time: slot_start, end_time: slot_start + 30.minutes)
      expect(booking).not_to be_valid
    end

    it "is invalid if booking more than 4 hours" do
      booking = build(:booking_equipment, equipment: equipment, start_time: slot_start, end_time: slot_start + 5.hours)
      expect(booking).not_to be_valid
    end

    it "is invalid if current time past the booking start time" do
      travel_to slot_end do
        booking = build(:booking_equipment, equipment: equipment, start_time: slot_start, end_time: slot_end)
        expect(booking).not_to be_valid
      end
    end

    it "is invalid if end time is before start time" do
      booking = build(:booking_equipment, equipment: equipment, start_time: slot_end, end_time: slot_start)
      expect(booking).not_to be_valid
    end

    it "is invalid if duplicate booking for same user and slot" do
      booking = create(:booking_equipment, equipment: equipment, start_time: slot_start, end_time: slot_end)
      duplicate = build(:booking_equipment, user: booking.user, equipment: booking.equipment, start_time: booking.start_time, end_time: booking.end_time)
      expect(duplicate).not_to be_valid
    end

    it "is invalid if conflict with existing booking" do
      booking = create(:booking_equipment, user: user, equipment: equipment, start_time: slot_start, end_time: slot_end, quantity: 2)
      conflict = build(:booking_equipment, user: user, equipment: booking.equipment, start_time: booking.start_time, end_time: booking.end_time)
      expect(conflict).not_to be_valid
    end
  end

  describe "booking venue validations" do
    it "is invalid if outside opening hours" do
      booking = build(:booking_venue, venue: venue,
                    start_time: venue.open_time - 1.hour,
                    end_time: venue.open_time + 1.hour)
      expect(booking).not_to be_valid
    end

    it "is invalid if overlapping another booking" do
      existing = create(:booking_venue, venue: venue, start_time: slot_start, end_time: slot_end)
      conflict = build(:booking_venue, venue: venue,
                    start_time: existing.start_time,
                    end_time: existing.end_time)
      expect(conflict).not_to be_valid
    end
  end

  describe "#approve!" do
    let(:booking_equipment) { create(:booking_equipment, status: 'pending', equipment: equipment, start_time: slot_start, end_time: slot_end) }
    let(:booking_venue)     { create(:booking_venue, status: 'pending', venue: venue, start_time: slot_start, end_time: slot_end) }

    it "changes status to approved" do
      booking_equipment.approve!
      expect(booking_equipment).to be_approved
      booking_venue.approve!
      expect(booking_venue).to be_approved
    end
  end

  describe "#reject!" do
    let(:booking_equipment) { create(:booking_equipment, status: 'pending', equipment: equipment, start_time: slot_start, end_time: slot_end) }
    let(:booking_venue)     { create(:booking_venue, status: 'pending', venue: venue, start_time: slot_start, end_time: slot_end) }

    it "changes status to rejected" do
      booking_equipment.reject!
      expect(booking_equipment).to be_rejected
      booking_venue.reject!
      expect(booking_venue).to be_rejected
    end
  end

  describe "#deletable_by?" do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:staff_user) { create(:user, :staff) }
    let(:booking_equipment) { create(:booking_equipment, user: owner, equipment: equipment, start_time: slot_start, end_time: slot_end) }
    let(:booking_venue) { create(:booking_venue, user: owner, venue: venue, start_time: slot_start, end_time: slot_end) }

    it "returns true for the booking owner" do
      expect(booking_equipment.deletable_by?(owner)).to be true
      expect(booking_venue.deletable_by?(owner)).to be true
    end

    it "returns true for a staff user" do
      expect(booking_equipment.deletable_by?(staff_user)).to be true
      expect(booking_venue.deletable_by?(staff_user)).to be true
    end

    it "returns false for other non-staff users" do
      expect(booking_equipment.deletable_by?(other_user)).to be false
      expect(booking_venue.deletable_by?(other_user)).to be false
    end

    it "returns false for nil actor" do
      expect(booking_equipment.deletable_by?(nil)).to be false
      expect(booking_venue.deletable_by?(nil)).to be false
    end
  end

  describe "#cancel!" do
    let(:booking_equipment) { create(:booking_equipment, status: 'approved', quantity: 1, equipment: equipment, start_time: slot_start, end_time: slot_end) }

    it "changes status to cancelled and restores equipment quantity" do
      original_qty = equipment.quantity
      booking_equipment.cancel!
      expect(booking_equipment).to be_cancelled
      expect(equipment.reload.quantity).to eq(original_qty + 1)
    end
  end

  describe "locking" do
    it "locks and releases a booking" do
      booking = Booking.create!(booking_type: "equipment", equipment: equipment,
                                start_time: slot_start, end_time: slot_end, user: user, quantity: 1)
      booking.update!(locked_by_id: user.id, locked_at: Time.zone.now)
      expect(booking.locked?).to be true
      expect(booking.locked_by?(user)).to be true
      booking.release_lock!
      expect(booking.locked?).to be false
    end
  end
end
