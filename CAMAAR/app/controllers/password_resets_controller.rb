class PasswordResetsController < ApplicationController
  before_action :find_user_by_token, only: [:edit, :update]
  
  # GET /password_resets/new
  # Formulário para solicitar reset de senha
  def new
  end
  
  # POST /password_resets
  # Processa solicitação e envia email com link de reset
  def create
    email = params[:email]
    
    # Tenta encontrar usuário (Aluno ou Professor)
    @user = Aluno.find_by(email: email) || Professor.find_by(email: email)
    
    if @user
      # Envia email com link de reset usando signed_id
      PasswordResetMailer.reset_password(@user).deliver_later
      
      redirect_to login_path, notice: 'Instruções de reset de senha foram enviadas para seu email.'
    else
      flash.now[:alert] = 'Email não encontrado'
      render :new, status: :unprocessable_entity
    end
  end
  
  # GET /password_resets/:id/edit
  # Formulário para definir nova senha
  def edit
    # @user já foi definido pelo before_action
  end
  
  # PATCH/PUT /password_resets/:id
  # Atualiza a senha do usuário
  def update
    # Atualiza a senha usando has_secure_password
    if @user.update(user_params)
      # HAPPY PATH: Senha atualizada com sucesso
      
      # Marca como registered se ainda não estiver
      @user.update_column(:registered, true) unless @user.registered?
      
      redirect_to login_path, notice: 'Senha atualizada com sucesso! Faça login com sua nova senha.'
    else
      # SAD PATH: Senha inválida (validações falharam)
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  # Encontra o usuário usando signed_id token
  def find_user_by_token
    token = params[:id]
    
    # Tenta encontrar Aluno ou Professor usando signed_id
    # O purpose 'password_reset' garante que tokens de outras funcionalidades não funcionem
    @user = Aluno.find_signed(token, purpose: :password_reset) || 
            Professor.find_signed(token, purpose: :password_reset)
    
    # SAD PATH: Token expirado, inválido ou purpose incorreto
    if @user.nil?
      redirect_to login_path, alert: 'O link de reset de senha é inválido ou expirou. Solicite um novo.'
    end
  end
  
  # Strong parameters para senha
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
