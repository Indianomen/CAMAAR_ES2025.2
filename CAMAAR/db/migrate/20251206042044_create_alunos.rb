class CreateAlunos < ActiveRecord::Migration[8.0]
  def change
    create_table :alunos do |t|
      t.string :nome
      t.string :curso
      t.string :matricula
      t.string :departamento
      t.string :formacao
      t.string :usuario
      t.string :email
      t.string :ocupacao
      t.boolean :registered
      t.string :password_digest

      t.timestamps
    end
  end
end
