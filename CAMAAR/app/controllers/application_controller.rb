class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :current_administrador
  
  private
  
  # Retorna o usuário atual da sessão
  def current_user
    return nil unless session[:user_id] && session[:user_type]
    
    @current_user ||= begin
      user_class = session[:user_type].constantize
      user_class.find_by(id: session[:user_id])
    end
  end
  
  # Verifica se há um usuário logado
  def logged_in?
    current_user.present?
  end
  
  # Redireciona para login se não estiver autenticado
  def require_login
    unless logged_in?
      flash[:alert] = 'Você precisa fazer login para acessar esta página'
      redirect_to login_path
    end
  end
  
  # ADMIN SPECIFIC METHODS
  
  # Returns current admin if logged in as admin
  def current_administrador
    return nil unless logged_in? && current_user.is_a?(Administrador)
    current_user
  end
  
  # Authenticate admin
  def authenticate_administrador!
    unless current_administrador
      flash[:alert] = 'Acesso restrito a administradores'
      redirect_to admin_login_path
    end
  end
  
  # Similarly for other user types if needed
  def current_aluno
    return nil unless logged_in? && current_user.is_a?(Aluno)
    current_user
  end
  
  def authenticate_aluno!
    unless current_aluno
      flash[:alert] = 'Acesso restrito a alunos'
      redirect_to login_path
    end
  end
  
  def current_professor
    return nil unless logged_in? && current_user.is_a?(Professor)
    current_user
  end
  
  def authenticate_professor!
    unless current_professor
      flash[:alert] = 'Acesso restrito a professores'
      redirect_to login_path
    end
  end
end