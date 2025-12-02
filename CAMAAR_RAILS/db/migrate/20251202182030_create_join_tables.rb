class CreateJoinTables < ActiveRecord::Migration[8.0]
  def change
    create_table :alunos_turmas, id: false do |t|
      t.belongs_to :aluno
      t.belongs_to :turma
      t.index [:aluno_id, :turma_id], unique: true
    end
    
    create_table :alunos_formularios, id: false do |t|
      t.belongs_to :aluno
      t.belongs_to :formulario
      t.index [:aluno_id, :formulario_id], unique: true
    end
  end
end
