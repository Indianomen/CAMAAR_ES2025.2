class ApplicationController < ActionController::Base
  helper_method :current_user
  
  private
  
  # Temporary mock for development
  # Remove this when real authentication is implemented
  def current_user
    # For now, return the first admin if exists
    # In tests, this will be mocked
    @current_user ||= Administrador.first
  end
end