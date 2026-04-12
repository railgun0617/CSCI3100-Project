require 'rails_helper'

RSpec.describe Venue, type: :model do
  subject { build(:venue) }

  describe "venue validations" do
    context "when adding venue" do
      it "is valid with all attributes" do
        expect(subject).to be_valid
      end

      it "is invalid without a name" do
        subject.name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:name]).to include("can't be blank")
      end

      it "is invalid without a description" do
        subject.description = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:description]).to include("can't be blank")
      end

      it "is invalid without a tenant" do
        subject.tenant = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:tenant]).to include("can't be blank")
      end

      it "is invalid with a negative capacity" do
        subject.capacity = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("must be greater than 0")
      end

      it "is invalid with zero capacity" do
        subject.capacity = 0
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("must be greater than 0")
      end

      it "is valid with capacity greater than 0" do
        subject.capacity = 1
        expect(subject).to be_valid
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

      it "is invalid if closing time the same as opening time" do
        subject.open_time = Time.zone.parse("12:00")
        subject.close_time = Time.zone.parse("12:00")
        expect(subject).not_to be_valid
        expect(subject.errors[:close_time]).to include("must be after open time")
      end

      it "is invalid without latitude" do
        subject.latitude = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:latitude]).to include("can't be blank")
      end

      it "is invalid with non-numeric latitude" do
        subject.latitude = "twenty two point four two"
        expect(subject).not_to be_valid
        expect(subject.errors[:latitude]).to include("is not a number")
      end

      it "is invalid with latitude out of range" do
        subject.latitude = 290
        expect(subject).not_to be_valid
        expect(subject.errors[:latitude]).to include("must be less than or equal to 90")
      end

      it "is invalid without longitude" do
        subject.longitude = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:longitude]).to include("can't be blank")
      end

      it "is invalid with non-numeric longitude" do
        subject.longitude = "one one four point two"
        expect(subject).not_to be_valid
        expect(subject.errors[:longitude]).to include("is not a number")
      end

      it "is invalid with longitude out of range" do
        subject.longitude = -53
        expect(subject).not_to be_valid
        expect(subject.errors[:longitude]).to include("must be greater than or equal to 0")
      end

      it "is valid with latitude at lower boundary" do
        subject.latitude = 0
        expect(subject).to be_valid
      end

      it "is valid with latitude at upper boundary" do
        subject.latitude = 90
        expect(subject).to be_valid
      end

      it "is valid with longitude at lower boundary" do
        subject.longitude = 0
        expect(subject).to be_valid
      end

      it "is valid with longitude at upper boundary" do
        subject.longitude = 180
        expect(subject).to be_valid
      end

      it "requires unique name" do
        create(:venue, name: "Library")
        duplicate = build(:venue, name: "Library", description: "Another Library", capacity: 100, open_time: Time.zone.parse("09:00"), close_time: Time.zone.parse("18:00"), latitude: 22.419538, longitude: 114.205059)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end
    end
  
    context "when editing a venue" do
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

  describe "#is_venue_open?" do
    let(:venue) { build(:venue, open_time: Time.zone.parse("09:00"), close_time: Time.zone.parse("18:00")) }

    it "returns true when times are within operating hours" do
      start_time = Time.zone.parse("10:00")
      end_time   = Time.zone.parse("11:00")
      expect(venue.is_venue_open?(start_time, end_time)).to be true
    end

    it "returns false when start time is before opening" do
      start_time = Time.zone.parse("08:00")
      end_time   = Time.zone.parse("14:00")
      expect(venue.is_venue_open?(start_time, end_time)).to be false
    end

    it "returns false when end time is after closing" do
      start_time = Time.zone.parse("16:00")
      end_time   = Time.zone.parse("19:00")
      expect(venue.is_venue_open?(start_time, end_time)).to be false
    end
  end
end
