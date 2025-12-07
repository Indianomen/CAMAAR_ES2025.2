class CreateAlunosTurmasJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :alunos, :turmas, column_options: { null: false } do |t|
      t.index [:aluno_id, :turma_id], unique: true, name: 'index_alunos_turmas_on_aluno_id_and_turma_id'
      t.index [:turma_id, :aluno_id], name: 'index_alunos_turmas_on_turma_id_and_aluno_id'
    end
  end
end
