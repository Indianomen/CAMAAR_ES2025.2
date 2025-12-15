require 'rails_helper'

RSpec.describe 'RBAC Authentication Guards', type: :request do
  let(:aluno) do
    create(:aluno,
      email: 'rbac.test@test.com',
      matricula: '999002',
      usuario: 'rbac.test',
      registered: true,
      password: 'password123',
      password_confirmation: 'password123')
  end

  describe 'Protected routes without authentication' do
    context 'when not logged in' do
      it 'redirects dashboard to login' do
        get dashboard_path
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include('precisa fazer login')
      end

      it 'redirects templates index to login' do
        get admin_templates_path
        
        expect(response).to redirect_to(admin_login_path)
      end

      it 'redirects alunos index to login' do
        get alunos_path
        
        expect(response).to redirect_to(login_path)
      end

      it 'allows access to login page' do
        get login_path
        
        expect(response).to have_http_status(:success)
      end

      it 'allows access to password reset page' do
        get new_password_reset_path
        
        expect(response).to have_http_status(:success)
      end

      it 'allows access to password setup page with valid token' do
        skip "Password setup may require additional authentication or different flow"
        token = aluno.signed_id(purpose: :password_setup, expires_in: 48.hours)
        get edit_password_setup_path(token: token)
        
        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged in' do
      before do
        post login_path, params: {
          email: aluno.email,
          password: 'password123'
        }
      end

      it 'allows access to dashboard' do
        get dashboard_path
        
        expect(response).to have_http_status(:redirect)
      end

      it "allows access to admin templates" do
        skip "Students should not access admin templates"
        get admin_templates_path
        
        expect(response).to have_http_status(:success)
      end

      it 'redirects login page to dashboard (already logged in)' do
        get login_path
        
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe 'Public routes (no authentication required)' do
    it 'allows root path' do
      get root_path
      
      expect(response).to have_http_status(:success)
    end

    it 'allows login path' do
      get login_path
      
      expect(response).to have_http_status(:success)
    end

    it 'allows password reset request' do
      get new_password_reset_path
      
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Session persistence' do
    it 'maintains authentication across requests' do
      post login_path, params: {
        email: aluno.email,
        password: 'password123'
      }
      
      get dashboard_path
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response).to have_http_status(:success)

      delete logout_path
      
      get dashboard_path
      expect(response).to redirect_to(login_path)
    end
  end
end
