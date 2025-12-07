module AuthenticationHelper
  def login_as_admin(admin = nil)
    admin ||= create(:administrador)
    allow(controller).to receive(:current_user).and_return(admin)
    admin
  end
  
  def login_as_professor(professor = nil)
    professor ||= create(:professor)
    allow(controller).to receive(:current_user).and_return(professor)
    professor
  end
  
  def login_as_aluno(aluno = nil)
    aluno ||= create(:aluno)
    allow(controller).to receive(:current_user).and_return(aluno)
    aluno
  end
end