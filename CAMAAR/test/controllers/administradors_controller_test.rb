require "test_helper"

class AdministradorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @administrador = administradors(:one)
  end

  test "should get index" do
    get administradors_url
    assert_response :success
  end

  test "should get new" do
    get new_administrador_url
    assert_response :success
  end

  test "should create administrador" do
    assert_difference("Administrador.count") do
      post administradors_url, params: { administrador: { departamento: @administrador.departamento, email: @administrador.email, formacao: @administrador.formacao, nome: @administrador.nome, ocupacao: @administrador.ocupacao, password_digest: @administrador.password_digest, usuario: @administrador.usuario } }
    end

    assert_redirected_to administrador_url(Administrador.last)
  end

  test "should show administrador" do
    get administrador_url(@administrador)
    assert_response :success
  end

  test "should get edit" do
    get edit_administrador_url(@administrador)
    assert_response :success
  end

  test "should update administrador" do
    patch administrador_url(@administrador), params: { administrador: { departamento: @administrador.departamento, email: @administrador.email, formacao: @administrador.formacao, nome: @administrador.nome, ocupacao: @administrador.ocupacao, password_digest: @administrador.password_digest, usuario: @administrador.usuario } }
    assert_redirected_to administrador_url(@administrador)
  end

  test "should destroy administrador" do
    assert_difference("Administrador.count", -1) do
      delete administrador_url(@administrador)
    end

    assert_redirected_to administradors_url
  end
end
