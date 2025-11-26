require "application_system_test_case"

class ClassessesTest < ApplicationSystemTestCase
  setup do
    @classess = classesses(:one)
  end

  test "visiting the index" do
    visit classesses_url
    assert_selector "h1", text: "Classesses"
  end

  test "should create classess" do
    visit classesses_url
    click_on "New classess"

    fill_in "Disciplina id", with: @classess.disciplina_ID
    fill_in "Form id", with: @classess.form_ID
    fill_in "Professor id", with: @classess.professor_ID
    fill_in "Semestre", with: @classess.semestre
    fill_in "Time", with: @classess.time
    click_on "Create Classess"

    assert_text "Classess was successfully created"
    click_on "Back"
  end

  test "should update Classess" do
    visit classess_url(@classess)
    click_on "Edit this classess", match: :first

    fill_in "Disciplina id", with: @classess.disciplina_ID
    fill_in "Form id", with: @classess.form_ID
    fill_in "Professor id", with: @classess.professor_ID
    fill_in "Semestre", with: @classess.semestre
    fill_in "Time", with: @classess.time
    click_on "Update Classess"

    assert_text "Classess was successfully updated"
    click_on "Back"
  end

  test "should destroy Classess" do
    visit classess_url(@classess)
    click_on "Destroy this classess", match: :first

    assert_text "Classess was successfully destroyed"
  end
end
