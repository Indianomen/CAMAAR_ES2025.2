# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Session Management', type: :request do
  let(:aluno) do
    create(:aluno,
      email: 'session.test@test.com',
      matricula: '999001',
      usuario: 'session.test',
      registered: true,
      password: 'password123',
      password_confirmation: 'password123')
  end

  describe 'Redirect when already logged in' do
    context 'when user is already logged in' do
      before do
        # Simula login
        post login_path, params: {
          email: aluno.email,
          password: 'password123'
        }
      end

      it 'redirects to dashboard when accessing login page' do
        get login_path
        
        expect(response).to redirect_to(dashboard_path)
        follow_redirect!
        expect(response.body).to include('já está logado')
      end

      it 'redirects to dashboard when trying to login again' do
        post login_path, params: {
          email: aluno.email,
          password: 'password123'
        }
        
        expect(response).to redirect_to(dashboard_path)
      end

      it 'allows logout' do
        delete logout_path
        
        expect(response).to redirect_to(login_path)
        expect(session[:user_id]).to be_nil
        expect(session[:user_type]).to be_nil
      end
    end

    context 'when user is not logged in' do
      it 'shows login page' do
        get login_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include('CAMAAR')
        expect(response.body).to include('Email')
      end
    end

    context 'when session has invalid user_id' do
      before do
        # Cria sessão com ID inexistente
        post login_path, params: {
          email: aluno.email,
          password: 'password123'
        }
        
        # Deleta o usuário mas mantém a sessão
        aluno.destroy
      end

      it 'clears invalid session and shows login page' do
        get login_path
        
        expect(response).to have_http_status(:success)
        expect(session[:user_id]).to be_nil
        expect(session[:user_type]).to be_nil
      end
    end
  end

  describe 'Session persistence across tabs' do
    it 'maintains session when opening new tab' do
      # Tab 1: Login
      post login_path, params: {
        email: aluno.email,
        password: 'password123'
      }
      
      expect(session[:user_id]).to eq(aluno.id)
      expect(session[:user_type]).to eq('Aluno')
      
      # Tab 2: Acessa dashboard (mesma sessão)
      get dashboard_path
      expect(response).to have_http_status(:success)
      
      # Tab 3: Tenta acessar login (deve redirecionar)
      get login_path
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
