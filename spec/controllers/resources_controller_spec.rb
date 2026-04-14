require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
  let(:tenant)    { create(:tenant) }
  let!(:venue1)   { create(:venue, tenant: tenant, name: "Library A", description: "Quiet study space") }
  let!(:venue2)   { create(:venue, tenant: tenant, name: "Gymnasium", description: "Sports hall") }
  let!(:equipment1) { create(:equipment, tenant: tenant, name: "Projector X", description: "HD Projector", location: "Room 101") }
  let!(:equipment2) { create(:equipment, tenant: tenant, name: "Microphone", description: "Wireless mic", location: "Auditorium") }

  describe "GET #index" do
    context "without search params" do
      it "returns all venues and equipment sorted by name" do
        get :index
        expect(assigns(:resources)).to eq([equipment2, venue2, venue1, equipment1].sort_by(&:name))
        expect(assigns(:resources).map(&:name)).to include("Library A", "Gymnasium", "Projector X", "Microphone")
      end
    end

    context "with search params" do
      it "returns matching venues and equipment by name" do
        get :index, params: { q: { name_or_description_or_location_cont: "Library" } }
        expect(assigns(:resources)).to contain_exactly(venue1)
      end

      it "returns matching equipment by description" do
        get :index, params: { q: { name_or_description_or_location_cont: "Projector" } }
        expect(assigns(:resources)).to contain_exactly(equipment1)
      end

      it "returns matching equipment by location" do
        get :index, params: { q: { name_or_description_or_location_cont: "Auditorium" } }
        expect(assigns(:resources)).to contain_exactly(equipment2)
      end

      it "returns combined results when both venue and equipment match" do
        get :index, params: { q: { name_or_description_or_location_cont: "Room" } }
        expect(assigns(:resources)).to include(equipment1)
      end
    end
  end
end
