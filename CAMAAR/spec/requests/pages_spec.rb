require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get "/pages/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard" do
    it "returns http success" do
      get "/pages/dashboard"
      expect(response).to have_http_status(:success)
    end
  end

end
