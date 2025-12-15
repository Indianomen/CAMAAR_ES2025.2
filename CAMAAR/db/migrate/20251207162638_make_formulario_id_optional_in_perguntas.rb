class MakeFormularioIdOptionalInPerguntas < ActiveRecord::Migration[7.0]
  def change
    change_column_null :pergunta, :formulario_id, true
    
    remove_foreign_key :pergunta, :formularios if foreign_key_exists?(:pergunta, :formularios)
    
    add_foreign_key :pergunta, :formularios, on_delete: :nullify
  end
end