class MakeFormularioOptionalOnTurmas < ActiveRecord::Migration[8.0]
  def up
    change_column_null :turmas, :formulario_id, true
  end

  def down
    change_column_null :turmas, :formulario_id, false
  end
end
