class MakeFormularioOptionalOnTurmas < ActiveRecord::Migration[8.0]
  def up
    # Torna a coluna aceitável a NULL, alinhada com belongs_to :formulario, optional: true
    change_column_null :turmas, :formulario_id, true
  end

  def down
    # Reverte (se precisar voltar atrás)
    change_column_null :turmas, :formulario_id, false
  end
end
