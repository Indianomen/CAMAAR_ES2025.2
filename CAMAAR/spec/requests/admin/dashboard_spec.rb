require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success when authenticated" do
      admin = create(:administrador)
      post admin_login_path, params: { usuario: admin.usuario, password: 'password123' }
      get admin_root_path
      expect(response).to have_http_status(:success)
    end
  end

end
