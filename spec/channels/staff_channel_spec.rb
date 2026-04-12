# spec/channels/staff_channel_spec.rb
require "rails_helper"

RSpec.describe StaffChannel, type: :channel do
  let(:tenant) { create(:tenant) }
  let(:staff_user) { create(:user, :staff, tenant: tenant) }
  let(:student_user) { create(:user, :student, tenant: tenant) }

  context "when subscribed as staff" do
    before do
      stub_connection current_user: staff_user
      subscribe
    end

    it "successfully subscribes" do
      expect(subscription).to be_confirmed
    end

    it "streams from staff_channel" do
      expect(subscription.streams).to include("staff_channel")
    end
  end

  context "when subscribed as student (non-staff)" do
    before do
      stub_connection current_user: student_user
      subscribe
    end

    it "rejects the subscription" do
      expect(subscription).to be_rejected
    end
  end

  context "when subscribed with no user" do
    before do
      stub_connection current_user: nil
      subscribe
    end

    it "rejects the subscription" do
      expect(subscription).to be_rejected
    end
  end
end
