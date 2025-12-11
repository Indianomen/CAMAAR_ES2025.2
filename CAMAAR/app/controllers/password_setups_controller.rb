class PasswordSetupsController < ApplicationController
  # Não exige login, pois o usuário ainda não tem senha configurada
  skip_before_action :verify_authenticity_token, only: [:update], raise: false
  
  before_action :find_user_by_token, only: [:edit, :update]
  before_action :check_user_already_active, only: [:edit]

  # GET /password_setups/:token/edit
  # Renderiza o formulário de configuração de senha
  def edit
    # @user já foi definido pelo before_action
    # A view será renderizada automaticamente
  end

  # PATCH/PUT /password_setups/:token
  # Salva a senha e ativa a conta
  def update
    # Atualiza a senha usando has_secure_password
    if @user.update(user_params)
      # HAPPY PATH: Senha salva com sucesso
      
      # Marca como registrado (ativo) - só executa se update foi bem-sucedido
      @user.update_column(:registered, true)
      
      # Loga o usuário automaticamente
      session[:user_id] = @user.id
      session[:user_type] = @user.class.name
      
      redirect_to dashboard_path, notice: 'Senha definida com sucesso! Bem-vindo ao CAMAAR.'
    else
      # SAD PATH: Senha inválida (validações do has_secure_password falharam)
      # Renderiza novamente o formulário com erros
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Encontra o usuário (Aluno ou Professor) usando o token signed_id
  def find_user_by_token
    token = params[:token]
    
    # Tenta encontrar Aluno ou Professor usando signed_id
    # O purpose 'password_setup' garante que tokens de outras funcionalidades não funcionem aqui
    @user = Aluno.find_signed(token, purpose: :password_setup) || 
            Professor.find_signed(token, purpose: :password_setup)

    # SAD PATH: Token expirado, inválido ou purpose incorreto
    if @user.nil?
      redirect_to login_path, alert: 'O link de configuração de senha é inválido ou expirou. Solicite um novo.'
    end
  end

  # Verifica se o usuário já está ativo (registered: true)
  # Se sim, redireciona para login
  def check_user_already_active
    if @user&.registered?
      redirect_to login_path, alert: 'Sua conta já está ativa. Por favor, faça login.'
    end
  end

  # Strong parameters para senha
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end