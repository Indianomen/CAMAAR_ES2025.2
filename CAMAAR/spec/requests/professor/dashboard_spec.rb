require 'rails_helper'

RSpec.describe "Professor::Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success when authenticated" do
      skip "Professor dashboard not yet implemented"
      professor = create(:professor, email: 'prof@test.com', password: 'password123')
      post login_path, params: { email: professor.email, password: 'password123' }
      get '/professor/dashboard'
      expect(response).to have_http_status(:success)
    end
  end

end
