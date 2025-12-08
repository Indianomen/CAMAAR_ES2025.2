module Admin
  class ApplicationController < ActionController::Base
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
      redirect_to admin_login_path unless administrador_signed_in?
    end
  end
end
