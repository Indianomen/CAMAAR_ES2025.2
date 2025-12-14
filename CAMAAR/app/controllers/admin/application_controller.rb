module Admin
  class ApplicationController < ::ApplicationController
    layout "admin"
    before_action :authenticate_administrador!
    
    helper_method :current_administrador, :administrador_signed_in?

    private

    def current_administrador
      @current_administrador ||= Administrador.find_by(id: session[:administrador_id])
    end

    def administrador_signed_in?
      current_administrador.present?
    end

    def authenticate_administrador!
      unless administrador_signed_in?
        flash[:alert] = "Acesso restrito a administradores"
        redirect_to admin_login_path
      end
    end
  end
end