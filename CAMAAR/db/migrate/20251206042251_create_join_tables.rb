class CreateJoinTables < ActiveRecord::Migration[7.0]
  def change
    # Alunos and Turmas (students enrolled in classes)
    create_table :alunos_turmas, id: false do |t|
      t.belongs_to :aluno
      t.belongs_to :turma
      t.index [:aluno_id, :turma_id], unique: true
    end
    
    # Alunos and Formularios (students who have answered forms)
    create_table :alunos_formularios, id: false do |t|
      t.belongs_to :aluno
      t.belongs_to :formulario
      t.index [:aluno_id, :formulario_id], unique: true
    end
    
    # Add resposta model for answers
    create_table :respostas do |t|
      t.references :aluno, null: false, foreign_key: true
      t.references :pergunta, null: false, foreign_key: true
      t.references :formulario, null: false, foreign_key: true
      t.text :texto

      t.timestamps
    end
  end
end