class PagesController < ApplicationController
  # Requer login para acessar qualquer página
  before_action :require_login
  
  def login
  end
  
  def dashboard
  end
end