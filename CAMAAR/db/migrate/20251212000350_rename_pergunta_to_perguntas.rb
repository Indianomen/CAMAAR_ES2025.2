class RenamePerguntaToPerguntas < ActiveRecord::Migration[8.0]
  def change
    rename_table :pergunta, :perguntas
    
    # Update foreign key references
    rename_column :perguntas, :template_id, :template_id
    rename_column :perguntas, :formulario_id, :formulario_id
    
    # Update indexes
    rename_index :perguntas, 'index_pergunta_on_formulario_id', 'index_perguntas_on_formulario_id'
    rename_index :perguntas, 'index_pergunta_on_template_id', 'index_perguntas_on_template_id'
  end
end