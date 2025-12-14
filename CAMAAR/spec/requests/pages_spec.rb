require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard" do
    it "redirects to login when not authenticated" do
      get dashboard_path
      expect(response).to have_http_status(:redirect)
    end
  end

end
