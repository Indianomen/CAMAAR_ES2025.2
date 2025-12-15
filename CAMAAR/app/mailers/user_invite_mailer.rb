class UserInviteMailer < ApplicationMailer
  default from: 'noreply@camaar.unb.br'
  
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
  
  def generate_setup_link(user)
    token = user.signed_id(purpose: :password_setup, expires_in: 48.hours)
    
    Rails.application.routes.url_helpers.edit_password_setup_url(
      token: token,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      port: Rails.application.config.action_mailer.default_url_options[:port]
    )
  end
end
