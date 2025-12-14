require 'rails_helper'

RSpec.describe "Aluno::Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success when authenticated" do
      aluno = create(:aluno, email: 'test@test.com', password: 'password123', registered: true)
      post login_path, params: { email: aluno.email, password: 'password123' }
      get student_dashboard_path
      expect(response).to have_http_status(:success)
    end
  end

end
