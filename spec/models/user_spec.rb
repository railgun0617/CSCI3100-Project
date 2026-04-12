require 'rails_helper'

RSpec.describe User, type: :model do
  let(:tenant) { create(:tenant) }

  describe "tenant validation for staff" do
    it "is invalid when staff has no tenant" do
      user = build(:user, role: "staff", tenant: nil)
      expect(user).not_to be_valid
      expect(user.errors[:tenant_id]).to include("can't be blank")
    end

    it "is valid when staff has a tenant" do
      user = build(:user, role: "staff", tenant: tenant)
      expect(user).to be_valid
    end

    it "is valid when student has no tenant" do
      user = build(:user, role: "student", tenant: nil)
      expect(user).to be_valid
    end

    it "is valid when admin has no tenant" do
      user = build(:user, role: "admin", tenant: nil)
      expect(user).to be_valid
    end
  end

  describe "role helper methods" do
    it "returns true for student? when role is student" do
      user = build(:user, role: "student")
      expect(user.student?).to be true
      expect(user.staff?).to be false
    end

    it "returns true for staff? when role is staff" do
      user = build(:user, role: "staff", tenant: tenant)
      expect(user.staff?).to be true
      expect(user.student?).to be false
    end
  end
end
