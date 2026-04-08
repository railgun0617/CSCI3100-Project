require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  let(:user) { create(:user) }
  let(:staff) { create(:user, :staff) }
  let(:equipment) { create(:equipment, quantity: 5) }
  let(:venue) { create(:venue) }

  before { sign_in user }

  let(:valid_equipment_attributes) do
    {
      equipment_id: equipment.id,
      booking_type: "equipment",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      quantity: 1
    }
  end

  let(:valid_venue_attributes) do
    {
      booking_type: "venue",
      start_time: venue.open_time + 1.hour,
      end_time: venue.open_time + 2.hours
    }
  end

  let(:invalid_equipment_attributes) do
    {
      equipment_id: equipment.id,
      booking_type: "equipment",
      start_time: 1.hour.ago,
      end_time: Time.zone.now,
      quantity: 0
    }
  end

  let(:invalid_quantity_attributes) do
    {
      equipment_id: equipment.id,
      booking_type: "equipment",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      quantity: 0
    }
    end


  describe "GET #index" do
    it "lists the current user's bookings" do
      booking = create(:booking_equipment, user: user, equipment: equipment)
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:bookings)).to include(booking)
    end
  end

  describe "GET #new" do
    it "renders new booking form for venue" do
      get :new, params: { resource_type: "venue", resource_id: venue.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:resource)).to eq(venue)
    end

    it "redirects if no resource specified" do
      get :new
      expect(response).to redirect_to(resources_path)
      expect(flash[:alert]).to eq("No resource specified for booking.")
    end
  end

  describe "POST #create_booking" do
    context "with valid attributes" do
      it "creates a booking and redirects with notice" do
        expect {
          post :create_booking, params: { resource_type: "equipment", resource_id: equipment.id }.merge(valid_equipment_attributes)
        }.to change(Booking, :count).by(1)
        expect(response).to redirect_to(bookings_path)
        expect(flash[:notice]).to include("Booking request submitted")
      end
    end

    context "with invalid attributes (past start time)" do
      it "shows past time error" do
        post :create_booking, params: { resource_type: "equipment", resource_id: equipment.id }.merge(invalid_equipment_attributes)
        expect(flash[:alert]).to include("Start time cannot be in the past")
      end
    end

    context "when equipment quantity exceeded" do
      it "redirects with availability alert" do
        equipment.update(quantity: 1)
        create(:booking_equipment, equipment: equipment, user: user,
               start_time: valid_equipment_attributes[:start_time],
               end_time: valid_equipment_attributes[:end_time],
               quantity: 1)
        expect {
          post :create_booking, params: {
                resource_type: "equipment", resource_id: equipment.id, booking_type: "equipment",
                start_time: valid_equipment_attributes[:start_time],
                end_time: valid_equipment_attributes[:end_time],
                quantity: 2
            }
        }.not_to change(Booking, :count)
        expect(response).to redirect_to(new_booking_path(resource_type: "equipment", resource_id: equipment.id))
        expect(flash[:alert]).to match(/Only \d+ items available/)
      end
    end

    context "with venue booking" do
      it "creates a venue booking" do
        expect {
          post :create_booking, params: { resource_type: "venue", resource_id: venue.id }.merge(valid_venue_attributes)
        }.to change(Booking, :count).by(1)
        expect(response).to redirect_to(bookings_path)
        expect(flash[:notice]).to include("Booking request submitted")
      end
    end

    context "with invalid resource type" do
      it "redirects to resources path with alert" do
        post :create_booking, params: { resource_type: "foo", resource_id: 123 }.merge(valid_equipment_attributes)
        expect(response).to redirect_to(resources_path)
        expect(flash[:alert]).to eq("Invalid resource.")
      end
    end
  end

  describe "PATCH #approve" do
    it "approves a booking" do
      booking = create(:booking_equipment, user: user, equipment: equipment)
      patch :approve, params: { id: booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:notice]).to eq("Booking approved.")
      expect(booking.reload.status).to eq("approved")
    end

    it "prevents non-staff from approving" do
      sign_in user # not staff
      booking = create(:booking_equipment, user: user, equipment: equipment)
      patch :approve, params: { id: booking.id }
      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to include("not authorized")
      expect(booking.reload.status).to eq("pending")
    end
  end

  describe "PATCH #reject" do
    it "rejects a booking" do
      booking = create(:booking_equipment, user: user, equipment: equipment)
      patch :reject, params: { id: booking.id }
      expect(response).to redirect_to(staff_dashboard_path)
      expect(flash[:notice]).to eq("Booking rejected.")
      expect(booking.reload.status).to eq("rejected")
    end

    it "prevents non-staff from rejecting" do
      sign_in user # not staff
      booking = create(:booking_equipment, user: user, equipment: equipment)
      patch :reject, params: { id: booking.id }
      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to include("not authorized")
      expect(booking.reload.status).to eq("pending")
    end
  end

  describe "DELETE #destroy" do
    it "allows owner to delete booking" do
      booking = create(:booking_equipment, user: user, equipment: equipment)
      expect {
        delete :destroy, params: { id: booking.id }
      }.to change(Booking, :count).by(-1)
      expect(response).to redirect_to(bookings_path)
    end

    it "prevents non-owner non-staff from deleting" do
      other_user = create(:user)
      booking = create(:booking_equipment, user: other_user, equipment: equipment)
      expect {
        delete :destroy, params: { id: booking.id }
      }.not_to change(Booking, :count)
      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to include("not authorized")
    end

    it "allows staff to delete booking" do
      sign_in staff
      booking = create(:booking_equipment, user: user, equipment: equipment)
      expect {
        delete :destroy, params: { id: booking.id }
      }.to change(Booking, :count).by(-1)
      expect(response).to redirect_to(bookings_path)
    end
  end
end
