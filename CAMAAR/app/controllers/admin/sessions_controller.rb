module Admin
  class SessionsController < ApplicationController
    layout "admin"
    
    # Permite acesso às páginas de login sem autenticação
    skip_before_action :authenticate_administrador!, only: [:new, :create]

    def new
    end

    def create
      administrador = Administrador.find_by(usuario: params[:usuario])

      if administrador&.authenticate(params[:password])
        session[:administrador_id] = administrador.id
        redirect_to admin_root_path
      else
        flash[:alert] = "Usuário ou senha inválidos"
        render :new
      end
    end

    def destroy
      session.delete(:administrador_id)
      redirect_to admin_login_path
    end
  end
end
