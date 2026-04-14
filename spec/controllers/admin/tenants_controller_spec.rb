require "rails_helper"

RSpec.describe Admin::TenantsController, type: :controller do
  let(:staff_user)   { create(:user, :staff) }
  let(:student_user) { create(:user, :student) }
  let(:admin_user)   { create(:user, :admin) }
  let!(:tenant)      { create(:tenant) }

  before do
    sign_in(staff_user)
  end

  describe "GET #index" do
    it "assigns all tenants ordered by name" do
      get :index
      expect(assigns(:tenants)).to match_array(Tenant.order(:name))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "assigns a new tenant" do
      get :new
      expect(assigns(:tenant)).to be_a_new(Tenant)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new tenant and redirects" do
        expect {
          post :create, params: { tenant: { name: "Mathematics Department", slug: "mathematics-department" } }
        }.to change(Tenant, :count).by(1)
        expect(response).to redirect_to(admin_tenants_path)
        expect(flash[:notice]).to match(/created successfully/)
      end
    end

    context "with invalid params" do
      it "renders new template" do
        post :create, params: { tenant: { name: "" } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested tenant" do
      get :edit, params: { id: tenant.id }
      expect(assigns(:tenant)).to eq(tenant)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates tenant and redirects" do
        patch :update, params: { id: tenant.id, tenant: { name: "Updated Department" } }
        expect(tenant.reload.name).to eq("Updated Department")
        expect(response).to redirect_to(admin_tenants_path)
        expect(flash[:notice]).to match(/updated successfully/)
      end
    end

    context "with invalid params" do
      it "renders edit template" do
        patch :update, params: { id: tenant.id, tenant: { name: "" } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when tenant is Admin" do
      let!(:admin_tenant) { create(:admin_tenant) }

      it "does not delete and redirects with alert" do
        delete :destroy, params: { id: admin_tenant.id }
        expect(Tenant.exists?(admin_tenant.id)).to be true
        expect(response).to redirect_to(admin_tenants_path)
        expect(flash[:alert]).to match(/cannot be deleted/)
      end
    end

    context "when tenant has associated resources" do
      let!(:tenant_with_venue) { create(:tenant) }
      let!(:venue) { create(:venue, tenant: tenant_with_venue) }

      it "does not delete and redirects with alert" do
        delete :destroy, params: { id: tenant_with_venue.id }
        expect(Tenant.exists?(tenant_with_venue.id)).to be true
        expect(flash[:alert]).to match(/associated resources/)
      end
    end

    context "when tenant has no associations and is not Admin" do
      let!(:deletable_tenant) { create(:tenant, name: "Deletable") }

      it "deletes tenant and redirects with notice" do
        expect {
          delete :destroy, params: { id: deletable_tenant.id }
        }.to change(Tenant, :count).by(-1)
        expect(response).to redirect_to(admin_tenants_path)
        expect(flash[:notice]).to match(/Department deleted/)
      end
    end
  end

  describe "authorization" do
    it "denies access for student users" do
      sign_out(staff_user)
      sign_in(student_user)
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end

    it "allows staff users" do
      sign_out(staff_user)
      sign_in(staff_user)
      get :index
      expect(response).to have_http_status(:ok)
    end
    
    it "allows admin users" do
      sign_out(staff_user)
      sign_in(admin_user)
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
