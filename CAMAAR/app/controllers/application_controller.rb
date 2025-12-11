class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  
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
end