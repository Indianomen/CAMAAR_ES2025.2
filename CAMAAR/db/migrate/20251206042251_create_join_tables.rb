class CreateJoinTables < ActiveRecord::Migration[7.0]
  def change

    # Join table entre Alunos e Formularios
    create_join_table :alunos, :formularios do |t|
      t.index [:aluno_id, :formulario_id], unique: true
      t.index [:formulario_id, :aluno_id]
    end

    # Tabela de respostas
    create_table :respostas do |t|
      t.references :aluno, null: false, foreign_key: true
      t.references :pergunta, null: false, foreign_key: true
      t.references :formulario, null: false, foreign_key: true
      t.text :texto

      t.timestamps
    end
  end
end
