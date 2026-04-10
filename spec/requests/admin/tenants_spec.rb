require 'rails_helper'

RSpec.describe "Admin::Tenants", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/tenants/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/tenants/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/tenants/create"
      expect(response).to have_http_status(:success)
    end
  end

end
