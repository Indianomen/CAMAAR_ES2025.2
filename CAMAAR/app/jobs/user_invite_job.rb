# app/jobs/user_invite_job.rb
class UserInviteJob < ApplicationJob
  queue_as :default
  
  # Retry strategy para falhas temporárias de SMTP
  retry_on Net::SMTPServerBusy, wait: 5.minutes, attempts: 3
  retry_on Net::SMTPAuthenticationError, wait: 10.minutes, attempts: 2
  
  # Não retenta em erros permanentes (ex: email inválido)
  discard_on Net::SMTPFatalError do |job, error|
    Rails.logger.error "SMTP Fatal Error in UserInviteJob: #{error.message}"
    Rails.logger.error "Job arguments: #{job.arguments.inspect}"
  end
  
  # Argumentos esperados:
  # user_ids = { alunos: [1, 2, 3], professores: [4, 5] }
  def perform(user_ids)
    Rails.logger.info "UserInviteJob started with #{user_ids.inspect}"
    
    sent_count = 0
    
    # Envia emails para alunos pendentes
    if user_ids[:alunos].present?
      Aluno.where(id: user_ids[:alunos], registered: false).find_each do |aluno|
        UserInviteMailer.invite_student(aluno).deliver_later
        sent_count += 1
      end
    end
    
    # Envia emails para professores pendentes
    if user_ids[:professores].present?
      Professor.where(id: user_ids[:professores], registered: false).find_each do |professor|
        UserInviteMailer.invite_professor(professor).deliver_later
        sent_count += 1
      end
    end
    
    Rails.logger.info "UserInviteJob completed: #{sent_count} emails enqueued"
  end
end
