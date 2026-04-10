require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "sign up validations" do
    it "is valid with a proper email and matching password confirmation" do
      expect(subject).to be_valid
    end

    it "is invalid without an email" do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it "is invalid without a password" do
      subject.password = nil
      subject.password_confirmation = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).to include("can't be blank")
    end

    it "is invalid when password confirmation does not match" do
      subject.password_confirmation = "123456"
      expect(subject).not_to be_valid
      expect(subject.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it "is invalid when password is too short" do
      subject.password = "156"
      subject.password_confirmation = "156"
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "1155123456@link.cuhk.edu.hk")
      duplicate_user = build(:user, email: "1155123456@link.cuhk.edu.hk")
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end
  end

  
  describe "sign in validations" do
    let!(:existing_user) do
      create(:user, email: "1155123456@link.cuhk.edu.hk", password: "qwerty123", password_confirmation: "qwerty123")
    end

    it "is valid with correct email and password" do
      expect(existing_user.valid_password?("qwerty123")).to be true
    end

    it "is invalid with incorrect password" do
      expect(existing_user.valid_password?("qwertyuiop123")).to be false
    end

    it "is invalid with different case password" do
      expect(existing_user.valid_password?("QWERTY123")).to be false
    end

    it "is invalid with non-existent email" do  
      non_existent_user = described_class.find_by(email: "1155987654@link.cuhk.edu.hk")
      expect(non_existent_user).to be_nil
    end
  end
end
