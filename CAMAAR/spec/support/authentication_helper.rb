module AuthenticationHelper
  # Generic method to set session
  def set_session_for(user)
    session[:user_id] = user.id
    session[:user_type] = user.class.name
  end
  
  # For admin authentication
  def login_as_admin(admin = nil)
    admin ||= create(:administrador)
    set_session_for(admin)
    
    # Mock current_user for all controllers
    allow(controller).to receive(:current_user).and_return(admin)
    
    # Check controller type to decide what to mock
    controller_name = controller.class.name
    
    case controller_name
    when /^Admin::/
      # For Admin namespace controllers
      allow(controller).to receive(:current_administrador).and_return(admin)
      allow(controller).to receive(:authenticate_administrador!).and_return(true)
      # Also ensure require_login passes
      allow(controller).to receive(:require_login).and_return(true)
    else
      # For non-admin controllers (like TemplatesController)
      allow(controller).to receive(:require_login).and_return(true)
      # If they use current_administrador too, mock it
      if controller.respond_to?(:current_administrador)
        allow(controller).to receive(:current_administrador).and_return(admin)
      end
    end
    
    admin
  end
  
  # For professor authentication
  def login_as_professor(professor = nil)
    professor ||= create(:professor)
    set_session_for(professor)
    allow(controller).to receive(:current_user).and_return(professor)
    allow(controller).to receive(:require_login).and_return(true)
    professor
  end
  
  # For student authentication
  def login_as_aluno(aluno = nil)
    aluno ||= create(:aluno)
    set_session_for(aluno)
    
    # Mock current_user for all controllers
    allow(controller).to receive(:current_user).and_return(aluno)
    allow(controller).to receive(:logged_in?).and_return(true)
    
    # Check controller type to decide what to mock
    controller_name = controller.class.name
    
    case controller_name
    when /^Student::/
      # For Student namespace controllers
      allow(controller).to receive(:current_aluno).and_return(aluno)
      allow(controller).to receive(:authenticate_aluno!).and_return(true)
      # Also ensure require_login passes
      allow(controller).to receive(:require_login).and_return(true)
    else
      # For non-student controllers
      allow(controller).to receive(:require_login).and_return(true)
      # If they use current_aluno too, mock it
      if controller.respond_to?(:current_aluno)
        allow(controller).to receive(:current_aluno).and_return(aluno)
      end
    end
    
    aluno
  end
  
  # Logout helper
  def logout
    session[:user_id] = nil
    session[:user_type] = nil
    
    allow(controller).to receive(:current_user).and_return(nil)
    allow(controller).to receive(:require_login).and_call_original
    
    if controller.class.name.start_with?('Admin::')
      allow(controller).to receive(:current_administrador).and_return(nil)
      allow(controller).to receive(:authenticate_administrador!).and_call_original
    else
      allow(controller).to receive(:require_login).and_call_original
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :controller
end