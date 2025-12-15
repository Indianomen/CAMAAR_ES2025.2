class PasswordResetsController < ApplicationController
  before_action :find_user_by_token, only: [:edit, :update]
  
  def new
  end

  def create
    email = params[:email]
    
    @user = Aluno.find_by(email: email) || Professor.find_by(email: email)
    
    if @user

      PasswordResetMailer.reset_password(@user).deliver_later
      
      redirect_to login_path, notice: 'Instruções de reset de senha foram enviadas para seu email.'
    else
      flash.now[:alert] = 'Email não encontrado'
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      
      @user.update_column(:registered, true) unless @user.registered?
      
      redirect_to login_path, notice: 'Senha atualizada com sucesso! Faça login com sua nova senha.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def find_user_by_token
    token = params[:id]
    
    @user = Aluno.find_signed(token, purpose: :password_reset) || 
            Professor.find_signed(token, purpose: :password_reset)
    
    if @user.nil?
      redirect_to login_path, alert: 'O link de reset de senha é inválido ou expirou. Solicite um novo.'
    end
  end
  
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
