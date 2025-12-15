class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]
  
  def new
  end
  
  def create
    email = params[:email]
    password = params[:password]
    
    user = Aluno.find_by(email: email)
    user_type = 'Aluno'
    
    if user.nil?
      user = Professor.find_by(email: email)
      user_type = 'Professor'
    end
    
    if user && user.registered? && user.authenticate(password)
      session[:user_id] = user.id
      session[:user_type] = user_type
      
      redirect_to dashboard_path, notice: 'Login realizado com sucesso!'
    else
      @error_message = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session.delete(:user_id)
    session.delete(:user_type)
    redirect_to login_path, notice: 'Logout realizado com sucesso'
  end
  
  private
  
  def redirect_if_logged_in
    if session[:user_id] && session[:user_type]
      user_class = session[:user_type].constantize
      user = user_class.find_by(id: session[:user_id])
      
      if user
        redirect_to dashboard_path, notice: 'Você já está logado!'
      else
        session.delete(:user_id)
        session.delete(:user_type)
      end
    end
  end
end