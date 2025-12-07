class MakeFormularioIdOptionalInPerguntas < ActiveRecord::Migration[7.0]
  def change
    # Make formulario_id optional (allow null)
    change_column_null :pergunta, :formulario_id, true
    
    # Remove the foreign key constraint
    remove_foreign_key :pergunta, :formularios if foreign_key_exists?(:pergunta, :formularios)
    
    # Add it back but allowing null
    add_foreign_key :pergunta, :formularios, on_delete: :nullify
  end
end