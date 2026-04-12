require 'rails_helper'

RSpec.describe EquipmentController, type: :controller do
  let(:tenant) { create(:tenant, name: "Department of Computer Science and Engineering") }
  let(:admin_tenant) { create(:admin_tenant) }
  let(:non_admin_tenant) { create(:non_admin_tenant) }
  let(:staff_user) { create(:user, role: "staff", tenant: admin_tenant) }

  before { sign_in staff_user }

  describe "authentication and authorization" do
    context "when unauthenticated" do
      before { sign_out staff_user }  # ensure no one is signed in

      it "redirects unauthenticated users to sign in" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a student" do
      let(:student_user) { create(:user, role: "student", tenant: tenant) }
      before { sign_in student_user }

      it "shows all equipment without tenant filter" do
        equipment1 = create(:equipment, tenant: tenant)
        equipment2 = create(:equipment, tenant: admin_tenant)
        get :index
        expect(assigns(:equipment)).to match_array([equipment1, equipment2])
      end

      it "denies access to new" do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end

      it "denies access to create" do
        post :create, params: { equipment: attributes_for(:equipment, tenant_id: tenant.id) }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end

      it "denies access to destroy" do
        equipment = create(:equipment, tenant: tenant)
        delete :destroy, params: { id: equipment.to_param }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "when signed in as non-admin staff" do
      let(:staff_user) { create(:user, role: "staff", tenant: non_admin_tenant) }
      before { sign_in staff_user }

      it "filters equipment by the staff's tenant" do
        tenant_equipment = create(:equipment, tenant: non_admin_tenant)
        other_equipment = create(:equipment, tenant: admin_tenant)
        get :index
        expect(assigns(:equipment)).to include(tenant_equipment)
        expect(assigns(:equipment)).not_to include(other_equipment)
      end
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:equipment, tenant_id: admin_tenant.id) }
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
        expect(flash[:notice]).to eq("Equipment was successfully created.")
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

    context "when non-admin staff creates equipment" do
      let(:staff_user) { create(:user, role: "staff", tenant: non_admin_tenant) }
      before { sign_in staff_user }

      it "forces tenant to staff's tenant even if another tenant_id is passed" do
        post :create, params: { equipment: attributes_for(:equipment, tenant_id: admin_tenant.id) }
        expect(Equipment.last.tenant).to eq(non_admin_tenant)
      end
    end
  end

  describe "GET #show" do
    let(:staff_user) { create(:user, role: "staff", tenant: non_admin_tenant) }
    let(:equipment) { create(:equipment, tenant: non_admin_tenant) }
    let(:other_equipment) { create(:equipment, tenant: admin_tenant) }
    before { sign_in staff_user }

    it "returns a success response for equipment in their tenant" do
      get :show, params: { id: equipment.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "raises ActiveRecord::RecordNotFound for equipment outside their tenant" do
      expect {
        get :show, params: { id: other_equipment.to_param }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    let(:staff_user) { create(:user, role: "staff", tenant: non_admin_tenant) }
    before { sign_in staff_user }

    it "returns a success response" do
      get :new
      expect(response).to have_http_status(:ok)
    end

    it "pre-assigns tenant to their own tenant" do
      get :new
      expect(assigns(:equipment).tenant).to eq(non_admin_tenant)
    end
  end

  describe "GET #edit" do
    let(:equipment) { create(:equipment, tenant: admin_tenant) }
    it "returns a success response" do
      get :edit, params: { id: equipment.to_param }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    let(:equipment) { create(:equipment, tenant: admin_tenant) }
    let(:new_attributes) do
      {
        name: "New Projector",
        description: "New Description",
        location: "New Location",
        quantity: 5,
        latitude: 22.419000,
        longitude: 114.208000
      }
    end

    it "re-renders edit when invalid" do
      patch :update, params: { id: equipment.to_param, equipment: { name: "" } }
      expect(response).to render_template(:edit)
    end

    it "updates the requested equipment" do
      patch :update, params: { id: equipment.to_param, equipment: new_attributes }
      equipment.reload
      expect(equipment.name).to eq("New Projector")
      expect(equipment.description).to eq("New Description")
      expect(equipment.location).to eq("New Location")
      expect(equipment.quantity).to eq(5)
      expect(equipment.latitude).to eq(22.419000)
      expect(equipment.longitude).to eq(114.208000)
    end

    it "redirects to the equipment" do
      patch :update, params: { id: equipment.to_param, equipment: new_attributes }
      expect(response).to redirect_to(equipment)
      expect(flash[:notice]).to eq("Equipment was successfully updated.")
    end
  end

  describe "DELETE #destroy" do
    let!(:equipment) { create(:equipment, tenant: admin_tenant) }

    it "destroys the requested equipment" do
      expect {
        delete :destroy, params: { id: equipment.to_param }
      }.to change(Equipment, :count).by(-1)
    end

    it "redirects to the equipment list" do
      delete :destroy, params: { id: equipment.to_param }
      expect(response).to redirect_to(equipment_index_path)
      expect(flash[:notice]).to eq("Equipment was successfully deleted.")
    end
  end
end
