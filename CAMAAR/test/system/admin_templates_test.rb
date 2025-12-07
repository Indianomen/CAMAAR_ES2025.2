require "application_system_test_case"

class AdminTemplatesTest < ApplicationSystemTestCase
  setup do
    @admin = Administrador.create!(
      nome: "Admin Test",
      usuario: "admin_test",
      email: "admin@test.com",
      password: "password",
      password_confirmation: "password"
    )
    
    # Login as admin
    visit login_path
    fill_in "Usuário", with: @admin.usuario
    fill_in "Senha", with: "password"
    click_button "Login"
  end

  test "admin visits templates index" do
    visit templates_path
    assert_text "Templates de Formulário"
    assert_link "Novo Template"
  end

  test "admin creates a new template with questions" do
    visit templates_path
    click_on "Novo Template"
    
    fill_in "Nome", with: "Avaliação de Disciplina 2024.1"
    
    # Add first question
    fill_in "Pergunta 1", with: "Como você avalia a clareza das explicações?"
    
    # Add more questions
    click_on "Adicionar Pergunta"
    fill_in "Pergunta 2", with: "O material didático foi adequado?"
    
    click_on "Adicionar Pergunta"
    fill_in "Pergunta 3", with: "Sugestões para melhorias:"
    
    click_on "Criar Template"
    
    assert_text "Template criado com sucesso"
    assert_text "Avaliação de Disciplina 2024.1"
    assert_text "Como você avalia a clareza das explicações?"
    assert_text "O material didático foi adequado?"
    assert_text "Sugestões para melhorias:"
  end

  test "admin can edit an existing template" do
    template = Template.create!(
      nome: "Template Antigo",
      administrador: @admin
    )
    
    visit edit_template_path(template)
    
    fill_in "Nome", with: "Template Atualizado"
    click_on "Atualizar Template"
    
    assert_text "Template atualizado com sucesso"
    assert_text "Template Atualizado"
  end

  test "admin can delete a template" do
    template = Template.create!(
      nome: "Template para Excluir",
      administrador: @admin
    )
    
    visit templates_path
    
    accept_confirm do
      click_on "Excluir", match: :first
    end
    
    assert_text "Template excluído com sucesso"
    assert_no_text "Template para Excluir"
  end
end