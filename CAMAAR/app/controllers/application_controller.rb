class ApplicationController < ActionController::Base
  helper_method :current_user
  
  # Mock temporário de autenticação
  # DAVI remove isso quando for implementar autenticação
  def current_user
    @current_user ||= Administrador.first
  end
end