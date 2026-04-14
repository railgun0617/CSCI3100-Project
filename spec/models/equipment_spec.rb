require 'rails_helper'

RSpec.describe Equipment, type: :model do
  let(:tenant) { create(:admin_tenant) }
  subject { build(:equipment, tenant: tenant) }

  describe "validations" do
    it "is valid with all attributes" do
      expect(subject).to be_valid
    end

    it "requires a tenant" do
      subject.tenant = nil
      expect(subject).not_to be_valid
    end

    it "requires a unique name" do
      create(:equipment, name: "Projector", tenant: tenant)
      duplicate = build(:equipment, name: "Projector", tenant: tenant)
      expect(duplicate).not_to be_valid
    end

    it "requires description, location, and positive quantity" do
      subject.description = nil
      subject.location = nil
      subject.quantity = 0
      expect(subject).not_to be_valid
    end

    it "validates latitude and longitude ranges" do
      subject.latitude = -1
      subject.longitude = 200
      expect(subject).not_to be_valid
    end

    it "accepts numeric strings for latitude/longitude" do
      subject.latitude = "22.42"
      subject.longitude = "114.20"
      expect(subject).to be_valid
    end
  end

  describe "availability methods" do
    let(:equipment) { create(:equipment, tenant: tenant, quantity: 5) }
    let(:start_time) { 1.day.from_now }
    let(:end_time) { start_time + 1.hour }

    it "returns full quantity when no bookings exist" do
      expect(equipment.available_quantity_for_slot(start_time, end_time)).to eq(5)
    end

    it "reduces available quantity when bookings exist" do
      create(:booking_equipment, equipment: equipment, quantity: 2,
             start_time: start_time, end_time: end_time, status: "approved")
      expect(equipment.available_quantity_for_slot(start_time, end_time)).to eq(3)
    end

    it "excludes a specific booking when checking sufficiency" do
      booking = create(:booking_equipment, equipment: equipment, quantity: 4,
                       start_time: start_time, end_time: end_time, status: "approved")
      expect(equipment.sufficient_quantity_for_slot?(3, start_time, end_time, booking.id)).to be true
    end
  end

  describe "quantity changes" do
    let(:equipment) { create(:equipment, tenant: tenant, quantity: 5) }

    it "decrements quantity with and without lock" do
      equipment.decrement_quantity!(2, lock: false)
      expect(equipment.quantity).to eq(3)
      equipment.decrement_quantity!(1, lock: true)
      expect(equipment.reload.quantity).to eq(2)
    end

    it "increments quantity with and without lock" do
      equipment.increment_quantity!(2, lock: false)
      expect(equipment.quantity).to eq(7)
      equipment.increment_quantity!(1, lock: true)
      expect(equipment.reload.quantity).to eq(8)
    end
  end

  describe "class methods" do
    it "returns ransackable attributes" do
      expect(Equipment.ransackable_attributes).to include("name", "description", "location")
    end

    it "returns ransackable associations" do
      expect(Equipment.ransackable_associations).to include("latitude", "longitude", "quantity")
    end
  end
end
