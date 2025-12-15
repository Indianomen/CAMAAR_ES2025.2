require 'rails_helper'

RSpec.describe 'PasswordSetups', type: :request do
  describe 'GET /password_setups/:token/edit' do
    context 'com token válido' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.setup@test.com',
          matricula: '300001',
          usuario: 'aluno.setup',
          registered: false)
      end
      let(:token) { aluno.signed_id(purpose: :password_setup, expires_in: 48.hours) }

      it 'renderiza o formulário de configuração de senha' do
        get edit_password_setup_path(token: token)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Definir Senha')
        expect(response.body).to include(aluno.nome)
      end

      it 'expõe o usuário para a view' do
        get edit_password_setup_path(token: token)
        
        expect(assigns(:user)).to eq(aluno)
      end
    end

    context 'com token expirado' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.expired@test.com',
          matricula: '300002',
          usuario: 'aluno.expired',
          registered: false)
      end
      let(:expired_token) do
        travel_to 50.hours.ago do
          aluno.signed_id(purpose: :password_setup, expires_in: 48.hours)
        end
      end

      it 'redireciona para login com mensagem de erro' do
        get edit_password_setup_path(token: expired_token)
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/expirou|inválido/i)
      end
    end

    context 'com token inválido' do
      it 'redireciona para login com mensagem de erro' do
        get edit_password_setup_path(token: 'token_invalido_123')
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/inválido|expirou/i)
      end
    end

    context 'com usuário já ativo (registered: true)' do
      let(:aluno_ativo) do
        create(:aluno,
          email: 'aluno.ativo@test.com',
          matricula: '300003',
          usuario: 'aluno.ativo',
          registered: true)
      end
      let(:token) { aluno_ativo.signed_id(purpose: :password_setup, expires_in: 48.hours) }

      it 'redireciona para login informando que conta já está ativa' do
        get edit_password_setup_path(token: token)
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/já está ativa/i)
      end
    end
  end

  describe 'PATCH /password_setups/:token' do
    context 'com senha válida' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.update@test.com',
          matricula: '300004',
          usuario: 'aluno.update',
          registered: false)
      end
      let(:token) { aluno.signed_id(purpose: :password_setup, expires_in: 48.hours) }
      let(:valid_params) do
        {
          user: {
            password: 'NewSecurePass123!',
            password_confirmation: 'NewSecurePass123!'
          }
        }
      end

      it 'atualiza a senha do usuário' do
        patch password_setup_path(token: token), params: valid_params
        
        aluno.reload
        expect(aluno.authenticate('NewSecurePass123!')).to eq(aluno)
      end

      it 'marca o usuário como registered: true' do
        patch password_setup_path(token: token), params: valid_params
        
        aluno.reload
        expect(aluno.registered).to eq(true)
      end

      it 'loga o usuário automaticamente' do
        patch password_setup_path(token: token), params: valid_params
        
        expect(session[:user_id]).to eq(aluno.id)
        expect(session[:user_type]).to eq('Aluno')
      end

      it 'redireciona para dashboard com mensagem de sucesso' do
        patch password_setup_path(token: token), params: valid_params
        
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to match(/sucesso/i)
      end
    end

    context 'com senha inválida (muito curta)' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.short@test.com',
          matricula: '300005',
          usuario: 'aluno.short',
          registered: false)
      end
      let(:token) { aluno.signed_id(purpose: :password_setup, expires_in: 48.hours) }
      let(:invalid_params) do
        {
          user: {
            password: '123',
            password_confirmation: '123'
          }
        }
      end

      it 'não atualiza a senha' do
        original_digest = aluno.password_digest
        
        patch password_setup_path(token: token), params: invalid_params
        
        aluno.reload
        expect(aluno.password_digest).to eq(original_digest)
      end

      it 'não marca como registered' do
        patch password_setup_path(token: token), params: invalid_params
        
        aluno.reload
        expect(aluno.registered).to eq(false)
      end

      it 'renderiza novamente o formulário com erros' do
        patch password_setup_path(token: token), params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('erro')
      end
    end

    context 'com confirmação de senha não coincidente' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.mismatch@test.com',
          matricula: '300006',
          usuario: 'aluno.mismatch',
          registered: false)
      end
      let(:token) { aluno.signed_id(purpose: :password_setup, expires_in: 48.hours) }
      let(:mismatch_params) do
        {
          user: {
            password: 'Password123!',
            password_confirmation: 'DifferentPass123!'
          }
        }
      end

      it 'não atualiza a senha' do
        original_digest = aluno.password_digest
        
        patch password_setup_path(token: token), params: mismatch_params
        
        aluno.reload
        expect(aluno.password_digest).to eq(original_digest)
      end

      it 'renderiza novamente o formulário com erros' do
        patch password_setup_path(token: token), params: mismatch_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/doesn.*t match|não confere/i)
      end
    end

    context 'com token expirado' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.expired.update@test.com',
          matricula: '300007',
          usuario: 'aluno.expired.update',
          registered: false)
      end
      let(:expired_token) do
        travel_to 50.hours.ago do
          aluno.signed_id(purpose: :password_setup, expires_in: 48.hours)
        end
      end
      let(:valid_params) do
        {
          user: {
            password: 'NewPass123!',
            password_confirmation: 'NewPass123!'
          }
        }
      end

      it 'redireciona para login sem atualizar senha' do
        original_digest = aluno.password_digest
        
        patch password_setup_path(token: expired_token), params: valid_params
        
        aluno.reload
        expect(aluno.password_digest).to eq(original_digest)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'Suporte a Professor' do
    context 'professor pode configurar senha' do
      let(:professor) do
        create(:professor,
          email: 'prof.setup@test.com',
          usuario: 'prof.setup',
          registered: false)
      end
      let(:token) { professor.signed_id(purpose: :password_setup, expires_in: 48.hours) }
      let(:valid_params) do
        {
          user: {
            password: 'ProfPass123!',
            password_confirmation: 'ProfPass123!'
          }
        }
      end

      it 'renderiza formulário para professor' do
        get edit_password_setup_path(token: token)
        
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to eq(professor)
      end

      it 'atualiza senha e marca como registered' do
        patch password_setup_path(token: token), params: valid_params
        
        professor.reload
        expect(professor.authenticate('ProfPass123!')).to eq(professor)
        expect(professor.registered).to eq(true)
      end

      it 'loga professor automaticamente' do
        patch password_setup_path(token: token), params: valid_params
        
        expect(session[:user_id]).to eq(professor.id)
        expect(session[:user_type]).to eq('Professor')
      end
    end
  end
end
