require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:staff_user)   { create(:user, :staff) }
  let(:student_user) { create(:user, :student) }
  let(:admin_user)   { create(:user, role: "admin") }
  let(:tenant)       { create(:tenant) }

  before do
    sign_in(staff_user)
  end

  describe "GET #new" do
    it "assigns a new user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) do
        {
          user: {
            email: "staff@example.com",
            password: "password123",
            tenant_id: tenant.id
          }
        }
      end

      it "creates a new staff user" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)

        created_user = User.last
        expect(created_user.role).to eq("staff")
        expect(response).to redirect_to(staff_dashboard_path)
        expect(flash[:notice]).to match(/Staff account created/)
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          user: {
            email: "",
            password: "short",
            tenant_id: tenant.id
          }
        }
      end

      it "does not create user and renders new" do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe "authorization" do
    it "denies access for student users" do
      sign_out(staff_user)
      sign_in(student_user)
      get :new
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end

    it "allows staff users" do
      sign_out(staff_user)
      sign_in(staff_user)
      get :new
      expect(response).to have_http_status(:ok)
    end

    it "allows admin users" do
      sign_out(staff_user)
      sign_in(admin_user)
      get :new
      expect(response).to have_http_status(:ok)
    end
  end
end
