module AuthenticationHelper
  def set_session_for(user)
    return unless respond_to?(:session)
    session[:user_id] = user.id
    session[:user_type] = user.class.name
  end
  
  def stub_admin_auth_request(admin = nil)
    admin ||= create(:administrador)

    allow_any_instance_of(Admin::ApplicationController)
      .to receive(:current_administrador).and_return(admin)

    allow_any_instance_of(Admin::ApplicationController)
      .to receive(:administrador_signed_in?).and_return(true)

    if Admin::ApplicationController.method_defined?(:require_login)
      allow_any_instance_of(Admin::ApplicationController)
        .to receive(:require_login).and_return(true)
    end

    admin
  end

  RSpec.configure do |config|
    config.include AuthenticationHelper, type: :controller
    config.include AuthenticationHelper, type: :request
  end


  def login_as_admin(admin = nil)
    admin ||= create(:administrador)
    set_session_for(admin)
    
    allow(controller).to receive(:current_user).and_return(admin)
    
    controller_name = controller.class.name
    
    case controller_name
    when /^Admin::/
      allow(controller).to receive(:current_administrador).and_return(admin)
      allow(controller).to receive(:authenticate_administrador!).and_return(true)
      allow(controller).to receive(:require_login).and_return(true)
    else
      allow(controller).to receive(:require_login).and_return(true)
      if controller.respond_to?(:current_administrador)
        allow(controller).to receive(:current_administrador).and_return(admin)
      end
    end
    
    admin
  end
  
  def login_as_professor(professor = nil)
    professor ||= create(:professor)
    set_session_for(professor)
    allow(controller).to receive(:current_user).and_return(professor)
    allow(controller).to receive(:require_login).and_return(true)
    professor
  end
  
  def login_as_aluno(aluno = nil)
    aluno ||= create(:aluno)
    set_session_for(aluno)
    
    allow(controller).to receive(:current_user).and_return(aluno)
    allow(controller).to receive(:logged_in?).and_return(true)
    
    controller_name = controller.class.name
    
    case controller_name
    when /^Student::/
      allow(controller).to receive(:current_aluno).and_return(aluno)
      allow(controller).to receive(:authenticate_aluno!).and_return(true)
      allow(controller).to receive(:require_login).and_return(true)
    else
      allow(controller).to receive(:require_login).and_return(true)
      if controller.respond_to?(:current_aluno)
        allow(controller).to receive(:current_aluno).and_return(aluno)
      end
    end
    
    aluno
  end
  
  def logout
    if respond_to?(:session)
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
    else
      visit logout_path if defined?(visit)
    end
  end
  
  def capybara_login_as(user, password: 'password123')
    case user.class.name
    when 'Administrador'
      visit admin_login_path
      fill_in 'Usuário', with: user.usuario
      fill_in 'Senha', with: password
      click_button 'Entrar'
    else
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Senha', with: password
      click_button 'Entrar'
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :controller
  config.include AuthenticationHelper, type: :feature
end