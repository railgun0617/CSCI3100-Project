require 'rails_helper'

RSpec.describe StaffController, type: :controller do
  let(:tenant)       { create(:tenant, name: "Department of Computer Science") }
  let(:admin_tenant) { create(:admin_tenant) }

  let(:student_user) { create(:user, :student, tenant: tenant) }
  let(:staff_user)   { create(:user, :staff, tenant: tenant) }
  let(:admin_user)   { create(:user, :staff, tenant: admin_tenant) }

  let!(:venue)       { create(:venue, tenant: tenant) }
  let!(:equipment)   { create(:equipment, tenant: tenant) }

  let!(:pending_booking) do
    create(:booking_venue, venue: venue, user: staff_user,
            start_time: Time.zone.now.tomorrow.change(hour: venue.open_time.hour + 1),
            end_time:   Time.zone.now.tomorrow.change(hour: venue.open_time.hour + 2))
  end
  let!(:approved_booking) do
    create(:booking_equipment, :approved, equipment: equipment, user: staff_user,
           start_time: 2.days.from_now, end_time: 2.days.from_now + 1.hour)
  end

  describe "GET #dashboard" do
    context "as student" do
      before { sign_in(student_user) }

      it "denies access" do
        get :dashboard
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "as staff (non-admin tenant)" do
      before { sign_in(staff_user) }

      it "shows only pending bookings for their tenant" do
        get :dashboard
        bookings = assigns(:bookings)
        expect(bookings).to include(pending_booking)
        expect(bookings).not_to include(approved_booking)
        expect(bookings.all? { |b| b.status == "pending" }).to be true
      end
    end

    context "as admin staff (tenant named Admin)" do
      before { sign_in(admin_user) }

      it "shows all bookings regardless of status or tenant" do
        get :dashboard
        bookings = assigns(:bookings)
        expect(bookings).to include(pending_booking)
        expect(bookings).to include(approved_booking)
      end
    end
  end
end
