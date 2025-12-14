require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    it "creates a session" do
      aluno = create(:aluno, email: 'test@test.com', password: 'password123', registered: true)
      post login_path, params: { email: aluno.email, password: 'password123' }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /logout" do
    it "destroys the session" do
      aluno = create(:aluno, email: 'test2@test.com', password: 'password123', registered: true)
      post login_path, params: { email: aluno.email, password: 'password123' }
      delete logout_path
      expect(response).to have_http_status(:redirect)
    end
  end

end
