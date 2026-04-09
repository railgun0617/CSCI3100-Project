require 'rails_helper'

RSpec.describe Venue, type: :model do
  subject { build(:venue) }

  describe "add venue validations" do
    it "is valid with all attributes" do
      expect(subject).to be_valid
    end

    it "is invalid with a negative capacity" do
      subject.capacity = -1
      expect(subject).not_to be_valid
      expect(subject.errors[:capacity]).to include("must be greater than or equal to 1")
    end

    it "is invalid with zero capacity" do
      subject.capacity = 0
      expect(subject).not_to be_valid
      expect(subject.errors[:capacity]).to include("must be greater than or equal to 1")
    end

    it "is invalid without opening time" do
      subject.open_time = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:open_time]).to include("can't be blank")
    end

    it "is invalid without closing time" do
      subject.close_time = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:close_time]).to include("can't be blank")
    end

    it "is invalid if closing time is before opening time" do
      subject.open_time = Time.zone.parse("12:00")
      subject.close_time = Time.zone.parse("09:00")
      expect(subject).not_to be_valid
      expect(subject.errors[:close_time]).to include("must be after open time")
    end

    it "is invalid with non-numeric latitude" do
      subject.latitude = "twenty two point four two"
      expect(subject).not_to be_valid
      expect(subject.errors[:latitude]).to include("is not a number")
    end

    it "is invalid with latitude out of range" do
      subject.latitude = 22.45
      expect(subject).not_to be_valid
      expect(subject.errors[:latitude]).to include("must be less than or equal to 90")
    end

    it "is invalid with non-numeric longitude" do
      subject.longitude = "one one four point two"
      expect(subject).not_to be_valid
      expect(subject.errors[:longitude]).to include("is not a number")
    end

    it "is invalid with longitude out of range" do
      subject.longitude = 114.22
      expect(subject).not_to be_valid
      expect(subject.errors[:longitude]).to include("must be less than or equal to 180")
    end

    it "is valid with latitude at lower boundary" do
      subject.latitude = 22.412
      expect(subject).to be_valid
    end

    it "is valid with latitude at upper boundary" do
      subject.latitude = 22.428
      expect(subject).to be_valid
    end

    it "is valid with longitude at lower boundary" do
      subject.longitude = 114.2006
      expect(subject).to be_valid
    end

    it "is valid with longitude at upper boundary" do
      subject.longitude = 114.2145
      expect(subject).to be_valid
    end

    it "requires unique name" do
      create(:venue, name: "Library")
      duplicate = build(:venue, name: "Library", description: "Another Library", capacity: 100, open_time: Time.zone.parse("09:00"), close_time: Time.zone.parse("18:00"), latitude: 22.419538, longitude: 114.205059)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end
  end

  
  describe "edit venue validations" do
    let!(:existing_venue) { create(:venue) }

    it "is valid with valid attributes" do
      existing_venue.description = "New Library Description"
      existing_venue.open_time = Time.zone.parse("13:00")
      existing_venue.close_time = Time.zone.parse("16:00")
      expect(existing_venue).to be_valid
    end

    it "is invalid when name is changed to a duplicate" do
      create(:venue, name: "Library", description: "Another Library", capacity: 100, open_time: Time.zone.parse("09:00"), close_time: Time.zone.parse("18:00"), latitude: 22.419538, longitude: 114.205059)
      existing_venue.name = "Library"
      expect(existing_venue).not_to be_valid
      expect(existing_venue.errors[:name]).to include("has already been taken")
    end
  end
end