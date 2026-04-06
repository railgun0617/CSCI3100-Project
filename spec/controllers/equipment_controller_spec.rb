require 'rails_helper'

RSpec.describe EquipmentController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:equipment) }

    let(:invalid_attributes) do
      {
        name: nil,
        description: nil,
        location: nil,
        quantity: nil,
        latitude: nil,
        longitude: nil
      }
    end

    context "with valid parameters" do
      it "creates a new Equipment" do
        expect {
          post :create, params: { equipment: valid_attributes }
        }.to change(Equipment, :count).by(1)
      end

      it "redirects to the created equipment" do
        post :create, params: { equipment: valid_attributes }
        expect(response).to redirect_to(Equipment.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Equipment" do
        expect {
          post :create, params: { equipment: invalid_attributes }
        }.not_to change(Equipment, :count)
      end

      it "renders the new template again" do
        post :create, params: { equipment: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #show" do
    let(:equipment) { create(:equipment) }

    it "returns a success response" do
      get :show, params: { id: equipment.to_param }
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
    let(:equipment) { create(:equipment) }

    it "returns a success response" do
      get :edit, params: { id: equipment.to_param }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    let(:equipment) { create(:equipment) }
    let(:new_attributes) do
      {
        name: "Updated Projector",
        description: "Updated Description",
        location: "Updated Location",
        quantity: 5,
        latitude: 22.419000,
        longitude: 114.208000
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
      expect(equipment.latitude).to eq(22.419000)
      expect(equipment.longitude).to eq(114.208000)
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