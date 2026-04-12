require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create (sign up)" do
    context "with permitted params" do
      it "creates a user with email and password" do
        expect {
          post :create, params: {
            user: {
              email: "newuser@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq("newuser@example.com")
        expect(user.valid_password?("password123")).to be true
      end
    end

    context "with unpermitted role param" do
      it "ignores the role attribute" do
        post :create, params: {
          user: {
            email: "roleuser@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: "admin" # should be ignored
          }
        }
        user = User.last
        expect(user.role).not_to eq("admin")
      end
    end
  end

  describe "PATCH #update (account update)" do
    let(:user) { create(:user, email: "old@example.com", password: "password123") }
    let(:tenant) { create(:tenant, name: "Test Tenant") }

    before do
      sign_in user
    end

    context "with permitted params" do
      it "updates email and tenant_id" do
        patch :update, params: {
          user: {
            email: "updated@example.com",
            current_password: "password123",
            tenant_id: tenant.id
          }
        }
        user.reload
        expect(user.email).to eq("updated@example.com")
        expect(user.tenant_id).to eq(tenant.id)
      end
    end

    context "with unpermitted role param" do
      it "does not update the role" do
        patch :update, params: {
          user: {
            email: "updated2@example.com",
            current_password: "password123",
            role: "admin"
          }
        }
        user.reload
        expect(user.role).not_to eq("admin")
      end
    end
  end
end
