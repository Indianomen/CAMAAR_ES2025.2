
require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  describe 'GET /password_resets/new' do
    it 'renderiza o formulário de solicitação de reset' do
      get new_password_reset_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Esqueci Minha Senha')
      expect(response.body).to include('Email')
    end
  end

  describe 'POST /password_resets' do
    context 'com email válido de aluno' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.reset@test.com',
          matricula: '400001',
          usuario: 'aluno.reset',
          registered: true)
      end

      it 'envia email de reset' do
        expect {
          post password_resets_path, params: { email: aluno.email }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'PasswordResetMailer',
          'reset_password',
          'deliver_now',
          { args: [aluno] }
        )
      end

      it 'redireciona para login com mensagem de sucesso' do
        post password_resets_path, params: { email: aluno.email }
        
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to match(/instruções.*enviadas/i)
      end
    end

    context 'com email válido de professor' do
      let(:professor) do
        create(:professor,
          email: 'prof.reset@test.com',
          usuario: 'prof.reset',
          registered: true)
      end

      it 'envia email de reset para professor' do
        expect {
          post password_resets_path, params: { email: professor.email }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context 'com email não encontrado' do
      it 'renderiza formulário com erro' do
        post password_resets_path, params: { email: 'naoexiste@test.com' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('não encontrado')
      end

      it 'não envia email' do
        expect {
          post password_resets_path, params: { email: 'naoexiste@test.com' }
        }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end

  describe 'GET /password_resets/:id/edit' do
    context 'com token válido' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.edit@test.com',
          matricula: '400002',
          usuario: 'aluno.edit',
          registered: true)
      end
      let(:token) { aluno.signed_id(purpose: :password_reset, expires_in: 2.hours) }

      it 'renderiza o formulário de nova senha' do
        get edit_password_reset_path(id: token)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Definir Nova Senha')
        expect(response.body).to include(aluno.nome)
      end

      it 'expõe o usuário para a view' do
        get edit_password_reset_path(id: token)
        
        expect(assigns(:user)).to eq(aluno)
      end
    end

    context 'com token expirado' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.expired.reset@test.com',
          matricula: '400003',
          usuario: 'aluno.expired.reset',
          registered: true)
      end
      let(:expired_token) do
        travel_to 3.hours.ago do
          aluno.signed_id(purpose: :password_reset, expires_in: 2.hours)
        end
      end

      it 'redireciona para login com mensagem de erro' do
        get edit_password_reset_path(id: expired_token)
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to match(/expirou|inválido/i)
      end
    end

    context 'com token inválido' do
      it 'redireciona para login com mensagem de erro' do
        get edit_password_reset_path(id: 'token_invalido_123')
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to match(/inválido|expirou/i)
      end
    end
  end

  describe 'PATCH /password_resets/:id' do
    context 'com senha válida' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.update.reset@test.com',
          matricula: '400004',
          usuario: 'aluno.update.reset',
          registered: true,
          password: 'OldPassword123!',
          password_confirmation: 'OldPassword123!')
      end
      let(:token) { aluno.signed_id(purpose: :password_reset, expires_in: 2.hours) }
      let(:valid_params) do
        {
          user: {
            password: 'NewSecurePass123!',
            password_confirmation: 'NewSecurePass123!'
          }
        }
      end

      it 'atualiza a senha do usuário' do
        patch password_reset_path(id: token), params: valid_params
        
        aluno.reload
        expect(aluno.authenticate('NewSecurePass123!')).to eq(aluno)
        expect(aluno.authenticate('OldPassword123!')).to be_falsey
      end

      it 'redireciona para login com mensagem de sucesso' do
        patch password_reset_path(id: token), params: valid_params
        
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to match(/senha atualizada/i)
      end

      it 'marca usuário pendente como registered' do
        aluno.update_column(:registered, false)
        
        patch password_reset_path(id: token), params: valid_params
        
        aluno.reload
        expect(aluno.registered).to eq(true)
      end
    end

    context 'com senha inválida (muito curta)' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.short.reset@test.com',
          matricula: '400005',
          usuario: 'aluno.short.reset',
          registered: true,
          password: 'OldPassword123!',
          password_confirmation: 'OldPassword123!')
      end
      let(:token) { aluno.signed_id(purpose: :password_reset, expires_in: 2.hours) }
      let(:invalid_params) do
        {
          user: {
            password: '123',
            password_confirmation: '123'
          }
        }
      end

      it 'não atualiza a senha' do
        patch password_reset_path(id: token), params: invalid_params
        
        aluno.reload
        expect(aluno.authenticate('OldPassword123!')).to eq(aluno)
        expect(aluno.authenticate('123')).to be_falsey
      end

      it 'renderiza novamente o formulário com erros' do
        patch password_reset_path(id: token), params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/erro|curta|mínimo/i)
      end
    end

    context 'com confirmação de senha não coincidente' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.mismatch.reset@test.com',
          matricula: '400006',
          usuario: 'aluno.mismatch.reset',
          registered: true,
          password: 'OldPassword123!',
          password_confirmation: 'OldPassword123!')
      end
      let(:token) { aluno.signed_id(purpose: :password_reset, expires_in: 2.hours) }
      let(:mismatch_params) do
        {
          user: {
            password: 'Password123!',
            password_confirmation: 'DifferentPass123!'
          }
        }
      end

      it 'não atualiza a senha' do
        patch password_reset_path(id: token), params: mismatch_params
        
        aluno.reload
        expect(aluno.authenticate('OldPassword123!')).to eq(aluno)
      end

      it 'renderiza novamente o formulário com erros' do
        patch password_reset_path(id: token), params: mismatch_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/doesn.*t match|não confere/i)
      end
    end

    context 'com token expirado' do
      let(:aluno) do
        create(:aluno,
          email: 'aluno.expired.update@test.com',
          matricula: '400007',
          usuario: 'aluno.expired.update',
          registered: true,
          password: 'OldPassword123!',
          password_confirmation: 'OldPassword123!')
      end
      let(:expired_token) do
        travel_to 3.hours.ago do
          aluno.signed_id(purpose: :password_reset, expires_in: 2.hours)
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
        patch password_reset_path(id: expired_token), params: valid_params
        
        aluno.reload
        expect(aluno.authenticate('OldPassword123!')).to eq(aluno)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'Suporte a Professor' do
    context 'professor pode resetar senha' do
      let(:professor) do
        create(:professor,
          email: 'prof.reset.update@test.com',
          usuario: 'prof.reset.update',
          registered: true,
          password: 'OldProfPass123!',
          password_confirmation: 'OldProfPass123!')
      end
      let(:token) { professor.signed_id(purpose: :password_reset, expires_in: 2.hours) }
      let(:valid_params) do
        {
          user: {
            password: 'NewProfPass123!',
            password_confirmation: 'NewProfPass123!'
          }
        }
      end

      it 'renderiza formulário para professor' do
        get edit_password_reset_path(id: token)
        
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to eq(professor)
      end

      it 'atualiza senha do professor' do
        patch password_reset_path(id: token), params: valid_params
        
        professor.reload
        expect(professor.authenticate('NewProfPass123!')).to eq(professor)
      end
    end
  end
end
