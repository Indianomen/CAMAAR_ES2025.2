module Admin
  class ApplicationController < ::ApplicationController
    layout "admin"
    before_action :authenticate_administrador!
    
    # Optional: Add any admin-specific helper methods
    helper_method :current_admin
    
    private
    
    def current_admin
      current_administrador  # Uses parent's method
    end
    
    # The authenticate_administrador! method from parent will redirect non-admins
    # If you need custom redirect for admin section:
    def authenticate_administrador!
      unless current_administrador
        flash[:alert] = 'Acesso restrito a administradores'
        redirect_to admin_login_path
      end
    end
  end
end