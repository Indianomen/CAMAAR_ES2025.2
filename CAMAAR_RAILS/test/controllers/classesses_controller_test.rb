require "test_helper"

class ClassessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @classess = classesses(:one)
  end

  test "should get index" do
    get classesses_url
    assert_response :success
  end

  test "should get new" do
    get new_classess_url
    assert_response :success
  end

  test "should create classess" do
    assert_difference("Classess.count") do
      post classesses_url, params: { classess: { disciplina_ID: @classess.disciplina_ID, form_ID: @classess.form_ID, professor_ID: @classess.professor_ID, semestre: @classess.semestre, time: @classess.time } }
    end

    assert_redirected_to classess_url(Classess.last)
  end

  test "should show classess" do
    get classess_url(@classess)
    assert_response :success
  end

  test "should get edit" do
    get edit_classess_url(@classess)
    assert_response :success
  end

  test "should update classess" do
    patch classess_url(@classess), params: { classess: { disciplina_ID: @classess.disciplina_ID, form_ID: @classess.form_ID, professor_ID: @classess.professor_ID, semestre: @classess.semestre, time: @classess.time } }
    assert_redirected_to classess_url(@classess)
  end

  test "should destroy classess" do
    assert_difference("Classess.count", -1) do
      delete classess_url(@classess)
    end

    assert_redirected_to classesses_url
  end
end
