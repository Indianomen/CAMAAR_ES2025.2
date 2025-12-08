# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserInviteMailer, type: :mailer do
  # Helper para extrair corpo de email decodificado (sem Quoted-Printable)
  def email_body(mail)
    if mail.multipart?
      mail.text_part.body.decoded
    else
      mail.body.decoded
    end
  end

  describe '#invite_student' do
    let(:aluno) do
      create(:aluno, 
        nome: 'João Silva', 
        email: 'joao.silva@test.com',
        matricula: '200001',
        usuario: 'joao.silva',
        registered: false)
    end
    let(:mail) { described_class.invite_student(aluno) }

    it 'renderiza o assunto' do
      expect(mail.subject).to eq('Bem-vindo ao CAMAAR - Configure sua senha de acesso')
    end

    it 'envia para o email do aluno' do
      expect(mail.to).to eq([aluno.email])
    end

    it 'envia do email padrão' do
      expect(mail.from).to eq(['noreply@camaar.unb.br'])
    end

    it 'inclui o nome do aluno no corpo' do
      body = email_body(mail)
      expect(body).to include(aluno.nome)
    end

    it 'inclui link de configuração de senha com token' do
      body = email_body(mail)
      expect(body).to include('password_setups')
      # Token está no path, não como query param: /password_setups/{token}/edit
      expect(body).to match(%r{password_setups/[A-Za-z0-9_-]+/edit})
    end

    it 'gera token signed_id com purpose password_setup' do
      # Extrai o token do corpo do email
      body = email_body(mail)
      # Formato: http://example.com/password_setups/{TOKEN}/edit
      token_match = body.match(%r{password_setups/([A-Za-z0-9_-]+)/edit})
      expect(token_match).to be_present
      
      token = token_match[1]
      
      # Verifica se o token é válido
      decoded_user = Aluno.find_signed(token, purpose: :password_setup)
      expect(decoded_user).to eq(aluno)
    end

    it 'renderiza versão HTML e texto' do
      expect(mail.html_part.body.decoded).to include('CAMAAR')
      expect(mail.text_part.body.decoded).to include('CAMAAR')
    end
  end

  describe '#invite_professor' do
    let(:professor) do
      create(:professor, 
        nome: 'Maria Santos', 
        email: 'maria.santos@test.com',
        usuario: 'maria.santos',
        registered: false)
    end
    let(:mail) { described_class.invite_professor(professor) }

    it 'renderiza o assunto' do
      expect(mail.subject).to eq('Acesso ao CAMAAR - Configure sua senha de acesso')
    end

    it 'envia para o email do professor' do
      expect(mail.to).to eq([professor.email])
    end

    it 'inclui o nome do professor no corpo' do
      body = email_body(mail)
      expect(body).to include(professor.nome)
    end

    it 'inclui link de configuração de senha com token' do
      body = email_body(mail)
      expect(body).to include('password_setups')
      expect(body).to match(%r{password_setups/[A-Za-z0-9_-]+/edit})
    end

    it 'gera token signed_id com purpose password_setup' do
      body = email_body(mail)
      token_match = body.match(%r{password_setups/([A-Za-z0-9_-]+)/edit})
      expect(token_match).to be_present
      
      token = token_match[1]
      
      decoded_user = Professor.find_signed(token, purpose: :password_setup)
      expect(decoded_user).to eq(professor)
    end
  end

  describe 'token expiration' do
    let(:aluno) do
      create(:aluno,
        email: 'expiration.test@test.com',
        matricula: '200999',
        usuario: 'expiration.test',
        registered: false)
    end
    let(:mail) { described_class.invite_student(aluno) }

    it 'token expira após 48 horas' do
      body = email_body(mail)
      token_match = body.match(%r{password_setups/([A-Za-z0-9_-]+)/edit})
      token = token_match[1]
      
      # Simula viagem no tempo para 49 horas no futuro
      travel_to 49.hours.from_now do
        decoded_user = Aluno.find_signed(token, purpose: :password_setup)
        expect(decoded_user).to be_nil
      end
    end

    it 'token é válido dentro de 48 horas' do
      body = email_body(mail)
      token_match = body.match(%r{password_setups/([A-Za-z0-9_-]+)/edit})
      token = token_match[1]
      
      # Simula viagem no tempo para 47 horas no futuro
      travel_to 47.hours.from_now do
        decoded_user = Aluno.find_signed(token, purpose: :password_setup)
        expect(decoded_user).to eq(aluno)
      end
    end
  end
end
