require 'rails_helper'

RSpec.describe VenuesController, type: :controller do
  let(:tenant) { create(:tenant, name: "Department of Computer Science and Engineering") }
  let(:admin_tenant) { create(:admin_tenant) }
  let(:non_admin_tenant) { create(:non_admin_tenant) }
  let(:staff_user) { create(:user, role: "staff", tenant: admin_tenant) }

  before { sign_in staff_user }

  describe "authentication and authorization" do
    context "when unauthenticated" do
      before { sign_out :user }  # ensure no one is signed in

      it "redirects unauthenticated users to sign in" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a student" do
      let(:student_user) { create(:user, role: "student", tenant: tenant) }
      before { sign_in student_user }

      it "denies access to new" do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end

      it "denies access to create" do
        post :create, params: { venue: attributes_for(:venue, tenant_id: tenant.id) }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end

      it "denies access to destroy" do
        venue = create(:venue, tenant: tenant)
        delete :destroy, params: { id: venue.to_param }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "when signed in as a student" do
      let(:student_user) { create(:user, role: "student", tenant: tenant) }
      before { sign_in student_user }

      it "shows all venues without tenant filter" do
        venue1 = create(:venue, tenant: tenant)
        venue2 = create(:venue, tenant: admin_tenant)
        get :index
        expect(assigns(:venues)).to match_array([venue1, venue2])
      end
    end
  end

  describe "GET #index" do
    let(:other_tenant) { create(:tenant, name: "OtherTenant") }
    let!(:venue_admin) { create(:venue, tenant: tenant) }
    let!(:venue_other) { create(:venue, tenant: other_tenant) }

    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "admin staff sees all venues" do
      get :index
      expect(assigns(:venues)).to include(venue_admin, venue_other)
    end

    it "non-admin staff sees only their tenant's venues" do
      non_admin_tenant = create(:tenant, name: "RegularTenant")
      non_admin_user = create(:user, role: "staff", tenant: non_admin_tenant)
      sign_in non_admin_user
      venue_non_admin = create(:venue, tenant: non_admin_tenant)

      get :index
      expect(assigns(:venues)).to include(venue_non_admin)
      expect(assigns(:venues)).not_to include(venue_other)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:venue, tenant_id: tenant.id) }
    let(:invalid_attributes) { { name: nil, description: nil, capacity: nil } }

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

      it "redirects back to new when invalid" do
        post :create, params: { venue: invalid_attributes }
        expect(response).to redirect_to(new_venue_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when admin staff creates venue with tenant_id" do
      it "assigns the provided tenant_id" do
        post :create, params: { venue: attributes_for(:venue, tenant_id: non_admin_tenant.id) }
        expect(Venue.last.tenant_id).to eq(non_admin_tenant.id)
      end
    end

    context "when non-admin staff creates venue" do
      let(:staff_user) { create(:user, role: "staff", tenant: non_admin_tenant) }
      before { sign_in staff_user }

      it "forces tenant to staff's tenant even if another tenant_id is passed" do
        post :create, params: { venue: attributes_for(:venue, tenant_id: admin_tenant.id) }
        expect(Venue.last.tenant).to eq(non_admin_tenant)
      end
    end
  end

  describe "GET #show" do
    let(:staff_user) { create(:user, role: "staff", tenant: non_admin_tenant) }
    let(:venue) { create(:venue, tenant: non_admin_tenant) }
    let(:venue_other) { create(:venue, tenant: admin_tenant) }
    before { sign_in staff_user }

    it "returns a success response" do
      get :show, params: { id: venue.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "raises ActiveRecord::RecordNotFound for venue outside their tenant" do
      expect {
        get :show, params: { id: venue_other.to_param }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #edit" do
    let(:venue) { create(:venue, tenant: tenant) }

    it "returns a success response" do
      get :edit, params: { id: venue.to_param }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    let(:venue) { create(:venue, tenant: tenant) }
    let(:new_attributes) do
      {
        name: "Updated Venue",
        description: "Updated Description",
        capacity: 100,
        open_time: Time.zone.parse("10:00"),
        close_time: Time.zone.parse("16:00"),
        latitude: 22.419538,
        longitude: 114.205059
      }
    end

    it "updates the requested venue" do
      patch :update, params: { id: venue.to_param, venue: new_attributes }
      venue.reload
      expect(venue.name).to eq("Updated Venue")
      expect(venue.description).to eq("Updated Description")
      expect(venue.capacity).to eq(100)
    end

    it "redirects to the venue" do
      patch :update, params: { id: venue.to_param, venue: new_attributes }
      expect(response).to redirect_to(venue)
    end

      it "redirects back to edit when invalid" do
        patch :update, params: { id: venue.to_param, venue: { name: "" } }
        expect(response).to redirect_to(edit_venue_path(venue))
        expect(flash[:alert]).to be_present
      end
  end

  describe "DELETE #destroy" do
    let!(:venue) { create(:venue, tenant: tenant) }

    it "destroys the requested venue" do
      expect {
        delete :destroy, params: { id: venue.to_param }
      }.to change(Venue, :count).by(-1)
    end

    it "redirects to the venues list" do
      delete :destroy, params: { id: venue.to_param }
      expect(response).to redirect_to(venues_path)
    end
  end
end