require "application_system_test_case"

class PerguntaTest < ApplicationSystemTestCase
  setup do
    @perguntum = pergunta(:one)
  end

  test "visiting the index" do
    visit pergunta_url
    assert_selector "h1", text: "Pergunta"
  end

  test "should create perguntum" do
    visit pergunta_url
    click_on "New perguntum"

    fill_in "Formulario", with: @perguntum.formulario_id
    fill_in "Resposta", with: @perguntum.resposta
    fill_in "Template", with: @perguntum.template_id
    fill_in "Texto", with: @perguntum.texto
    click_on "Create Perguntum"

    assert_text "Perguntum was successfully created"
    click_on "Back"
  end

  test "should update Perguntum" do
    visit perguntum_url(@perguntum)
    click_on "Edit this perguntum", match: :first

    fill_in "Formulario", with: @perguntum.formulario_id
    fill_in "Resposta", with: @perguntum.resposta
    fill_in "Template", with: @perguntum.template_id
    fill_in "Texto", with: @perguntum.texto
    click_on "Update Perguntum"

    assert_text "Perguntum was successfully updated"
    click_on "Back"
  end

  test "should destroy Perguntum" do
    visit perguntum_url(@perguntum)
    click_on "Destroy this perguntum", match: :first

    assert_text "Perguntum was successfully destroyed"
  end
end
