require 'rails_helper'

RSpec.describe UserInviteJob, type: :job do
  describe '#perform' do
    let(:aluno1) do
      create(:aluno, 
        email: 'aluno1@test.com', 
        matricula: '190001', 
        usuario: 'aluno1',
        registered: false)
    end
    
    let(:aluno2) do
      create(:aluno, 
        email: 'aluno2@test.com', 
        matricula: '190002', 
        usuario: 'aluno2',
        registered: false)
    end
    
    let(:aluno3) do
      create(:aluno, 
        email: 'aluno3@test.com', 
        matricula: '190003', 
        usuario: 'aluno3',
        registered: true) 
    end
    
    let(:professor1) do
      create(:professor, 
        email: 'prof1@test.com', 
        usuario: 'prof1',
        registered: false)
    end
    
    let(:professor2) do
      create(:professor, 
        email: 'prof2@test.com', 
        usuario: 'prof2',
        registered: true)
    end
    
    let(:user_ids) do
      {
        alunos: [aluno1.id, aluno2.id, aluno3.id],
        professores: [professor1.id, professor2.id]
      }
    end

    it 'enfileira emails apenas para usuários com registered: false' do
      expect {
        described_class.perform_now(user_ids)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(3).times
    end

    it 'envia email para alunos pendentes' do
      mailer_double = double('UserInviteMailer')
      allow(UserInviteMailer).to receive(:invite_student).and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_later)

      described_class.perform_now(user_ids)

      expect(UserInviteMailer).to have_received(:invite_student).with(aluno1)
      expect(UserInviteMailer).to have_received(:invite_student).with(aluno2)
      expect(UserInviteMailer).not_to have_received(:invite_student).with(aluno3)
    end

    it 'envia email para professores pendentes' do
      mailer_double = double('UserInviteMailer')
      allow(UserInviteMailer).to receive(:invite_professor).and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_later)

      described_class.perform_now(user_ids)

      expect(UserInviteMailer).to have_received(:invite_professor).with(professor1)
      expect(UserInviteMailer).not_to have_received(:invite_professor).with(professor2)
    end

    it 'loga informações sobre o processamento' do
      allow(Rails.logger).to receive(:info)

      described_class.perform_now(user_ids)

      expect(Rails.logger).to have_received(:info).with(/UserInviteJob started/)
      expect(Rails.logger).to have_received(:info).with(/UserInviteJob completed: 3 emails enqueued/)
    end

    context 'quando não há usuários pendentes' do
      let(:empty_ids) { { alunos: [], professores: [] } }

      it 'não enfileira nenhum email' do
        expect {
          described_class.perform_now(empty_ids)
        }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end
end