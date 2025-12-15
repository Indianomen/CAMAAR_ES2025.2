class PasswordSetupsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update], raise: false
  
  before_action :find_user_by_token, only: [:edit, :update]
  before_action :check_user_already_active, only: [:edit]

  def edit
  end

  def update
    if @user.update(user_params)
      @user.update_column(:registered, true)
      
      session[:user_id] = @user.id
      session[:user_type] = @user.class.name
      
      redirect_to dashboard_path, notice: 'Senha definida com sucesso! Bem-vindo ao CAMAAR.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user_by_token
    token = params[:token]
    
    @user = Aluno.find_signed(token, purpose: :password_setup) || 
            Professor.find_signed(token, purpose: :password_setup)

    if @user.nil?
      redirect_to login_path, alert: 'O link de configuração de senha é inválido ou expirou. Solicite um novo.'
    end
  end

  def check_user_already_active
    if @user&.registered?
      redirect_to login_path, alert: 'Sua conta já está ativa. Por favor, faça login.'
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end