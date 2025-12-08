module Admin
  class SessionsController < ApplicationController
    layout "admin"

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
