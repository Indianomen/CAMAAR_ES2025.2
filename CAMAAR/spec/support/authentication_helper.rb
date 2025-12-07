module AuthenticationHelper
  def login_as_admin(admin = nil)
    admin ||= create(:administrador)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    admin
  end
  
  def login_as_professor(professor = nil)
    professor ||= create(:professor)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(professor)
    professor
  end
  
  def login_as_aluno(aluno = nil)
    aluno ||= create(:aluno)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(aluno)
    aluno
  end
  
  def logout
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
  end
end