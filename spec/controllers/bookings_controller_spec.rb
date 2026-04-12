# spec/controllers/bookings_controller_spec.rb
require "rails_helper"

RSpec.describe BookingsController, type: :controller do
  let(:tenant) { create(:tenant, name: "Admin") }
  let(:staff)  { create(:user, :staff, tenant: tenant) }
  let(:student){ create(:user, :student, tenant: tenant) }
  let(:venue)  { create(:venue, tenant: tenant) }
  let(:equipment) { create(:equipment, tenant: tenant, quantity: 5) }

  before { sign_in(student) }

  describe "GET #index" do
    context "as student" do
      it "lists only current user's bookings" do
        own_booking = create(:booking_equipment, user: student, equipment: equipment)
        other_booking = create(:booking_equipment, user: staff, equipment: equipment)

        get :index
        expect(assigns(:bookings)).to eq([own_booking])
        expect(assigns(:bookings)).not_to include(other_booking)
      end
    end

    context "as admin staff" do
      before { sign_in(staff) }

      it "lists all bookings" do
        booking1 = create(:booking_equipment, user: student, equipment: equipment)
        booking2 = create(:booking_equipment, user: staff, equipment: equipment)

        get :index
        expect(assigns(:bookings)).to match_array([booking1, booking2])
      end
    end
  end

  describe "GET #new" do
    it "loads venue resource" do
      get :new, params: { resource_type: "venue", resource_id: venue.id }
      expect(assigns(:resource)).to eq(venue)
      expect(assigns(:time_slots)).to be_present
    end

    it "loads equipment resource" do
      get :new, params: { resource_type: "equipment", resource_id: equipment.id }
      expect(assigns(:resource)).to eq(equipment)
      expect(assigns(:time_slots)).to be_present
      expect(assigns(:max_quantities)).to be_present
    end

    it "redirects if no resource specified" do
      get :new
      expect(response).to redirect_to(resources_path)
      expect(flash[:alert]).to eq("No resource specified for booking.")
    end
  end

  describe "POST #create_booking" do
    context "with valid equipment booking" do
      it "creates booking and redirects" do
        post :create_booking, params: {
          resource_type: "equipment",
          resource_id: equipment.id,
          start_time: 1.day.from_now.to_s,
          end_time: (1.day.from_now + 1.hour).to_s,
          quantity: 2
        }
        expect(response).to redirect_to(bookings_path)
        expect(flash[:notice]).to eq("Booking request submitted")
        expect(Booking.last.user).to eq(student)
      end
    end

    context "with valid venue booking" do
      it "creates booking and redirects" do
        post :create_booking, params: {
          resource_type: "venue",
          resource_id: venue.id,
          start_time: 1.day.from_now.to_s,
          end_time: (1.day.from_now + 1.hour).to_s
        }
        expect(response).to redirect_to(bookings_path)
        expect(flash[:notice]).to eq("Booking request submitted")
        expect(Booking.last.venue).to eq(venue)
      end
    end

    context "with overbooking equipment" do
      it "redirects with alert" do
        create(:booking_equipment, user: staff, equipment: equipment,
               start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour,
               quantity: 5, status: :approved)

        post :create_booking, params: {
          resource_type: "equipment",
          resource_id: equipment.id,
          start_time: 1.day.from_now.to_s,
          end_time: (1.day.from_now + 1.hour).to_s,
          quantity: 2
        }
        expect(response).to redirect_to(new_booking_path(resource_type: "equipment", resource_id: equipment.id))
        expect(flash[:alert]).to match(/Only 0 items available/)
      end
    end

    context "with invalid resource_type" do
      it "redirects with alert" do
        post :create_booking, params: { resource_type: "school_bus", resource_id: 123, 
                                        start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour }
        expect(response).to redirect_to(resources_path)
        expect(flash[:alert]).to eq("Invalid resource.")
      end
    end

    context "with invalid booking save" do
      it "redirects with error" do
        post :create_booking, params: {
          resource_type: "venue",
          resource_id: venue.id,
          start_time: 1.day.from_now.to_s,
          end_time: 1.day.ago.to_s # invalid end_time before start_time
        }
        expect(response).to redirect_to(new_booking_path(resource_type: "venue", resource_id: venue.id))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH #approve" do
    let(:booking) { create(:booking_equipment, user: student, equipment: equipment) }

    before { sign_in(staff) }

    it "approves booking" do
      patch :approve, params: { id: booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:notice]).to eq("Booking approved.")
      expect(booking.reload.status).to eq("approved")
    end

    it "denies unauthorized user" do
      sign_in(student)
      patch :approve, params: { id: booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:alert]).to eq("You are not authorized to approve this booking.")
    end
  end

  describe "PATCH #reject" do
    let(:booking) { create(:booking_equipment, user: student, equipment: equipment) }

    before { sign_in(staff) }

    it "rejects booking" do
      patch :reject, params: { id: booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:notice]).to eq("Booking rejected.")
      expect(booking.reload.status).to eq("rejected")
    end

    it "denies unauthorized user" do
      sign_in(student)
      patch :reject, params: { id: booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:alert]).to eq("You are not authorized to reject this booking.")
    end
  end

  describe "DELETE #destroy" do
    let!(:booking) { create(:booking_equipment, user: student, equipment: equipment) }

    it "allows owner to delete booking" do
      request.env["HTTP_REFERER"] = bookings_path
      delete :destroy, params: { id: booking.id }
      expect(response).to redirect_to(bookings_path)
      expect(flash[:notice]).to eq("Booking was successfully deleted.")
      expect(Booking.exists?(booking.id)).to be_falsey
    end

    it "handles booking not found" do
      delete :destroy, params: { id: 9999 }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:alert]).to eq("Booking was already deleted or not found.")
    end

    it "denies unauthorized user" do
      other_booking = create(:booking_equipment, user: staff, equipment: equipment)
      delete :destroy, params: { id: other_booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:alert]).to eq("You are not authorized to delete this booking.")
    end
  end
end
