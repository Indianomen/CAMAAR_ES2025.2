require 'rails_helper'

RSpec.feature "StudentAnswersForms", type: :feature do
  pending "add some scenarios (or delete) #{__FILE__}"
end
RSpec.describe "Student answers forms", type: :feature do
  let(:student) { create(:student) }
  let(:form) { create(:form) }
  let(:question) { create(:pergunta, formulario: formulario) }
  
  before do
    login_as(aluno)
    aluno.formularios << formulario
  end
  
  scenario "student views pending forms" do
    visit aluno_dashboard_path
    expect(page).to have_content("Formulários Pendentes")
    expect(page).to have_selector(".form-item", count: 1)
  end
  
  scenario "student submits form answers" do
    visit respond_formulario_path(formulario)
    
    fill_in "resposta_#{pergunta.id}", with: "Excelente professor!"
    click_button "Enviar Formulário"
    
    expect(page).to have_content("Formulário enviado com sucesso!")
    expect(aluno.formularios_respostas).to include(formulario)
  end
end