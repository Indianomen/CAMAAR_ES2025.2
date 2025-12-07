require 'rails_helper'

RSpec.describe "Admin Templates", type: :feature do
  let(:admin) { create(:administrador) }
  
  before do
    login_as_admin(admin)
  end
  
  describe "viewing templates list" do
    it "shows templates index page" do
      create(:template, nome: "Template 1", administrador: admin)
      create(:template, nome: "Template 2", administrador: admin)
      
      visit templates_path
      
      expect(page).to have_content("Templates de Formulário")
      expect(page).to have_content("Template 1")
      expect(page).to have_content("Template 2")
      expect(page).to have_link("Novo Template")
    end
    
    it "only shows templates created by current admin" do
      other_admin = create(:administrador, usuario: "outro_admin")
      create(:template, nome: "Meu Template", administrador: admin)
      create(:template, nome: "Template de Outro", administrador: other_admin)
      
      visit templates_path
      
      expect(page).to have_content("Meu Template")
      expect(page).not_to have_content("Template de Outro")
    end
  end
  
  describe "creating a new template" do
    it "creates a template with questions" do
      visit new_template_path
      
      fill_in "Nome", with: "Avaliação de Disciplina 2024.1"
      
      # Preenche os campos de pesquisa com textos prontos
      within "#perguntas" do
        all("textarea").each_with_index do |textarea, index|
          fill_in textarea[:name], with: "Pergunta #{index + 1}?"
        end
      end
      
      click_button "Criar Template"
      
      expect(page).to have_content("Template criado com sucesso")
      expect(page).to have_content("Avaliação de Disciplina 2024.1")
      expect(page).to have_content("Pergunta 1?")
      expect(page).to have_content("Pergunta 2?")
      expect(page).to have_content("Pergunta 3?")
    end
    
    it "shows error when template has no name" do
      visit new_template_path
      
      # Não preenche nome
      click_button "Criar Template"
      
      expect(page).to have_content("Nome não pode ficar em branco")
    end
    
    it "shows error when template has no questions" do
      visit new_template_path
      
      fill_in "Nome", with: "Template sem perguntas"
      
      # Remove todas as perguntas
      within "#perguntas" do
        all('input[type="checkbox"]').each(&:check)
      end
      
      click_button "Criar Template"
      
      expect(page).to have_content("O template deve ter pelo menos uma pergunta")
    end
    
    it "allows adding more questions dynamically" do
      visit new_template_path
      
      # Conta perguntas iniciais
      initial_count = all('.pergunta-card').count
      
      # Adiciona uma pergunta
      click_button "Adicionar Pergunta"
      
      expect(page).to have_css('.pergunta-card', count: initial_count + 1)
      
      # Preenche a pergunta nova
      new_textarea = all('textarea').last
      fill_in new_textarea[:name], with: "Nova pergunta dinâmica?"
      
      fill_in "Nome", with: "Template com pergunta dinâmica"
      
      click_button "Criar Template"
      
      expect(page).to have_content("Template criado com sucesso")
      expect(page).to have_content("Nova pergunta dinâmica?")
    end
  end
  
  describe "editing a template" do
    let!(:template) do
      create(:template, 
             nome: "Template Original",
             administrador: admin,
             perguntas: [
               build(:pergunta, texto: "Pergunta original 1"),
               build(:pergunta, texto: "Pergunta original 2")
             ])
    end
    
    it "updates template name" do
      visit edit_template_path(template)
      
      fill_in "Nome", with: "Template Atualizado"
      click_button "Atualizar Template"
      
      expect(page).to have_content("Template atualizado com sucesso")
      expect(page).to have_content("Template Atualizado")
    end
    
    it "adds a new question to existing template" do
      visit edit_template_path(template)
      
      # Adiciona pergunta nova
      click_button "Adicionar Pergunta"
      
      new_textarea = all('textarea').last
      fill_in new_textarea[:name], with: "Nova pergunta adicionada"
      
      click_button "Atualizar Template"
      
      expect(page).to have_content("Template atualizado com sucesso")
      expect(page).to have_content("Nova pergunta adicionada")
      expect(page).to have_content("Pergunta original 1")
    end
    
    it "removes a question from template" do
      visit edit_template_path(template)
      
      # Verifica remover checkbox para a primeira pergunta
      first_checkbox = first('input[type="checkbox"][name*="_destroy"]')
      check(first_checkbox[:id])
      
      click_button "Atualizar Template"
      
      expect(page).to have_content("Template atualizado com sucesso")
      expect(page).to have_content("Pergunta original 2")
      expect(page).not_to have_content("Pergunta original 1")
    end
  end
  
  describe "deleting a template" do
    let!(:template) { create(:template, nome: "Template para excluir", administrador: admin) }
    
    it "deletes a template" do
      visit templates_path
      
      expect(page).to have_content("Template para excluir")
      
      # Deleta o template
      accept_confirm do
        click_link "Excluir", href: template_path(template)
      end
      
      expect(page).to have_content("Template excluído com sucesso")
      expect(page).not_to have_content("Template para excluir")
    end
  end
  
  describe "authorization" do
    it "redirects professor when trying to access templates" do
      logout
      professor = create(:professor)
      login_as_professor(professor)
      
      visit templates_path
      
      expect(page).to have_content("Acesso não autorizado")
      expect(current_path).to eq(root_path)
    end
    
    it "redirects student when trying to access templates" do
      logout
      aluno = create(:aluno)
      login_as_aluno(aluno)
      
      visit templates_path
      
      expect(page).to have_content("Acesso não autorizado")
      expect(current_path).to eq(root_path)
    end
  end
end