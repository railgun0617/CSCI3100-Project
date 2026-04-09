require 'rails_helper'

RSpec.describe VenuesController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:venue) }

    let(:invalid_attributes) do
      {
        name: nil,
        description: nil,
        capacity: nil,
        open_time: nil,
        close_time: nil,
        latitude: nil,
        longitude: nil
      }
    end

    context "with valid parameters" do
      it "creates a new Venue" do
        expect {
          post :create, params: { venue: valid_attributes }
        }.to change(Venue, :count).by(1)
      end

      it "redirects to the created venue" do
        post :create, params: { venue: valid_attributes }
        expect(response).to redirect_to(Venue.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Venue" do
        expect {
          post :create, params: { venue: invalid_attributes }
        }.not_to change(Venue, :count)
      end

      it "renders the new template again" do
        post :create, params: { venue: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #show" do
    let(:venue) { create(:venue) }

    it "returns a success response" do
      get :show, params: { id: venue.to_param }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #edit" do
    let(:venue) { create(:venue) }

    it "returns a success response" do
      get :edit, params: { id: venue.to_param }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    let(:venue) { create(:venue) }
    let(:new_attributes) do
      {
        name: "New Venue",
        description: "New Description",
        location: "New Location",
        quantity: 5,
        latitude: 22.419538,
        longitude: 114.205059
      }
    end

    it "re-renders edit" do
      patch :update, params: { id: equipment.to_param, equipment: { name: "" } }
      expect(response).to render_template(:edit)
    end

    it "updates the requested equipment" do
      patch :update, params: { id: equipment.to_param, equipment: new_attributes }
      equipment.reload
      expect(equipment.name).to eq("Updated Projector")
      expect(equipment.description).to eq("Updated Description")
      expect(equipment.location).to eq("Updated Location")
      expect(equipment.quantity).to eq(5)
      expect(equipment.latitude).to eq(22.419538)
      expect(equipment.longitude).to eq(114.205059)
    end

    it "redirects to the equipment" do
      patch :update, params: { id: equipment.to_param, equipment: new_attributes }
      expect(response).to redirect_to(equipment)
    end
  end

  describe "DELETE #destroy" do
    let!(:equipment) { create(:equipment) }

    it "destroys the requested equipment" do
      expect {
        delete :destroy, params: { id: equipment.to_param }
      }.to change(Equipment, :count).by(-1)
    end

    it "redirects to the equipment list" do
      delete :destroy, params: { id: equipment.to_param }
      expect(response).to redirect_to(equipment_index_path)
    end
  end
end