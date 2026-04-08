require 'rails_helper'

RSpec.describe Equipment, type: :model do
  subject { build(:equipment) }

  describe "add equipment validations" do
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

    it "is invalid without a location" do
      subject.location = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:location]).to include("can't be blank")
    end

    it "is invalid without a quantity" do
      subject.quantity = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:quantity]).to include("can't be blank")
    end

    it "is invalid with a non-integer quantity" do
      subject.quantity = "five"
      expect(subject).not_to be_valid
      expect(subject.errors[:quantity]).to include("is not a number")
    end

    it "is invalid with a negative quantity" do
      subject.quantity = -1
      expect(subject).not_to be_valid
      expect(subject.errors[:quantity]).to include("must be greater than or equal to 0")
    end

    it "is valid with zero quantity" do
      subject.quantity = 0
      expect(subject).to be_valid
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
      create(:equipment, name: "Projector")
      duplicate = build(:equipment, name: "Projector", description: "Another Projector", location: "MMW Room 102", quantity: 2, latitude: 22.42, longitude: 114.209)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end
  end

  
  describe "edit equipment validations" do
    let!(:existing_equipment) { create(:equipment) }

    it "is valid with valid attributes" do
      existing_equipment.description = "Updated Description"
      expect(existing_equipment).to be_valid
    end

    it "is invalid when name is changed to a duplicate" do
      create(:equipment, name: "Camera", description: "HD Camera", location: "MMW Room 102", quantity: 2, latitude: 22.42, longitude: 114.209)
      existing_equipment.name = "Camera"
      expect(existing_equipment).not_to be_valid
      expect(existing_equipment.errors[:name]).to include("has already been taken")
    end
  end
end