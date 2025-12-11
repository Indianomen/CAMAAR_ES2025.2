class PasswordResetMailer < ApplicationMailer
  default from: 'noreply@camaar.unb.br'
  
  # Envia email com link para reset de senha
  def reset_password(user)
    @user = user
    @reset_link = generate_reset_link(user)
    @user_type = user.class.name == 'Aluno' ? 'Aluno' : 'Professor'
    
    mail(
      to: @user.email,
      subject: 'CAMAAR - Redefinir sua senha'
    ) do |format|
      format.html
      format.text
    end
  end
  
  private
  
  # Gera link seguro de reset usando signed_id
  def generate_reset_link(user)
    # signed_id com validade de 2 horas e purpose específico
    token = user.signed_id(purpose: :password_reset, expires_in: 2.hours)
    
    Rails.application.routes.url_helpers.edit_password_reset_url(
      id: token,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      port: Rails.application.config.action_mailer.default_url_options[:port]
    )
  end
end
