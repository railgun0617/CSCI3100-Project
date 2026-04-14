require 'rails_helper'

RSpec.describe ManageResourcesController, type: :controller do
  let(:tenant)       { create(:non_admin_tenant) }
  let(:admin_tenant) { create(:admin_tenant) }

  let(:student_user) { create(:user, :student, tenant: tenant) }
  let(:staff_user)   { create(:user, :staff, tenant: tenant) }
  let(:admin_user)   { create(:user, :staff, tenant: admin_tenant) }

  let!(:venue)       { create(:venue, tenant: tenant) }
  let!(:equipment)   { create(:equipment, tenant: tenant) }

  describe "GET #index" do
    context "as student" do
      before { sign_in(student_user) }

      it "denies access" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "as staff" do
      before { sign_in(staff_user) }

      it "executes the else branch and assigns tenant resources" do
        get :index
        expect(assigns(:venues)).to contain_exactly(venue)
        expect(assigns(:equipment)).to contain_exactly(equipment)
        # force evaluation
        expect(assigns(:venues).first.name).to eq(venue.name)
        expect(assigns(:equipment).first.name).to eq(equipment.name)
      end
    end

    context "as admin" do
      let!(:other_venue)     { create(:venue) }
      let!(:other_equipment) { create(:equipment) }

      before { sign_in(admin_user) }

      it "executes the admin branch and assigns all resources" do
        get :index
        expect(assigns(:venues)).to include(venue, other_venue)
        expect(assigns(:equipment)).to include(equipment, other_equipment)
        # force evaluation
        expect(assigns(:venues).map(&:name)).to include(venue.name, other_venue.name)
        expect(assigns(:equipment).map(&:name)).to include(equipment.name, other_equipment.name)
      end
    end

    context "as staff with search param" do
      before { sign_in(staff_user) }

      let!(:search_equipment)   { create(:equipment, tenant: tenant, name: "Laptop", description: "Computer for study") }
      let!(:search_venue) { create(:venue, tenant: tenant, name: "Library", description: "A place for student to study") }

      it "filters venues and equipment by search term" do
        get :index, params: { search: "Computer" }

        expect(assigns(:venues)).to be_empty
        expect(assigns(:equipment)).to contain_exactly(search_equipment)
        expect(assigns(:equipment).first.description).to include("Computer for study")
      end
    end
  end
end
