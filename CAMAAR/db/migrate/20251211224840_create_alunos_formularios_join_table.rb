class CreateAlunosFormulariosJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :alunos, :formularios do |t|
      t.index [:aluno_id, :formulario_id], unique: true
      t.timestamps
    end
  end
end