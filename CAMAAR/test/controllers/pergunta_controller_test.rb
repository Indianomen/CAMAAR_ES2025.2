require "test_helper"

class PerguntaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @perguntum = pergunta(:one)
  end

  test "should get index" do
    get pergunta_url
    assert_response :success
  end

  test "should get new" do
    get new_perguntum_url
    assert_response :success
  end

  test "should create perguntum" do
    assert_difference("Perguntum.count") do
      post pergunta_url, params: { perguntum: { formulario_id: @perguntum.formulario_id, resposta: @perguntum.resposta, template_id: @perguntum.template_id, texto: @perguntum.texto } }
    end

    assert_redirected_to perguntum_url(Perguntum.last)
  end

  test "should show perguntum" do
    get perguntum_url(@perguntum)
    assert_response :success
  end

  test "should get edit" do
    get edit_perguntum_url(@perguntum)
    assert_response :success
  end

  test "should update perguntum" do
    patch perguntum_url(@perguntum), params: { perguntum: { formulario_id: @perguntum.formulario_id, resposta: @perguntum.resposta, template_id: @perguntum.template_id, texto: @perguntum.texto } }
    assert_redirected_to perguntum_url(@perguntum)
  end

  test "should destroy perguntum" do
    assert_difference("Perguntum.count", -1) do
      delete perguntum_url(@perguntum)
    end

    assert_redirected_to pergunta_url
  end
end
