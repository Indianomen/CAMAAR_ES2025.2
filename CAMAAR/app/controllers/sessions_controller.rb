class SessionsController < ApplicationController
  # Redireciona usuários já logados para o dashboard
  before_action :redirect_if_logged_in, only: [:new, :create]
  
  def new
    # Renderiza formulário de login (apenas se não estiver logado)
  end
  
  def create
    # Tenta encontrar o usuário por email (pode ser Aluno ou Professor)
    email = params[:email]
    password = params[:password]
    
    # Tenta autenticar como Aluno
    user = Aluno.find_by(email: email)
    user_type = 'Aluno'
    
    # Se não encontrou como Aluno, tenta como Professor
    if user.nil?
      user = Professor.find_by(email: email)
      user_type = 'Professor'
    end
    
    # Verifica se usuário existe, está registrado e senha está correta
    if user && user.registered? && user.authenticate(password)
      # Login bem-sucedido
      session[:user_id] = user.id
      session[:user_type] = user_type
      
      redirect_to dashboard_path, notice: 'Login realizado com sucesso!'
    else
      # Login falhou - renderiza com mensagem de erro
      @error_message = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    # Limpa a sessão
    session.delete(:user_id)
    session.delete(:user_type)
    redirect_to login_path, notice: 'Logout realizado com sucesso'
  end
  
  private
  
  # Redireciona usuários já autenticados para o dashboard
  def redirect_if_logged_in
    if session[:user_id] && session[:user_type]
      # Verifica se o usuário ainda existe no banco
      user_class = session[:user_type].constantize
      user = user_class.find_by(id: session[:user_id])
      
      if user
        # Usuário válido e logado - redireciona para dashboard
        redirect_to dashboard_path, notice: 'Você já está logado!'
      else
        # Sessão inválida (usuário deletado) - limpa sessão
        session.delete(:user_id)
        session.delete(:user_type)
      end
    end
  end
end