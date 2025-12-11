# app/mailers/user_invite_mailer.rb
class UserInviteMailer < ApplicationMailer
  default from: 'noreply@camaar.unb.br'
  
  # Envia email de convite para aluno
  # @param aluno [Aluno] Instância do aluno recém-criado
  def invite_student(aluno)
    @user = aluno
    @setup_link = generate_setup_link(aluno)
    @user_type = 'Aluno'
    
    mail(
      to: @user.email,
      subject: 'Bem-vindo ao CAMAAR - Configure sua senha de acesso'
    ) do |format|
      format.html
      format.text
    end
  end
  
  # Envia email de convite para professor
  # @param professor [Professor] Instância do professor recém-criado
  def invite_professor(professor)
    @user = professor
    @setup_link = generate_setup_link(professor)
    @user_type = 'Professor'
    
    mail(
      to: @user.email,
      subject: 'Acesso ao CAMAAR - Configure sua senha de acesso'
    ) do |format|
      format.html
      format.text
    end
  end
  
  private
  
  # Gera link seguro de configuração de senha usando signed_id
  # @param user [Aluno, Professor] Usuário para gerar o link
  # @return [String] URL completa com token assinado
  def generate_setup_link(user)
    # signed_id com validade de 48h e purpose específico
    # Purpose garante que token de password_reset não serve para setup
    token = user.signed_id(purpose: :password_setup, expires_in: 48.hours)
    
    # Gera URL completa usando url_helper
    # Em produção, configure host e port em config/environments/production.rb
    Rails.application.routes.url_helpers.edit_password_setup_url(
      token: token,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      port: Rails.application.config.action_mailer.default_url_options[:port]
    )
  end
end
